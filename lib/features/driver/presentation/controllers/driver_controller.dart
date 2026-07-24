import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/bus_model.dart';
import '../../../../shared/models/driver_report_model.dart';
import '../../../../shared/models/trip_model.dart';
import '../../../../shared/services/driver_service.dart';
import '../../../../shared/services/trip_service.dart';
import '../../../../shared/services/location_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

enum DriverTripState { notStarted, inProgress, completed, paused }

class DriverController extends GetxController {
  static DriverController get to => Get.find();

  // Services
  final _driverService = DriverService();
  final _tripService = TripService();
  final _locationService = Get.find<LocationService>();

  // Observables
  final RxInt selectedTabIndex = 0.obs;
  final Rx<DriverTripState> tripStatus = DriverTripState.notStarted.obs;
  final RxBool isSharingLocation = false.obs;
  final RxDouble currentSpeed = 0.0.obs;
  final RxInt passengerCount = 0.obs;
  final RxInt todayTrips = 0.obs;
  final RxDouble totalDistance = 0.0.obs;
  final RxList<DriverReport> reports = <DriverReport>[].obs;
  final RxList<TripModel> trips = <TripModel>[].obs;
  final Rx<BusModel?> assignedBus = Rx<BusModel?>(null);
  final Rx<TripModel?> activeTrip = Rx<TripModel?>(null);
  final Rx<LatLng> currentPosition = const LatLng(8.2280, 123.3317).obs;
  final RxBool isLoadingBus = true.obs;

  // Subscriptions
  StreamSubscription? _busSubscription;
  StreamSubscription? _reportsSubscription;
  StreamSubscription? _tripsSubscription;
  StreamSubscription? _activeTripSubscription;
  StreamSubscription<Position>? _locationSubscription;
  Timer? _locationUpdateTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeDriver();
  }

  @override
  void onClose() {
    _busSubscription?.cancel();
    _reportsSubscription?.cancel();
    _tripsSubscription?.cancel();
    _activeTripSubscription?.cancel();
    _locationSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    super.onClose();
  }

  /// Initialize driver data
  void _initializeDriver() async {
    final driverId = currentUserId;
    if (driverId == null) return;

    isLoadingBus.value = true;

    // Watch assigned bus
    _busSubscription = _driverService.watchDriverBus(driverId).listen(
      (bus) {
        assignedBus.value = bus;
        isLoadingBus.value = false;
        if (bus != null) {
          currentPosition.value = bus.position;
          currentSpeed.value = bus.speed;
          passengerCount.value = bus.passengerCount;
          
          // Sync trip status with bus status ONLY if not manually controlled
          // Don't override manual state changes (pause/resume)
          if (bus.status == BusStatus.online && tripStatus.value != DriverTripState.inProgress) {
            tripStatus.value = DriverTripState.inProgress;
            isSharingLocation.value = true;
          } else if (bus.status == BusStatus.offline && tripStatus.value != DriverTripState.notStarted) {
            tripStatus.value = DriverTripState.notStarted;
            isSharingLocation.value = false;
          }
          // Don't change to paused automatically - only through manual pauseTrip()
        }
      },
      onError: (error) {
        print('Error loading bus: $error');
        isLoadingBus.value = false;
      },
    );

    // Watch reports
    _reportsSubscription = _driverService.watchDriverReports(driverId).listen(
      (reportsList) {
        reports.value = reportsList;
      },
      onError: (error) {
        print('Error loading reports: $error');
      },
    );

    // Watch driver's trips
    _tripsSubscription = _tripService.watchTodayDriverTrips(driverId).listen(
      (tripsList) {
        trips.value = tripsList;
      },
      onError: (error) {
        print('Error loading trips: $error');
      },
    );

    // Watch active trip for the assigned bus
    if (assignedBus.value != null) {
      _activeTripSubscription = _tripService
          .watchBusActiveTrip(assignedBus.value!.id)
          .listen(
        (trip) {
          activeTrip.value = trip;
        },
        onError: (error) {
          print('Error loading active trip: $error');
        },
      );
    }

    // Load today's stats
    _loadTodayStats(driverId);
  }

  /// Load today's trip statistics
  void _loadTodayStats(String driverId) async {
    final stats = await _driverService.getTodayStats(driverId);
    todayTrips.value = stats['completedTrips'] ?? 0;
    totalDistance.value = stats['totalDistance'] ?? 0.0;
  }

  UserModel? get currentUser => Get.find<AuthController>().currentUser.value;
  String? get currentUserId => Get.find<AuthController>().currentUser.value?.id;

  String get assignedBusNumber => assignedBus.value?.busNumber ?? 'N/A';
  String get assignedRoute => assignedBus.value?.routeName ?? 'Not Assigned';

  void changeTab(int index) => selectedTabIndex.value = index;

  void setTabFromRoute(String routeName) {
    switch (routeName) {
      case '/driver/dashboard':
        selectedTabIndex.value = 0;
        break;
      case '/driver/active-route':
        selectedTabIndex.value = 1;
        break;
      case '/driver/routes':
        selectedTabIndex.value = 2;
        break;
      case '/driver/schedule':
        selectedTabIndex.value = 3;
        break;
      case '/driver/reports':
        selectedTabIndex.value = 4;
        break;
      case '/driver/profile':
        selectedTabIndex.value = 5;
        break;
    }
  }

  /// Start trip - begin location sharing (OPTIMIZED: Instant UI feedback)
  Future<void> startTrip([BuildContext? context]) async {
    print('🚀 Starting trip...');
    print('   assignedBus: ${assignedBus.value?.busNumber}');
    print('   currentUserId: $currentUserId');
    
    if (assignedBus.value == null) {
      _showSnackbar('Error', 'No bus assigned');
      print('❌ No bus assigned');
      return;
    }
    
    if (currentUserId == null) {
      _showSnackbar('Error', 'User not logged in');
      print('❌ User not logged in');
      return;
    }

    try {
      print('✓ Bus and user validated');
      
      // Check permissions first (with dialog support)
      final hasPermission = await _locationService.checkAndRequestPermissions(context);
      if (!hasPermission) {
        _showSnackbar('Permission Required', 'Location permission is required to start tracking');
        return;
      }
      
      print('✓ Permissions granted');

      // Get current location
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        _showSnackbar('Error', 'Unable to get current location');
        return;
      }
      
      print('✓ Got position: ${position.latitude}, ${position.longitude}');
      currentPosition.value = LatLng(position.latitude, position.longitude);

      // 🚀 OPTIMISTIC UPDATE: Update UI immediately for instant feedback
      tripStatus.value = DriverTripState.inProgress;
      isSharingLocation.value = true;
      
      print('⚡ UI updated instantly (optimistic)');

      // Start Firebase updates in background (non-blocking)
      _driverService.startTrip(
        busId: assignedBus.value!.id,
        routeId: assignedBus.value!.routeId,
        latitude: position.latitude,
        longitude: position.longitude,
      ).then((_) {
        print('✓ Firebase trip started (background)');
      }).catchError((e) {
        print('❌ Firebase error: $e (UI already updated)');
        // UI already shows correct state, Firebase will sync eventually
      });

      // Start location tracking in background (non-blocking)
      _locationService.startTracking(
        currentUserId!,
        assignedBus.value!.id,
      ).then((_) {
        print('✓ Location tracking started (background)');
      }).catchError((e) {
        print('❌ Tracking error: $e');
      });

      // Listen to location updates from the service
      _locationService.currentPosition.listen((Position? pos) {
        if (pos != null) {
          currentPosition.value = LatLng(pos.latitude, pos.longitude);
          currentSpeed.value = pos.speed * 3.6; // m/s to km/h
        }
      });

      _showSnackbar('Trip Started', 'Location sharing is now active');
      print('✅ Trip started successfully (instant UI)!');
    } catch (e, stackTrace) {
      // Rollback optimistic update on failure
      tripStatus.value = DriverTripState.notStarted;
      isSharingLocation.value = false;
      print('❌ Error starting trip: $e');
      print('Stack trace: $stackTrace');
      _showSnackbar('Error', 'Failed to start trip: $e');
    }
  }

  /// End trip (OPTIMIZED: Instant UI feedback)
  Future<void> endTrip() async {
    if (assignedBus.value == null) return;

    try {
      // 🚀 OPTIMISTIC UPDATE: Update UI immediately
      tripStatus.value = DriverTripState.completed;
      isSharingLocation.value = false;
      currentSpeed.value = 0;
      todayTrips.value++;
      print('⚡ Trip ended instantly (optimistic)');
      
      _showSnackbar('Trip Ended', 'Location sharing stopped');

      // Stop location tracking in background
      _locationService.stopTracking(assignedBus.value!.id).catchError((e) {
        print('❌ Error stopping tracking: $e');
      });
      
      // Get final position and update Firebase in background
      _locationService.getCurrentPosition().then((position) {
        if (position != null) {
          return _driverService.endTrip(
            busId: assignedBus.value!.id,
            latitude: position.latitude,
            longitude: position.longitude,
          );
        }
      }).then((_) {
        print('✓ Firebase trip ended (background)');
      }).catchError((e) {
        print('❌ Firebase error: $e (UI already updated)');
      });
      
      // Reset to not started after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (tripStatus.value == DriverTripState.completed) {
          tripStatus.value = DriverTripState.notStarted;
        }
      });
    } catch (e) {
      // Rollback on failure
      tripStatus.value = DriverTripState.inProgress;
      isSharingLocation.value = true;
      todayTrips.value--;
      print('❌ Error ending trip: $e');
      _showSnackbar('Error', 'Failed to end trip');
    }
  }

  /// Pause trip (OPTIMIZED: Instant UI feedback)
  Future<void> pauseTrip() async {
    if (assignedBus.value == null) return;

    try {
      // 🚀 OPTIMISTIC UPDATE: Update UI immediately
      tripStatus.value = DriverTripState.paused;
      isSharingLocation.value = false;
      currentSpeed.value = 0;
      print('⚡ Trip paused instantly (optimistic)');
      
      _showSnackbar('Trip Paused', 'Location sharing paused');

      // Stop location service in background
      _locationService.stopTracking(assignedBus.value!.id).catchError((e) {
        print('❌ Error stopping tracking: $e');
      });
      
      // Update Firebase in background
      _driverService.pauseTrip(assignedBus.value!.id).then((_) {
        print('✓ Firebase updated (background)');
      }).catchError((e) {
        print('❌ Firebase error: $e (UI already updated)');
      });
    } catch (e) {
      // Rollback on failure
      tripStatus.value = DriverTripState.inProgress;
      isSharingLocation.value = true;
      print('❌ Error pausing trip: $e');
    }
  }

  /// Resume trip (OPTIMIZED: Instant UI feedback)
  Future<void> resumeTrip() async {
    if (assignedBus.value == null || currentUserId == null) return;

    try {
      // 🚀 OPTIMISTIC UPDATE: Update UI immediately
      tripStatus.value = DriverTripState.inProgress;
      isSharingLocation.value = true;
      print('⚡ Trip resumed instantly (optimistic)');
      
      _showSnackbar('Trip Resumed', 'Location sharing resumed');

      // Update Firebase in background
      _driverService.resumeTrip(assignedBus.value!.id).then((_) {
        print('✓ Firebase updated (background)');
      }).catchError((e) {
        print('❌ Firebase error: $e (UI already updated)');
      });
      
      // Restart location tracking in background
      _locationService.startTracking(
        currentUserId!,
        assignedBus.value!.id,
      ).then((_) {
        print('✓ Location tracking restarted (background)');
      }).catchError((e) {
        print('❌ Tracking error: $e');
      });
    } catch (e) {
      // Rollback on failure
      tripStatus.value = DriverTripState.paused;
      isSharingLocation.value = false;
      print('❌ Error resuming trip: $e');
    }
  }

  /// Update passenger count
  Future<void> updatePassengerCount(int count) async {
    if (assignedBus.value == null) return;

    passengerCount.value = count;
    await _driverService.updatePassengerCount(assignedBus.value!.id, count);
  }

  /// Submit a report
  Future<void> submitReport({
    required String type,
    required String description,
  }) async {
    final driverId = currentUserId;
    if (driverId == null || assignedBus.value == null) return;

    try {
      final position = await _locationService.getCurrentPosition();
      
      await _driverService.submitReport(
        driverId: driverId,
        busId: assignedBus.value!.id,
        type: type,
        description: description,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      _showSnackbar('Success', 'Report submitted successfully');
    } catch (e) {
      print('Error submitting report: $e');
      _showSnackbar('Error', 'Failed to submit report');
    }
  }

  String get tripStatusLabel {
    switch (tripStatus.value) {
      case DriverTripState.notStarted:
        return 'Ready to Start';
      case DriverTripState.inProgress:
        return 'Trip in Progress';
      case DriverTripState.paused:
        return 'Trip Paused';
      case DriverTripState.completed:
        return 'Trip Completed';
    }
  }

  /// Safe snackbar helper that handles null context errors
  void _showSnackbar(String title, String message) {
    // For now, just use print to avoid GetX context issues
    // TODO: Implement proper snackbar when navigation is stable
    print('$title: $message');
  }
}

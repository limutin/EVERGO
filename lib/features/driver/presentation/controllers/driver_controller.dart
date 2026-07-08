import 'dart:async';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/bus_model.dart';
import '../../../../shared/models/driver_report_model.dart';
import '../../../../shared/models/trip_model.dart';
import '../../../../shared/services/driver_service.dart';
import '../../../../shared/services/trip_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

enum DriverTripState { notStarted, inProgress, completed, paused }

class DriverController extends GetxController {
  static DriverController get to => Get.find();

  // Services
  final _driverService = DriverService();
  final _tripService = TripService();

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
          
          // Determine trip status from bus status
          if (bus.status == BusStatus.online) {
            tripStatus.value = DriverTripState.inProgress;
            isSharingLocation.value = true;
          } else if (bus.status == BusStatus.idle) {
            if (tripStatus.value == DriverTripState.inProgress) {
              tripStatus.value = DriverTripState.paused;
            }
          }
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

  /// Start trip - begin location sharing
  Future<void> startTrip() async {
    if (assignedBus.value == null) return;

    try {
      // Get current location
      final position = await _getCurrentLocation();
      if (position == null) return;

      currentPosition.value = LatLng(position.latitude, position.longitude);

      // Update Firebase
      await _driverService.startTrip(
        busId: assignedBus.value!.id,
        routeId: assignedBus.value!.routeId,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      tripStatus.value = DriverTripState.inProgress;
      isSharingLocation.value = true;

      // Start location tracking
      _startLocationTracking();
    } catch (e) {
      print('Error starting trip: $e');
      Get.snackbar('Error', 'Failed to start trip');
    }
  }

  /// Pause trip
  Future<void> pauseTrip() async {
    if (assignedBus.value == null) return;

    try {
      await _driverService.pauseTrip(assignedBus.value!.id);
      tripStatus.value = DriverTripState.paused;
      currentSpeed.value = 0;
      _stopLocationTracking();
    } catch (e) {
      print('Error pausing trip: $e');
    }
  }

  /// Resume trip
  Future<void> resumeTrip() async {
    if (assignedBus.value == null) return;

    try {
      await _driverService.resumeTrip(assignedBus.value!.id);
      tripStatus.value = DriverTripState.inProgress;
      _startLocationTracking();
    } catch (e) {
      print('Error resuming trip: $e');
    }
  }

  /// End trip
  Future<void> endTrip() async {
    if (assignedBus.value == null) return;

    try {
      final position = await _getCurrentLocation();
      if (position != null) {
        await _driverService.endTrip(
          busId: assignedBus.value!.id,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      tripStatus.value = DriverTripState.completed;
      isSharingLocation.value = false;
      currentSpeed.value = 0;
      _stopLocationTracking();

      todayTrips.value++;
      
      // Reset to not started after a delay
      Future.delayed(const Duration(seconds: 3), () {
        tripStatus.value = DriverTripState.notStarted;
      });
    } catch (e) {
      print('Error ending trip: $e');
    }
  }

  /// Start tracking location
  void _startLocationTracking() {
    _locationUpdateTimer?.cancel();
    
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (assignedBus.value == null || tripStatus.value != DriverTripState.inProgress) {
        return;
      }

      final position = await _getCurrentLocation();
      if (position != null) {
        currentPosition.value = LatLng(position.latitude, position.longitude);
        currentSpeed.value = position.speed * 3.6; // Convert m/s to km/h

        // Update Firebase
        await _driverService.updateLocation(
          busId: assignedBus.value!.id,
          latitude: position.latitude,
          longitude: position.longitude,
          speed: position.speed * 3.6,
          heading: position.heading,
        );
      }
    });
  }

  /// Stop tracking location
  void _stopLocationTracking() {
    _locationUpdateTimer?.cancel();
    _locationSubscription?.cancel();
  }

  /// Get current GPS location
  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting location: $e');
      return null;
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
      final position = await _getCurrentLocation();
      
      await _driverService.submitReport(
        driverId: driverId,
        busId: assignedBus.value!.id,
        type: type,
        description: description,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      Get.snackbar('Success', 'Report submitted successfully');
    } catch (e) {
      print('Error submitting report: $e');
      Get.snackbar('Error', 'Failed to submit report');
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
}

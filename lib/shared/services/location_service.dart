import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

/// Service to manage real-time GPS location tracking and broadcasting
class LocationService extends GetxService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  Timer? _uploadTimer;
  
  // Observable location state
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isTracking = false.obs;
  final RxString trackingError = ''.obs;

  /// Check and request location permissions
  Future<bool> checkAndRequestPermissions(BuildContext? context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      trackingError.value = 'Location services are disabled. Please enable them.';
      
      // Show dialog prompting user to enable location services
      if (context != null && context.mounted) {
        final shouldOpenSettings = await _showLocationServicesDialog(context);
        if (shouldOpenSettings == true) {
          await Geolocator.openLocationSettings();
          // Wait a bit and check again
          await Future.delayed(const Duration(seconds: 1));
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            return false;
          }
        } else {
          return false;
        }
      } else {
        print('⚠️ Location services are disabled. Please enable them in device settings.');
        return false;
      }
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        trackingError.value = 'Location permission denied.';
        if (context != null && context.mounted) {
          await _showPermissionDeniedDialog(context);
        } else {
          print('⚠️ Location permission denied. Please grant permission in app settings.');
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      trackingError.value = 'Location permissions are permanently denied.';
      if (context != null && context.mounted) {
        final shouldOpenSettings = await _showPermissionDeniedForeverDialog(context);
        if (shouldOpenSettings == true) {
          await Geolocator.openAppSettings();
        }
      } else {
        print('⚠️ Location permissions permanently denied. Please enable in Settings > Apps > Evergo > Permissions.');
      }
      return false;
    }

    trackingError.value = '';
    print('✅ Location permissions granted');
    return true;
  }

  /// Show native dialog for disabled location services
  Future<bool?> _showLocationServicesDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_off, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Expanded(child: Text('Location Services Disabled')),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GPS location is required for real-time bus tracking.',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 12),
              Text(
                '⚠️ For drivers: Location must stay ON during trips to track your bus in real-time.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Please enable location services in your device settings.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  /// Show native dialog for denied permission
  Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Expanded(child: Text('Permission Required')),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location permission is required to track the bus in real-time.',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 12),
              Text(
                '📍 TIP FOR DRIVERS:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'When Android asks for permission, choose "Allow all the time" or "Always" for uninterrupted tracking during trips.',
                style: TextStyle(fontSize: 13, color: Colors.blue),
              ),
              SizedBox(height: 12),
              Text(
                'Please tap "Start Trip" again and grant permission when prompted.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK, Got It'),
            ),
          ],
        );
      },
    );
  }

  /// Show native dialog for permanently denied permission
  Future<bool?> _showPermissionDeniedForeverDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.block, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Expanded(child: Text('Location Permission Required')),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location permission has been permanently denied.',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 16),
                Text(
                  '⚠️ IMPORTANT FOR DRIVERS:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You must enable "Allow all the time" or "Always" permission for GPS tracking to work during trips.',
                  style: TextStyle(fontSize: 14, color: Colors.orange),
                ),
                SizedBox(height: 16),
                Text(
                  'To enable location:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text('1. Go to Settings'),
                Text('2. Select Apps → Evergo'),
                Text('3. Select Permissions → Location'),
                Text('4. Choose "Allow all the time" or "Always"'),
                SizedBox(height: 12),
                Text(
                  'Tap "Open Settings" below for quick access.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not Now'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  /// Start tracking driver location and broadcasting to Firebase
  Future<void> startTracking(String driverId, String busId) async {
    if (isTracking.value) {
      print('⚠️ Location tracking already active');
      return;
    }

    // Check permissions (no dialog, silent check for background tracking)
    final hasPermission = await checkAndRequestPermissions(null);
    if (!hasPermission) {
      print('❌ Location permissions not granted');
      return;
    }

    print('📍 Starting location tracking for driver: $driverId, bus: $busId');
    isTracking.value = true;

    // Configure location settings for high accuracy
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters
      timeLimit: Duration(seconds: 10),
    );

    // Listen to position stream
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _currentPosition = position;
        currentPosition.value = position;
        print('📍 New position: ${position.latitude}, ${position.longitude} @ ${position.speed} m/s');
      },
      onError: (error) {
        print('❌ Location stream error: $error');
        trackingError.value = 'Location tracking error: $error';
      },
    );

    // Upload location to Firebase every 3 seconds
    _uploadTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPosition != null) {
        _uploadLocationToFirebase(driverId, busId, _currentPosition!);
      }
    });
  }

  /// Upload current location to Firebase Realtime Database
  /// Writes to /locations/{busId} for low-latency tracking
  Future<void> _uploadLocationToFirebase(
    String driverId,
    String busId,
    Position position,
  ) async {
    try {
      final speedKmh = position.speed * 3.6; // Convert m/s to km/h
      
      final locationRef = _database.ref('locations/$busId');
      await locationRef.update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'speed': speedKmh,
        'heading': position.heading,
        'accuracy': position.accuracy,
        'lastUpdated': ServerValue.timestamp,
        'status': speedKmh > 5 ? 'online' : 'idle', // Auto-detect status
      });

      print('✅ Location uploaded: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('❌ Error uploading location: $e');
    }
  }

  /// Stop tracking and clean up resources
  Future<void> stopTracking(String busId) async {
    print('🛑 Stopping location tracking');
    
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    
    _uploadTimer?.cancel();
    _uploadTimer = null;
    
    isTracking.value = false;
    _currentPosition = null;
    currentPosition.value = null;

    // Remove location from RTDB
    try {
      final locationRef = _database.ref('locations/$busId');
      await locationRef.remove();
    } catch (e) {
      print('❌ Error removing location: $e');
    }
  }

  /// Get current position once (not streaming)
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkAndRequestPermissions(null);
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      return position;
    } catch (e) {
      print('❌ Error getting current position: $e');
      return null;
    }
  }

  /// Calculate distance between two coordinates (in meters)
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Check if bus is near a stop (within 50 meters)
  bool isNearStop(Position busPosition, double stopLat, double stopLng) {
    final distance = calculateDistance(
      busPosition.latitude,
      busPosition.longitude,
      stopLat,
      stopLng,
    );
    return distance <= 50; // 50 meters threshold
  }

  @override
  void onClose() {
    stopTracking('');
    super.onClose();
  }
}

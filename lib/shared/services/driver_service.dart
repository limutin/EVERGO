import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../models/bus_model.dart';
import '../models/driver_report_model.dart';
import 'firebase_service.dart';

/// Service for driver-specific operations
class DriverService extends FirebaseService {
  CollectionReference get busesCollection => firestore.collection('buses');
  CollectionReference get driversCollection => firestore.collection('drivers');
  CollectionReference get reportsCollection => firestore.collection('reports');
  CollectionReference get tripLogsCollection => firestore.collection('tripLogs');

  /// Get driver's assigned bus
  Stream<BusModel?> watchDriverBus(String driverId) {
    return busesCollection
        .where('driverId', isEqualTo: driverId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return _busFromFirestore(snapshot.docs.first);
    });
  }

  /// Get driver profile with assigned bus info
  Future<Map<String, dynamic>?> getDriverProfile(String driverId) async {
    try {
      final doc = await driversCollection.doc(driverId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting driver profile: $e');
      return null;
    }
  }

  /// Start a trip - update bus status to online
  Future<void> startTrip({
    required String busId,
    required String routeId,
    required double latitude,
    required double longitude,
  }) async {
    final batch = firestore.batch();

    // Update bus status
    batch.update(busesCollection.doc(busId), {
      'status': 'online',
      'position': GeoPoint(latitude, longitude),
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    // Create trip log
    final tripLogRef = tripLogsCollection.doc();
    batch.set(tripLogRef, {
      'busId': busId,
      'routeId': routeId,
      'startTime': FieldValue.serverTimestamp(),
      'startPosition': GeoPoint(latitude, longitude),
      'status': 'in_progress',
    });

    await batch.commit();
  }

  /// End trip - update bus status to idle
  Future<void> endTrip({
    required String busId,
    required double latitude,
    required double longitude,
  }) async {
    await busesCollection.doc(busId).update({
      'status': 'idle',
      'position': GeoPoint(latitude, longitude),
      'speed': 0,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Pause trip - temporarily set to idle
  Future<void> pauseTrip(String busId) async {
    await busesCollection.doc(busId).update({
      'status': 'idle',
      'speed': 0,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Resume trip - set back to online
  Future<void> resumeTrip(String busId) async {
    await busesCollection.doc(busId).update({
      'status': 'online',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Update real-time location during trip
  Future<void> updateLocation({
    required String busId,
    required double latitude,
    required double longitude,
    required double speed,
    required double heading,
  }) async {
    await busesCollection.doc(busId).update({
      'position': GeoPoint(latitude, longitude),
      'speed': speed,
      'heading': heading,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Update passenger count
  Future<void> updatePassengerCount(String busId, int count) async {
    await busesCollection.doc(busId).update({
      'passengerCount': count,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Submit a driver report
  Future<void> submitReport({
    required String driverId,
    required String busId,
    required String type,
    required String description,
    double? latitude,
    double? longitude,
  }) async {
    await reportsCollection.add({
      'driverId': driverId,
      'busId': busId,
      'type': type,
      'description': description,
      'location': latitude != null && longitude != null
          ? GeoPoint(latitude, longitude)
          : null,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'submitted',
    });
  }

  /// Get driver's reports
  Stream<List<DriverReport>> watchDriverReports(String driverId) {
    return reportsCollection
        .where('driverId', isEqualTo: driverId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return _reportFromFirestore(doc);
      }).toList();
    });
  }



  /// Get trip statistics for today
  Future<Map<String, dynamic>> getTodayStats(String driverId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      final snapshot = await tripLogsCollection
          .where('driverId', isEqualTo: driverId)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      int completedTrips = 0;
      double totalDistance = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['status'] == 'completed') {
          completedTrips++;
          totalDistance += (data['distance'] as num?)?.toDouble() ?? 0;
        }
      }

      return {
        'completedTrips': completedTrips,
        'totalDistance': totalDistance,
      };
    } catch (e) {
      print('Error getting today stats: $e');
      return {'completedTrips': 0, 'totalDistance': 0.0};
    }
  }

  /// Convert Firestore document to BusModel
  BusModel _busFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final position = data['position'] as GeoPoint?;
    final lastUpdated = data['lastUpdated'] as Timestamp?;

    return BusModel(
      id: doc.id,
      busNumber: data['busNumber'] as String? ?? '',
      plateNumber: data['plateNumber'] as String? ?? '',
      driverName: data['driverName'] as String? ?? '',
      routeId: data['routeId'] as String? ?? '',
      routeName: data['routeName'] as String? ?? '',
      position: position != null
          ? LatLng(position.latitude, position.longitude)
          : const LatLng(8.2280, 123.3317),
      status: _parseStatus(data['status'] as String?),
      speed: (data['speed'] as num?)?.toDouble() ?? 0.0,
      passengerCount: data['passengerCount'] as int? ?? 0,
      capacity: data['capacity'] as int? ?? 50,
      lastUpdated: lastUpdated?.toDate() ?? DateTime.now(),
      heading: (data['heading'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert Firestore document to DriverReport
  DriverReport _reportFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['timestamp'] as Timestamp?;

    return DriverReport(
      id: doc.id,
      type: data['type'] as String? ?? '',
      description: data['description'] as String? ?? '',
      timestamp: timestamp?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'submitted',
    );
  }



  /// Parse bus status from string
  BusStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'online':
        return BusStatus.online;
      case 'offline':
        return BusStatus.offline;
      case 'idle':
        return BusStatus.idle;
      default:
        return BusStatus.offline;
    }
  }
}

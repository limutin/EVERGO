import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';
import '../models/bus_model.dart';
import '../models/driver_report_model.dart';

/// Service for driver-specific operations
/// Uses Firestore for permanent data (assignments, metadata)
/// Uses RTDB for real-time location tracking
class DriverService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  CollectionReference get busesCollection => _firestore.collection('buses');
  CollectionReference get driversCollection => _firestore.collection('drivers');
  CollectionReference get reportsCollection => _firestore.collection('reports');
  CollectionReference get tripLogsCollection => _firestore.collection('tripLogs');
  
  DatabaseReference get locationRef => _database.ref('locations');

  /// Get driver's assigned bus from Firestore
  Stream<BusModel?> watchDriverBus(String driverId) {
    return busesCollection
        .where('driverId', isEqualTo: driverId)
        .limit(1)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return null;
      return await _busFromFirestoreWithRoute(snapshot.docs.first);
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

  /// Start a trip - update bus status in Firestore
  Future<void> startTrip({
    required String busId,
    required String routeId,
    required double latitude,
    required double longitude,
  }) async {
    final batch = _firestore.batch();

    // Update bus status in Firestore
    batch.update(busesCollection.doc(busId), {
      'status': 'online',
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    // Create trip log in Firestore
    final tripLogRef = tripLogsCollection.doc();
    batch.set(tripLogRef, {
      'busId': busId,
      'routeId': routeId,
      'startTime': FieldValue.serverTimestamp(),
      'startLatitude': latitude,
      'startLongitude': longitude,
      'status': 'in_progress',
    });

    await batch.commit();
    
    // Initialize location in RTDB
    await locationRef.child(busId).set({
      'latitude': latitude,
      'longitude': longitude,
      'speed': 0,
      'heading': 0,
      'accuracy': 0,
      'status': 'online',
      'lastUpdated': ServerValue.timestamp,
    });
  }

  /// End trip - update bus status in Firestore, remove from RTDB
  Future<void> endTrip({
    required String busId,
    required double latitude,
    required double longitude,
  }) async {
    await busesCollection.doc(busId).update({
      'status': 'idle',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
    
    // Remove from RTDB locations
    await locationRef.child(busId).remove();
  }

  /// Pause trip - update status in Firestore only
  Future<void> pauseTrip(String busId) async {
    await busesCollection.doc(busId).update({
      'status': 'idle',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Resume trip - update status in Firestore only
  Future<void> resumeTrip(String busId) async {
    await busesCollection.doc(busId).update({
      'status': 'online',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Update passenger count in Firestore
  Future<void> updatePassengerCount(String busId, int count) async {
    await busesCollection.doc(busId).update({
      'passengerCount': count,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Submit a driver report to Firestore
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

  /// Get driver's reports from Firestore
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

  /// Get trip statistics for today from Firestore
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

  /// Convert Firestore document to BusModel with route lookup
  Future<BusModel> _busFromFirestoreWithRoute(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final lastUpdated = data['lastUpdated'] as Timestamp?;
    final routeId = data['routeId'] as String?;

    // Fetch route name from routes collection if routeId exists
    String routeName = data['routeName'] as String? ?? 'Unknown Route';
    if (routeId != null && routeId.isNotEmpty) {
      try {
        final routeDoc = await _firestore.collection('routes').doc(routeId).get();
        if (routeDoc.exists) {
          final routeData = routeDoc.data() as Map<String, dynamic>;
          routeName = routeData['name'] as String? ?? routeName;
          print('✅ Route fetched: $routeName for routeId: $routeId');
        } else {
          print('⚠️ Route document not found for routeId: $routeId');
        }
      } catch (e) {
        print('❌ Error fetching route: $e');
      }
    }

    // Handle both GeoPoint and separate lat/lng fields
    LatLng position;
    if (data.containsKey('position')) {
      final geoPoint = data['position'] as GeoPoint?;
      position = geoPoint != null
          ? LatLng(geoPoint.latitude, geoPoint.longitude)
          : const LatLng(8.2280, 123.3317);
    } else {
      // Use separate latitude/longitude fields
      final lat = (data['latitude'] as num?)?.toDouble() ?? 8.2280;
      final lng = (data['longitude'] as num?)?.toDouble() ?? 123.3317;
      position = LatLng(lat, lng);
    }

    return BusModel(
      id: doc.id,
      busNumber: data['busNumber'] as String? ?? '',
      plateNumber: data['plateNumber'] as String? ?? '',
      driverName: data['driverName'] as String? ?? '',
      routeId: routeId ?? '',
      routeName: routeName,
      position: position,
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../models/bus_model.dart';
import 'firebase_service.dart';

/// Service for managing bus data from Firebase
class BusService extends FirebaseService {
  /// Collection references
  CollectionReference get busesCollection => firestore.collection('buses');
  CollectionReference get routesCollection => firestore.collection('routes');

  /// Stream of all active buses
  Stream<List<BusModel>> watchActiveBuses() {
    return busesCollection
        .where('status', whereIn: ['online', 'idle'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return _busFromFirestore(doc);
      }).toList();
    });
  }

  /// Stream of buses by route
  Stream<List<BusModel>> watchBusesByRoute(String routeId) {
    return busesCollection
        .where('routeId', isEqualTo: routeId)
        .where('status', whereIn: ['online', 'idle'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return _busFromFirestore(doc);
      }).toList();
    });
  }

  /// Get active buses for a specific route (alias for watchBusesByRoute)
  Stream<List<BusModel>> getActiveBusesForRoute(String routeId) {
    return watchBusesByRoute(routeId);
  }

  /// Get single bus by ID
  Future<BusModel?> getBusById(String busId) async {
    try {
      final doc = await busesCollection.doc(busId).get();
      if (doc.exists) {
        return _busFromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting bus: $e');
      return null;
    }
  }

  /// Update bus location (for drivers)
  Future<void> updateBusLocation({
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

  /// Update bus status
  Future<void> updateBusStatus(String busId, BusStatus status) async {
    await busesCollection.doc(busId).update({
      'status': status.name,
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

  /// Stream of all routes
  Stream<List<BusRouteModel>> watchRoutes() {
    return routesCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return _routeFromFirestore(doc);
      }).toList();
    });
  }

  /// Get route by ID
  Future<BusRouteModel?> getRouteById(String routeId) async {
    try {
      final doc = await routesCollection.doc(routeId).get();
      if (doc.exists) {
        return _routeFromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting route: $e');
      return null;
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

  /// Convert Firestore document to BusRouteModel
  BusRouteModel _routeFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse stops
    final stopsData = data['stops'] as List<dynamic>? ?? [];
    final stops = stopsData.map((stop) {
      final stopMap = stop as Map<String, dynamic>;
      final position = stopMap['position'] as GeoPoint?;
      return RouteStop(
        id: stopMap['id'] as String? ?? '',
        name: stopMap['name'] as String? ?? '',
        position: position != null
            ? LatLng(position.latitude, position.longitude)
            : const LatLng(0, 0),
        orderIndex: stopMap['orderIndex'] as int? ?? 0,
        estimatedTime: stopMap['estimatedTime'] as String?,
      );
    }).toList();

    // Parse polyline
    final polylineData = data['polyline'] as List<dynamic>? ?? [];
    final polyline = polylineData.map((point) {
      final pointMap = point as Map<String, dynamic>;
      return LatLng(
        (pointMap['latitude'] as num?)?.toDouble() ?? 0.0,
        (pointMap['longitude'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    return BusRouteModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      stops: stops,
      polyline: polyline,
      distance: data['distance'] as String? ?? '',
      duration: data['duration'] as String? ?? '',
      fare: (data['fare'] as num?)?.toDouble() ?? 0.0,
      activeBuses: data['activeBuses'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
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

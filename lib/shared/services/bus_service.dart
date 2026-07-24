import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';
import '../models/bus_model.dart';

/// Service for managing bus data
/// Uses Firestore for bus metadata (assignments, routes, capacity)
/// Uses RTDB for real-time location tracking
class BusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Collection references for Firestore
  CollectionReference get busesCollection => _firestore.collection('buses');
  CollectionReference get routesCollection => _firestore.collection('routes');
  
  /// Database references for RTDB
  DatabaseReference get locationsRef => _database.ref('locations');

  /// Stream of all active buses with real-time location
  /// Combines Firestore metadata with RTDB location
  Stream<List<BusModel>> watchActiveBuses() {
    return busesCollection
        .where('status', whereIn: ['online', 'idle'])
        .snapshots()
        .asyncMap((snapshot) async {
      final buses = <BusModel>[];
      
      for (var doc in snapshot.docs) {
        final bus = await _busFromFirestoreWithLocation(doc);
        buses.add(bus);
      }
      
      return buses;
    });
  }

  /// Stream of buses by route with real-time location
  Stream<List<BusModel>> watchBusesByRoute(String routeId) {
    return busesCollection
        .where('routeId', isEqualTo: routeId)
        .where('status', whereIn: ['online', 'idle'])
        .snapshots()
        .asyncMap((snapshot) async {
      final buses = <BusModel>[];
      
      for (var doc in snapshot.docs) {
        final bus = await _busFromFirestoreWithLocation(doc);
        buses.add(bus);
      }
      
      return buses;
    });
  }

  /// Get active buses for a specific route (alias for watchBusesByRoute)
  Stream<List<BusModel>> getActiveBusesForRoute(String routeId) {
    return watchBusesByRoute(routeId);
  }

  /// Get single bus by ID with real-time location
  Future<BusModel?> getBusById(String busId) async {
    try {
      final doc = await busesCollection.doc(busId).get();
      if (doc.exists) {
        return await _busFromFirestoreWithLocation(doc);
      }
      return null;
    } catch (e) {
      print('Error getting bus: $e');
      return null;
    }
  }

  /// Update bus status in Firestore
  Future<void> updateBusStatus(String busId, BusStatus status) async {
    await busesCollection.doc(busId).update({
      'status': status.name,
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

  /// Stream of all routes from Firestore
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

  /// Get route by ID from Firestore
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

  /// Convert Firestore bus document to BusModel with RTDB location
  Future<BusModel> _busFromFirestoreWithLocation(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final lastUpdated = data['lastUpdated'] as Timestamp?;
    final routeId = data['routeId'] as String?;

    // Fetch route name from routes collection if routeId exists
    String routeName = data['routeName'] as String? ?? 'Unknown Route';
    if (routeId != null && routeId.isNotEmpty) {
      try {
        final routeDoc = await routesCollection.doc(routeId).get();
        if (routeDoc.exists) {
          final routeData = routeDoc.data() as Map<String, dynamic>;
          routeName = routeData['name'] as String? ?? routeName;
        }
      } catch (e) {
        print('Warning: Could not fetch route name: $e');
      }
    }

    // Get real-time location from RTDB
    LatLng position = const LatLng(8.2280, 123.3317);
    double speed = 0.0;
    double heading = 0.0;
    
    try {
      final locationSnapshot = await locationsRef.child(doc.id).get();
      if (locationSnapshot.exists && locationSnapshot.value != null) {
        final locationData = Map<String, dynamic>.from(locationSnapshot.value as Map);
        final lat = (locationData['latitude'] as num?)?.toDouble() ?? 8.2280;
        final lng = (locationData['longitude'] as num?)?.toDouble() ?? 123.3317;
        position = LatLng(lat, lng);
        speed = (locationData['speed'] as num?)?.toDouble() ?? 0.0;
        heading = (locationData['heading'] as num?)?.toDouble() ?? 0.0;
      }
    } catch (e) {
      print('Warning: Could not fetch location for bus ${doc.id}: $e');
      // Fallback to Firestore position if available
      if (data.containsKey('position')) {
        final geoPoint = data['position'] as GeoPoint?;
        if (geoPoint != null) {
          position = LatLng(geoPoint.latitude, geoPoint.longitude);
        }
      }
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
      speed: speed,
      passengerCount: data['passengerCount'] as int? ?? 0,
      capacity: data['capacity'] as int? ?? 50,
      lastUpdated: lastUpdated?.toDate() ?? DateTime.now(),
      heading: heading,
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

/// Utility to seed Firestore with initial route data
/// Run this once to populate the database
class FirestoreSeed {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seed the Dipolog-Dapitan route to Firestore
  Future<void> seedRoute() async {
    try {
      print('🌱 Seeding route to Firestore...');

      // Create the route document
      final routeRef = _firestore.collection('routes').doc('route001');
      
      await routeRef.set({
        'name': 'Dipolog ↔ Dapitan',
        'description': 'Via Minaog, Lawa-an, Polo, San Pedro, Owawon, Larayan, Upper Sicayab, and Sicayab',
        'distance': '53 km',
        'duration': '1h 30min',
        'fare': 0,
        'activeBuses': 0,
        'isActive': true,
        'stops': [
          {
            'id': 's1',
            'name': 'Dipolog',
            'position': GeoPoint(8.5834, 123.3417),
            'orderIndex': 0,
            'estimatedTime': null,
          },
          {
            'id': 's2',
            'name': 'Minaog',
            'position': GeoPoint(8.6050, 123.3650),
            'orderIndex': 1,
            'estimatedTime': null,
          },
          {
            'id': 's3',
            'name': 'Lawa-an',
            'position': GeoPoint(8.6250, 123.3850),
            'orderIndex': 2,
            'estimatedTime': null,
          },
          {
            'id': 's4',
            'name': 'Polo',
            'position': GeoPoint(8.6450, 123.4050),
            'orderIndex': 3,
            'estimatedTime': null,
          },
          {
            'id': 's5',
            'name': 'San Pedro',
            'position': GeoPoint(8.6650, 123.4250),
            'orderIndex': 4,
            'estimatedTime': null,
          },
          {
            'id': 's6',
            'name': 'Owawon',
            'position': GeoPoint(8.6850, 123.4450),
            'orderIndex': 5,
            'estimatedTime': null,
          },
          {
            'id': 's7',
            'name': 'Larayan',
            'position': GeoPoint(8.7050, 123.4650),
            'orderIndex': 6,
            'estimatedTime': null,
          },
          {
            'id': 's8',
            'name': 'Upper Sicayab',
            'position': GeoPoint(8.7250, 123.4850),
            'orderIndex': 7,
            'estimatedTime': null,
          },
          {
            'id': 's9',
            'name': 'Sicayab',
            'position': GeoPoint(8.7450, 123.5050),
            'orderIndex': 8,
            'estimatedTime': null,
          },
          {
            'id': 's10',
            'name': 'Dapitan',
            'position': GeoPoint(8.6500, 123.4242),
            'orderIndex': 9,
            'estimatedTime': null,
          },
        ],
        'polyline': [
          {'latitude': 8.5834, 'longitude': 123.3417},
          {'latitude': 8.6050, 'longitude': 123.3650},
          {'latitude': 8.6250, 'longitude': 123.3850},
          {'latitude': 8.6450, 'longitude': 123.4050},
          {'latitude': 8.6650, 'longitude': 123.4250},
          {'latitude': 8.6850, 'longitude': 123.4450},
          {'latitude': 8.7050, 'longitude': 123.4650},
          {'latitude': 8.7250, 'longitude': 123.4850},
          {'latitude': 8.7450, 'longitude': 123.5050},
          {'latitude': 8.6500, 'longitude': 123.4242},
        ],
      });

      print('✅ Route seeded successfully: route001');
    } catch (e) {
      print('❌ Error seeding route: $e');
      rethrow;
    }
  }

  /// Seed sample buses with the given driver user IDs
  /// Call this with actual driver UIDs from Firebase Authentication
  Future<void> seedBuses({
    required String driver1Id,
    required String driver2Id,
    required String driver3Id,
  }) async {
    try {
      print('🚌 Seeding buses to Firestore...');

      final batch = _firestore.batch();

      // Bus 1
      final bus1Ref = _firestore.collection('buses').doc('bus001');
      batch.set(bus1Ref, {
        'busNumber': 'EG-001',
        'plateNumber': 'ABC 1234',
        'driverId': driver1Id,
        'driverName': 'Juan dela Cruz',
        'routeId': 'route001',
        'routeName': 'Dipolog ↔ Dapitan',
        'status': 'idle',
        'passengerCount': 0,
        'capacity': 50,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Bus 2
      final bus2Ref = _firestore.collection('buses').doc('bus002');
      batch.set(bus2Ref, {
        'busNumber': 'EG-002',
        'plateNumber': 'DEF 5678',
        'driverId': driver2Id,
        'driverName': 'Pedro Reyes',
        'routeId': 'route001',
        'routeName': 'Dipolog ↔ Dapitan',
        'status': 'idle',
        'passengerCount': 0,
        'capacity': 50,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Bus 3
      final bus3Ref = _firestore.collection('buses').doc('bus003');
      batch.set(bus3Ref, {
        'busNumber': 'EG-003',
        'plateNumber': 'GHI 9012',
        'driverId': driver3Id,
        'driverName': 'Carlos Mendoza',
        'routeId': 'route001',
        'routeName': 'Dipolog ↔ Dapitan',
        'status': 'idle',
        'passengerCount': 0,
        'capacity': 50,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      print('✅ Buses seeded successfully:');
      print('   - bus001 (EG-001) → Driver: $driver1Id');
      print('   - bus002 (EG-002) → Driver: $driver2Id');
      print('   - bus003 (EG-003) → Driver: $driver3Id');
    } catch (e) {
      print('❌ Error seeding buses: $e');
      rethrow;
    }
  }

  /// Check if route already exists
  Future<bool> routeExists() async {
    final doc = await _firestore.collection('routes').doc('route001').get();
    return doc.exists;
  }

  /// Check if buses already exist
  Future<bool> busesExist() async {
    final snapshot = await _firestore
        .collection('buses')
        .where('routeId', isEqualTo: 'route001')
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Seed everything at once
  Future<void> seedAll({
    String? driver1Id,
    String? driver2Id,
    String? driver3Id,
  }) async {
    print('\n🌱 Starting Firestore Seed...\n');

    // Seed route
    if (await routeExists()) {
      print('ℹ️  Route already exists, skipping...');
    } else {
      await seedRoute();
    }

    // Seed buses (only if driver IDs provided)
    if (driver1Id != null && driver2Id != null && driver3Id != null) {
      if (await busesExist()) {
        print('ℹ️  Buses already exist, skipping...');
      } else {
        await seedBuses(
          driver1Id: driver1Id,
          driver2Id: driver2Id,
          driver3Id: driver3Id,
        );
      }
    } else {
      print('\n⚠️  Skipping bus seeding - driver IDs not provided');
      print('   To seed buses, provide driver UIDs from Firebase Authentication');
      print('   Example: seedAll(driver1Id: "abc123", driver2Id: "xyz789", ...)');
    }

    print('\n✅ Firestore seed complete!\n');
  }
}

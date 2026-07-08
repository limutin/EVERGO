import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';
import 'firebase_service.dart';

/// Unified service for trip/schedule management
/// Used by both commuters and drivers
class TripService extends FirebaseService {
  CollectionReference get tripsCollection => firestore.collection('trips');

  /// Watch all active trips (for commuters)
  Stream<List<TripModel>> watchActiveTrips() {
    return tripsCollection
        .where('status', whereIn: ['scheduled', 'in_progress'])
        .orderBy('departureTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TripModel.fromFirestore(doc);
      }).toList();
    });
  }

  /// Watch trips for a specific route (for commuters)
  Stream<List<TripModel>> watchRouteTrips(String routeId) {
    return tripsCollection
        .where('routeId', isEqualTo: routeId)
        .where('status', whereIn: ['scheduled', 'in_progress'])
        .orderBy('departureTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TripModel.fromFirestore(doc);
      }).toList();
    });
  }

  /// Watch driver's trips (for drivers)
  Stream<List<TripModel>> watchDriverTrips(String driverId) {
    return tripsCollection
        .where('driverId', isEqualTo: driverId)
        .orderBy('departureTime', descending: false)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TripModel.fromFirestore(doc);
      }).toList();
    });
  }

  /// Watch today's driver trips
  Stream<List<TripModel>> watchTodayDriverTrips(String driverId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return tripsCollection
        .where('driverId', isEqualTo: driverId)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('createdAt')
        .orderBy('departureTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TripModel.fromFirestore(doc);
      }).toList();
    });
  }

  /// Get active trip for a specific bus
  Stream<TripModel?> watchBusActiveTrip(String busId) {
    return tripsCollection
        .where('busId', isEqualTo: busId)
        .where('status', isEqualTo: 'in_progress')
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return TripModel.fromFirestore(snapshot.docs.first);
    });
  }

  /// Create a new trip (admin/driver)
  Future<String> createTrip(TripModel trip) async {
    final docRef = await tripsCollection.add(trip.toFirestore());
    return docRef.id;
  }

  /// Start a trip (driver)
  Future<void> startTrip(String tripId) async {
    await tripsCollection.doc(tripId).update({
      'status': 'in_progress',
      'startedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Complete a trip (driver)
  Future<void> completeTrip(String tripId) async {
    await tripsCollection.doc(tripId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update trip progress (driver updates stop)
  Future<void> updateTripProgress(String tripId, int stopIndex) async {
    await tripsCollection.doc(tripId).update({
      'currentStopIndex': stopIndex,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update passenger count on trip
  Future<void> updateTripPassengerCount(String tripId, int count) async {
    await tripsCollection.doc(tripId).update({
      'passengerCount': count,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cancel a trip
  Future<void> cancelTrip(String tripId) async {
    await tripsCollection.doc(tripId).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get trip by ID
  Future<TripModel?> getTripById(String tripId) async {
    final doc = await tripsCollection.doc(tripId).get();
    if (!doc.exists) return null;
    return TripModel.fromFirestore(doc);
  }

  /// Get today's stats for a driver
  Future<Map<String, dynamic>> getTodayStats(String driverId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      final snapshot = await tripsCollection
          .where('driverId', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      int completedTrips = 0;
      int scheduledTrips = 0;
      int inProgressTrips = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String?;

        switch (status) {
          case 'completed':
            completedTrips++;
            break;
          case 'in_progress':
            inProgressTrips++;
            break;
          case 'scheduled':
            scheduledTrips++;
            break;
        }
      }

      return {
        'completedTrips': completedTrips,
        'scheduledTrips': scheduledTrips,
        'inProgressTrips': inProgressTrips,
        'totalTrips': snapshot.docs.length,
      };
    } catch (e) {
      print('Error getting today stats: $e');
      return {
        'completedTrips': 0,
        'scheduledTrips': 0,
        'inProgressTrips': 0,
        'totalTrips': 0,
      };
    }
  }
}

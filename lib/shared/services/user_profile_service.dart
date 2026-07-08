import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for user profile statistics
class UserProfileStats {
  final int tripsTaken;
  final int savedRoutes;
  final DateTime memberSince;

  UserProfileStats({
    required this.tripsTaken,
    required this.savedRoutes,
    required this.memberSince,
  });

  factory UserProfileStats.fromFirestore(Map<String, dynamic> data) {
    return UserProfileStats(
      tripsTaken: data['tripsTaken'] ?? 0,
      savedRoutes: data['savedRoutes'] ?? 0,
      memberSince: data['memberSince'] != null
          ? (data['memberSince'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tripsTaken': tripsTaken,
      'savedRoutes': savedRoutes,
      'memberSince': Timestamp.fromDate(memberSince),
    };
  }

  /// Mock data for fallback
  static UserProfileStats get mock => UserProfileStats(
        tripsTaken: 48,
        savedRoutes: 3,
        memberSince: DateTime(2024, 3, 1),
      );
}

/// Service to manage user profile data
class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user profile stats
  Future<UserProfileStats> getUserStats(String userId) async {
    try {
      print('📊 Fetching user stats for: $userId');
      
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        print('⚠️ User document does not exist, creating with default stats');
        // Create user document with default stats
        final defaultStats = UserProfileStats(
          tripsTaken: 0,
          savedRoutes: 0,
          memberSince: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(userId).set({
          'stats': defaultStats.toFirestore(),
          'savedRoutes': [],
          'updatedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        print('✅ Created default stats for user');
        return defaultStats;
      }

      final data = doc.data();
      print('📦 User document data: $data');
      
      if (data != null && data['stats'] != null) {
        final stats = UserProfileStats.fromFirestore(data['stats']);
        print('✅ Loaded stats: trips=${stats.tripsTaken}, routes=${stats.savedRoutes}');
        return stats;
      }

      // Initialize stats if they don't exist
      print('⚠️ Stats field missing, initializing');
      final defaultStats = UserProfileStats(
        tripsTaken: 0,
        savedRoutes: 0,
        memberSince: data?['createdAt'] != null 
            ? (data!['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
      
      await _firestore.collection('users').doc(userId).update({
        'stats': defaultStats.toFirestore(),
      });
      
      return defaultStats;
    } catch (e) {
      print('❌ Error fetching user stats: $e');
      return UserProfileStats.mock;
    }
  }

  /// Stream user profile stats for real-time updates
  Stream<UserProfileStats> watchUserStats(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return UserProfileStats.mock;
      }

      final data = snapshot.data();
      if (data != null && data['stats'] != null) {
        return UserProfileStats.fromFirestore(data['stats']);
      }

      return UserProfileStats.mock;
    }).handleError((error) {
      print('Error watching user stats: $error');
      return UserProfileStats.mock;
    });
  }

  /// Increment trips taken counter
  Future<void> incrementTrips(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'stats': {
          'tripsTaken': FieldValue.increment(1),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error incrementing trips: $e');
    }
  }

  /// Add a saved route
  Future<void> addSavedRoute(String userId, String routeId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'savedRoutes': FieldValue.arrayUnion([routeId]),
        'stats': {
          'savedRoutes': FieldValue.increment(1),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding saved route: $e');
    }
  }

  /// Remove a saved route
  Future<void> removeSavedRoute(String userId, String routeId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'savedRoutes': FieldValue.arrayRemove([routeId]),
        'stats': {
          'savedRoutes': FieldValue.increment(-1),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error removing saved route: $e');
    }
  }

  /// Get saved routes list
  Future<List<String>> getSavedRoutes(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return [];

      final data = doc.data();
      if (data != null && data['savedRoutes'] != null) {
        return List<String>.from(data['savedRoutes']);
      }

      return [];
    } catch (e) {
      print('Error fetching saved routes: $e');
      return [];
    }
  }
}

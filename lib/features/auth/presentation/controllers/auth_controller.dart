import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../shared/models/user_model.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoggedIn = false.obs;
  final Rx<UserRole?> selectedRole = Rx<UserRole?>(null);

  @override
  void onInit() {
    super.onInit();
    _listenToAuthState();
  }

  /// Listen to Firebase auth state changes and auto-restore session.
  void _listenToAuthState() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserFromFirestore(user.uid);
        isLoggedIn.value = true;
      } else {
        currentUser.value = null;
        isLoggedIn.value = false;
      }
    });
  }

  /// Load user document from Firestore and populate [currentUser].
  Future<void> _loadUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final role = UserRole.values.firstWhere(
          (r) => r.name == (data['role'] as String? ?? 'commuter'),
          orElse: () => UserRole.commuter,
        );
        currentUser.value = UserModel(
          id: uid,
          name: data['name'] as String? ?? '',
          email: data['email'] as String? ?? '',
          phone: data['phone'] as String?,
          role: role,
          isVerified: _auth.currentUser?.emailVerified ?? false,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
        selectedRole.value = role;
      }
    } catch (e) {
      // Firestore read failure – session still valid via Firebase Auth
    }
  }

  void setRole(UserRole role) {
    selectedRole.value = role;
  }

  /// Sign in with email + password using Firebase Authentication.
  Future<bool> login({required String email, required String password}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _loadUserFromFirestore(credential.user!.uid);
      isLoggedIn.value = true;
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _mapAuthError(e.code);
      return false;
    } catch (e) {
      errorMessage.value = 'Login failed. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a new account with Firebase Auth and save profile to Firestore.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? busNumber,
    String? plateNumber,
    String? routeId,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final role = selectedRole.value ?? UserRole.commuter;

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update Firebase display name
      await credential.user!.updateDisplayName(name.trim());

      final uid = credential.user!.uid;
      final now = DateTime.now();

      // Save user profile to Firestore
      final userData = {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'role': role.name,
        'isVerified': false,
        'createdAt': Timestamp.fromDate(now),
      };

      // Add driver-specific fields if driver role
      if (role == UserRole.driver && busNumber != null && plateNumber != null && routeId != null) {
        userData['busNumber'] = busNumber.trim();
        userData['plateNumber'] = plateNumber.trim();
        userData['routeId'] = routeId;
        
        // Create initial bus document
        await _firestore.collection('buses').doc(uid).set({
          'driverId': uid,
          'driverName': name.trim(),
          'busNumber': busNumber.trim(),
          'plateNumber': plateNumber.trim(),
          'routeId': routeId,
          'status': 'offline',
          'passengerCount': 0,
          'capacity': 50,
          'speed': 0.0,
          'heading': 0.0,
          'latitude': 8.2280, // Default Dipolog coordinates
          'longitude': 123.3317,
          'lastUpdated': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await _firestore.collection('users').doc(uid).set(userData);

      currentUser.value = UserModel(
        id: uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        role: role,
        createdAt: now,
      );
      isLoggedIn.value = true;
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _mapAuthError(e.code);
      return false;
    } catch (e) {
      errorMessage.value = 'Registration failed. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Send a password-reset email via Firebase Auth.
  Future<bool> forgotPassword({required String email}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _mapAuthError(e.code);
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to send reset link.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign out from Firebase.
  Future<void> logout() async {
    await _auth.signOut();
    currentUser.value = null;
    selectedRole.value = null;
    isLoggedIn.value = false;
  }

  /// Update user profile (name, phone, license number)
  Future<bool> updateProfile({
    required String name,
    String? phone,
    String? licenseNumber,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'No user logged in';
        return false;
      }

      final uid = user.uid;

      // Update Firestore user document
      final updateData = <String, dynamic>{
        'name': name.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (phone != null && phone.isNotEmpty) {
        updateData['phone'] = phone.trim();
      }

      if (licenseNumber != null && licenseNumber.isNotEmpty) {
        updateData['licenseNumber'] = licenseNumber.trim();
      }

      await _firestore.collection('users').doc(uid).update(updateData);

      // Update Firebase Auth display name
      await user.updateDisplayName(name.trim());

      // Update local state
      if (currentUser.value != null) {
        currentUser.value = currentUser.value!.copyWith(
          name: name.trim(),
          phone: phone?.trim(),
          licenseNumber: licenseNumber?.trim(),
        );
      }

      print('✅ Profile updated successfully');
      return true;
    } on FirebaseException catch (e) {
      errorMessage.value = 'Failed to update profile: ${e.message}';
      print('❌ Profile update error: ${e.message}');
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to update profile';
      print('❌ Profile update error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Change user password (requires current password for re-authentication)
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        errorMessage.value = 'No user logged in';
        return false;
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      print('✅ Password changed successfully');
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        errorMessage.value = 'Current password is incorrect';
      } else if (e.code == 'weak-password') {
        errorMessage.value = 'New password must be at least 6 characters';
      } else if (e.code == 'requires-recent-login') {
        errorMessage.value = 'Please log out and log in again before changing password';
      } else {
        errorMessage.value = _mapAuthError(e.code);
      }
      print('❌ Password change error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to change password';
      print('❌ Password change error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

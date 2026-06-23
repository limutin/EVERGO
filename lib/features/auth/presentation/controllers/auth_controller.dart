import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/models/user_model.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoggedIn = false.obs;
  final Rx<UserRole?> selectedRole = Rx<UserRole?>(null);

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role');
    if (role != null) {
      isLoggedIn.value = true;
      selectedRole.value =
          UserRole.values.firstWhere((r) => r.name == role, orElse: () => UserRole.commuter);
      // Mock: load mock user
      if (selectedRole.value == UserRole.commuter) {
        currentUser.value = UserModel.mockCommuter;
      } else {
        currentUser.value = UserModel.mockDriver;
      }
    }
  }

  void setRole(UserRole role) {
    selectedRole.value = role;
  }

  Future<bool> login({required String email, required String password}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock login logic
      if (email.isNotEmpty && password.length >= 6) {
        final role = selectedRole.value ?? UserRole.commuter;
        currentUser.value =
            role == UserRole.commuter ? UserModel.mockCommuter : UserModel.mockDriver;
        isLoggedIn.value = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', role.name);
        return true;
      } else {
        errorMessage.value = 'Invalid email or password';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Login failed. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await Future.delayed(const Duration(seconds: 2));
      final role = selectedRole.value ?? UserRole.commuter;
      currentUser.value = UserModel(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );
      isLoggedIn.value = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', role.name);
      return true;
    } catch (e) {
      errorMessage.value = 'Registration failed. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to send reset link.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoggedIn.value = false;
    currentUser.value = null;
    selectedRole.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
  }
}

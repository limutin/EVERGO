import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/bus_model.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  // Driver-specific fields
  final _busNumberCtrl = TextEditingController();
  final _plateNumberCtrl = TextEditingController();
  final _authCtrl = Get.find<AuthController>();
  bool _agreedToTerms = false;
  String? _selectedRoute;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _busNumberCtrl.dispose();
    _plateNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Enable live validation after first attempt
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });
    
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      Get.snackbar(
        'Terms Required',
        'Please agree to the Terms of Service to continue.',
        backgroundColor: AppColors.cardDark2,
        colorText: AppColors.textPrimary,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    final role = _authCtrl.selectedRole.value;
    final isDriver = role?.name == 'driver';
    
    // Validate driver-specific fields
    if (isDriver) {
      if (_busNumberCtrl.text.trim().isEmpty) {
        Get.snackbar(
          'Bus Number Required',
          'Please enter your bus number.',
          backgroundColor: AppColors.cardDark2,
          colorText: AppColors.textPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (_plateNumberCtrl.text.trim().isEmpty) {
        Get.snackbar(
          'Plate Number Required',
          'Please enter the bus plate number.',
          backgroundColor: AppColors.cardDark2,
          colorText: AppColors.textPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (_selectedRoute == null) {
        Get.snackbar(
          'Route Required',
          'Please select your assigned route.',
          backgroundColor: AppColors.cardDark2,
          colorText: AppColors.textPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }
    
    final success = await _authCtrl.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      phone: _phoneCtrl.text.trim(),
      busNumber: isDriver ? _busNumberCtrl.text.trim() : null,
      plateNumber: isDriver ? _plateNumberCtrl.text.trim() : null,
      routeId: isDriver ? _selectedRoute : null,
    );
    if (success && mounted) {
      if (isDriver) {
        context.go(RouteNames.driverDashboard);
      } else {
        context.go(RouteNames.commuterDashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = _authCtrl.selectedRole.value;
    final isDriver = role?.name == 'driver';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: isDriver
                    ? AppColors.accentGradient
                    : AppColors.primaryGradient,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.pagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(
                           Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => context.pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                      // App logo
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/icons/logo.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Create Account',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isDriver
                            ? 'Join as a bus driver'
                            : 'Start tracking buses today',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidateMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      controller: _nameCtrl,
                      validator: Validators.name,
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Email Address',
                      hint: 'you@example.com',
                      controller: _emailCtrl,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Phone Number',
                      hint: '+63 9XX XXX XXXX',
                      controller: _phoneCtrl,
                      validator: Validators.phoneNumber,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    
                    // Driver-specific fields
                    if (isDriver) ...[
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Bus Number',
                        hint: 'e.g. EG-001',
                        controller: _busNumberCtrl,
                        validator: Validators.busNumber,
                        prefixIcon: Icons.directions_bus_outlined,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Plate Number',
                        hint: 'e.g. ABC 1234',
                        controller: _plateNumberCtrl,
                        validator: Validators.plateNumber,
                        prefixIcon: Icons.pin_outlined,
                      ),
                      const SizedBox(height: 20),
                      // Route Selection Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assigned Route',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark2,
                              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                              border: Border.all(color: AppColors.dividerDark),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedRoute,
                                isExpanded: true,
                                hint: Text(
                                  'Select your route',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                dropdownColor: AppColors.cardDark,
                                icon: const Icon(Icons.arrow_drop_down_rounded,
                                    color: AppColors.textSecondary),
                                items: BusRouteModel.mockRoutes.map((route) {
                                  return DropdownMenuItem<String>(
                                    value: route.id,
                                    child: Row(
                                      children: [
                                        Icon(Icons.route_rounded,
                                            size: 16, color: AppColors.accent),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                route.name,
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              Text(
                                                '${route.distance} • ${route.duration}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedRoute = value);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Password',
                      hint: 'At least 6 characters',
                      controller: _passwordCtrl,
                      validator: Validators.password,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline_rounded,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      controller: _confirmPasswordCtrl,
                      validator: (v) => Validators.confirmPassword(
                          v, _passwordCtrl.text),
                      obscureText: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 20),

                    // Terms Agreement
                    Row(
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          onChanged: (v) =>
                              setState(() => _agreedToTerms = v!),
                          activeColor: AppColors.primary,
                          side: const BorderSide(
                              color: AppColors.textMuted, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              children: const [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Error
                    Obx(() {
                      if (_authCtrl.errorMessage.value.isNotEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            _authCtrl.errorMessage.value,
                            style: GoogleFonts.inter(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    Obx(
                      () => PrimaryButton(
                        label: 'Create Account',
                        isLoading: _authCtrl.isLoading.value,
                        onPressed: _register,
                        gradient: isDriver
                            ? AppColors.accentGradient
                            : AppColors.primaryGradient,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            const TextSpan(
                                text: 'Already have an account? '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => context.pop(),
                                child: Text(
                                  'Sign In',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class DriverEditProfileScreen extends StatefulWidget {
  const DriverEditProfileScreen({super.key});

  @override
  State<DriverEditProfileScreen> createState() =>
      _DriverEditProfileScreenState();
}

class _DriverEditProfileScreenState extends State<DriverEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _authController = Get.find<AuthController>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = _authController.currentUser.value;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _licenseController.text = user.licenseNumber ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _authController.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        licenseNumber: _licenseController.text.trim(),
      );

      if (mounted) {
        if (success) {
          Get.back();
          // Show success message using native Flutter dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.backgroundDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Success',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Profile updated successfully',
                style: GoogleFonts.inter(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'OK',
                    style: GoogleFonts.inter(color: AppColors.accent),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Show error message using native Flutter dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.backgroundDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              title: Row(
                children: [
                  Icon(Icons.error, color: AppColors.error, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Error',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              content: Text(
                _authController.errorMessage.value.isEmpty
                    ? 'Failed to update profile'
                    : _authController.errorMessage.value,
                style: GoogleFonts.inter(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'OK',
                    style: GoogleFonts.inter(color: AppColors.accent),
                  ),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.backgroundDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            title: Row(
              children: [
                Icon(Icons.error, color: AppColors.error, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Error',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Text(
              'Failed to update profile: $e',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: GoogleFonts.inter(color: AppColors.accent),
                ),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),
              
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.accentGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text.split(' ').take(2).map((w) => w[0]).join().toUpperCase()
                            : 'JD',
                        style: GoogleFonts.inter(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.backgroundDark, width: 3),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),

              // Driver Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.drive_eta_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Verified Driver',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Name Field
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                prefixIcon: Icons.person_rounded,
                validator: Validators.name,
              ),
              
              const SizedBox(height: 16),

              // Phone Field
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter your phone number',
                prefixIcon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: Validators.phoneNumber,
              ),

              const SizedBox(height: 16),

              // License Number Field
              CustomTextField(
                controller: _licenseController,
                label: "Driver's License Number",
                hint: 'Enter your license number',
                prefixIcon: Icons.credit_card_rounded,
                validator: Validators.licenseNumber,
              ),

              const SizedBox(height: 16),

              // Email (read-only)
              Obx(() {
                final emailController = TextEditingController(
                  text: _authController.currentUser.value?.email ?? '',
                );
                return CustomTextField(
                  controller: emailController,
                  label: 'Email',
                  hint: 'Email',
                  prefixIcon: Icons.email_rounded,
                  enabled: false,
                );
              }),

              const SizedBox(height: 32),

              // Save Button
              PrimaryButton(
                label: 'Save Changes',
                onPressed: _saveProfile,
                isLoading: _isLoading,
                gradient: AppColors.accentGradient,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class CommuterEditProfileScreen extends StatefulWidget {
  const CommuterEditProfileScreen({super.key});

  @override
  State<CommuterEditProfileScreen> createState() => _CommuterEditProfileScreenState();
}

class _CommuterEditProfileScreenState extends State<CommuterEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _isLoading = false.obs;
  final _authCtrl = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authCtrl.currentUser.value;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;

    try {
      final userId = _authCtrl.currentUser.value?.id;
      if (userId == null) return;

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local user model
      final updatedUser = _authCtrl.currentUser.value?.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      _authCtrl.currentUser.value = updatedUser;

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      Navigator.of(context).pop();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(_nameController.text),
                          style: GoogleFonts.inter(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
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
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.backgroundDark,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              CustomTextField(
                label: 'Full Name',
                controller: _nameController,
                hint: 'Enter your full name',
                prefixIcon: Icons.person_outline_rounded,
                validator: Validators.required,
              ),
              const SizedBox(height: 20),

              // Phone Field
              CustomTextField(
                label: 'Phone Number',
                controller: _phoneController,
                hint: '+63 912 345 6789',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.required,
              ),
              const SizedBox(height: 20),

              // Email (Read-only)
              Text(
                'Email Address',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.dividerDark),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _authCtrl.currentUser.value?.email ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Email cannot be changed',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              Obx(() => PrimaryButton(
                    label: 'Save Changes',
                    onPressed: _saveProfile,
                    isLoading: _isLoading.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

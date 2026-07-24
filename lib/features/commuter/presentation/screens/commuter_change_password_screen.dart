import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class CommuterChangePasswordScreen extends StatefulWidget {
  const CommuterChangePasswordScreen({super.key});

  @override
  State<CommuterChangePasswordScreen> createState() => _CommuterChangePasswordScreenState();
}

class _CommuterChangePasswordScreenState extends State<CommuterChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authController = Get.find<AuthController>();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _authController.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          // Show success message
          _showSuccessDialog();
        } else {
          // Show error message
          _showErrorDialog(_authController.errorMessage.value.isEmpty
              ? 'Failed to change password'
              : _authController.errorMessage.value);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to change password: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 24),
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
            'Password changed successfully',
            style: GoogleFonts.inter(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.inter(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          title: Row(
            children: [
              const Icon(Icons.error, color: AppColors.error, size: 24),
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
            message,
            style: GoogleFonts.inter(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.inter(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: Text(
          'Change Password',
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
              
              // Info Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your new password must be at least 6 characters long',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Current Password
              CustomTextField(
                label: 'Current Password',
                controller: _currentPasswordController,
                hint: 'Enter current password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                validator: Validators.required,
              ),
              const SizedBox(height: 20),

              // New Password
              CustomTextField(
                label: 'New Password',
                controller: _newPasswordController,
                hint: 'Enter new password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                validator: Validators.password,
              ),
              const SizedBox(height: 20),

              // Confirm New Password
              CustomTextField(
                label: 'Confirm New Password',
                controller: _confirmPasswordController,
                hint: 'Re-enter new password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Change Password Button
              PrimaryButton(
                label: 'Change Password',
                onPressed: _changePassword,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

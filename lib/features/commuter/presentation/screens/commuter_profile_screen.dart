import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../shared/services/user_profile_service.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'package:get/get.dart' hide Trans;
import 'commuter_edit_profile_screen.dart';
import 'commuter_change_password_screen.dart';

class CommuterProfileScreen extends StatefulWidget {
  const CommuterProfileScreen({super.key});

  @override
  State<CommuterProfileScreen> createState() => _CommuterProfileScreenState();
}

class _CommuterProfileScreenState extends State<CommuterProfileScreen> {
  final _profileService = UserProfileService();
  UserProfileStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final authCtrl = Get.find<AuthController>();
    final userId = authCtrl.currentUser.value?.id;

    print('👤 Loading profile stats for user: $userId');

    if (userId != null) {
      try {
        final stats = await _profileService.getUserStats(userId);
        print('✅ Stats loaded successfully: ${stats.tripsTaken} trips, ${stats.savedRoutes} routes');
        if (mounted) {
          setState(() {
            _stats = stats;
            _isLoading = false;
          });
        }
      } catch (e) {
        print('❌ Error loading stats: $e');
        if (mounted) {
          setState(() {
            _stats = UserProfileStats.mock;
            _isLoading = false;
          });
        }
      }
    } else {
      print('⚠️ No user ID available, using mock data');
      if (mounted) {
        setState(() {
          _stats = UserProfileStats.mock;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final user = authCtrl.currentUser.value;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePadding),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Avatar & Info
              Obx(() {
                final user = authCtrl.currentUser.value;
                return _ProfileAvatar(
                  name: user?.name ?? 'Commuter',
                  avatarUrl: user?.avatarUrl,
                );
              }),
              const SizedBox(height: 16),
              Text(
                user?.name ?? 'Maria Santos',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'commuter@example.com',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              // Verification badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded,
                        color: AppColors.success, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      'Verified Account',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats - Real data from Firebase
              _isLoading
                  ? const SkeletonProfileStats()
                  : Row(
                      children: [
                        _ProfileStat(
                          label: 'Trips Taken',
                          value: '${_stats?.tripsTaken ?? 0}',
                        ),
                        _ProfileStat(
                          label: 'Saved Routes',
                          value: '${_stats?.savedRoutes ?? 0}',
                        ),
                        _ProfileStat(
                          label: 'Member Since',
                          value: _stats != null
                              ? DateFormat('MMM yyyy')
                                  .format(_stats!.memberSince)
                              : 'N/A',
                        ),
                      ],
                    ),
              const SizedBox(height: 24),

              // Menu Items
              _ProfileSection(
                title: 'Account',
                items: [
                  _ProfileItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit Profile',
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CommuterEditProfileScreen(),
                        ),
                      );
                      // Reload user data after returning from edit screen
                      setState(() {});
                    },
                  ),
                  _ProfileItem(
                    icon: Icons.phone_outlined,
                    label: user?.phone ?? '+63 912 345 6789',
                    subtitle: 'Phone number',
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CommuterEditProfileScreen(),
                        ),
                      );
                      // Reload user data after returning from edit screen
                      setState(() {});
                    },
                  ),
                  _ProfileItem(
                    icon: Icons.lock_outline_rounded,
                    label: 'Change Password',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CommuterChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ProfileSection(
                title: 'Preferences',
                items: [
                  _ProfileItem(
                    icon: Icons.language_rounded,
                    label: 'Language',
                    trailing: Text(
                      'English',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Language selection will be available in the next update'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _ProfileItem(
                    icon: Icons.dark_mode_rounded,
                    label: 'Appearance',
                    trailing: Text(
                      'Dark',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Theme selection will be available in the next update'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ProfileSection(
                title: 'Support',
                items: [
                  _ProfileItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & FAQ',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('For assistance, please contact support@evergo.ph'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 4),
                        ),
                      );
                    },
                  ),
                  _ProfileItem(
                    icon: Icons.info_outline_rounded,
                    label: 'About Evergo',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.cardDark,
                          title: Text(
                            'About Evergo',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          content: Text(
                            'Evergo Bus Tracker\nVersion 1.0.0\n\nDipolog-Dapitan Route Bus Tracking System\n\n© 2024 Evergo. All rights reserved.',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Close',
                                style: GoogleFonts.inter(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Logout
              GestureDetector(
                onTap: () async {
                  await authCtrl.logout();
                  if (context.mounted) {
                    context.go(RouteNames.roleSelection);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
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
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;

  const _ProfileAvatar({required this.name, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').take(2).map((w) => w[0]).join();
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: avatarUrl == null ? AppColors.primaryGradient : null,
        shape: BoxShape.circle,
        image: avatarUrl != null
            ? DecorationImage(
                image: NetworkImage(avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: avatarUrl == null
          ? Center(
              child: Text(
                initials.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.dividerDark),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<_ProfileItem> items;

  const _ProfileSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.dividerDark),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              return Column(
                children: [
                  items[i],
                  if (i < items.length - 1)
                    const Divider(
                      color: AppColors.dividerDark,
                      height: 1,
                      indent: 54,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _ProfileItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.textMuted,
                    size: 14,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

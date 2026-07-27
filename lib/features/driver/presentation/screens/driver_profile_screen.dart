import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../shared/models/bus_model.dart';
import '../controllers/driver_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'driver_edit_profile_screen.dart';
import 'driver_change_password_screen.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final driverCtrl = Get.find<DriverController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePadding),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Driver Profile',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Avatar - Reactive
              Obx(() {
                final user = authCtrl.currentUser.value;
                return Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: user?.avatarUrl == null ? AppColors.accentGradient : null,
                    shape: BoxShape.circle,
                    image: user?.avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(user!.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: user?.avatarUrl == null
                      ? Center(
                          child: Text(
                            user?.name.split(' ').take(2).map((w) => w[0]).join().toUpperCase() ?? 'JD',
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                );
              }),
              const SizedBox(height: 16),
              
              // Name & Email - Reactive
              Obx(() {
                final user = authCtrl.currentUser.value;
                return Column(
                  children: [
                    Text(
                      user?.name ?? 'Juan dela Cruz',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'driver@evergo.ph',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 8),
              // Driver badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.drive_eta_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
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

              // Driver Stats
              Row(
                children: [
                  _DriverStat(
                    label: "Today's Trips",
                    value: '${driverCtrl.todayTrips.value}',
                  ),
                  _DriverStat(
                    label: 'Distance',
                    value:
                        '${driverCtrl.totalDistance.value.toStringAsFixed(0)} km',
                  ),
                  _DriverStat(
                    label: 'Reports',
                    value: '${driverCtrl.reports.length}',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bus Info Section
              Obx(() {
                final bus = driverCtrl.assignedBus.value;
                final isLoading = driverCtrl.isLoadingBus.value;

                if (isLoading) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                  );
                }

                if (bus == null) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(color: AppColors.dividerDark),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.textMuted,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Bus Assigned',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Contact admin for bus assignment',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_bus_rounded,
                              color: AppColors.accent,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assigned Vehicle',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  '${bus.busNumber} — ${bus.plateNumber}',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (bus.status == BusStatus.online
                                      ? AppColors.success
                                      : AppColors.textMuted)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              bus.statusLabel,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: bus.status == BusStatus.online
                                    ? AppColors.success
                                    : AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: AppColors.dividerDark, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.route_rounded,
                              color: AppColors.textMuted, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              bus.routeName,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Profile Menu - Reactive
              Obx(() {
                final user = authCtrl.currentUser.value;
                return Column(
                  children: [
                    _ProfileSection(
                      title: 'Account',
                      items: [
                        _ProfileItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Edit Profile',
                          onTap: () {
                            Get.to(() => const DriverEditProfileScreen());
                          },
                        ),
                        _ProfileItem(
                          icon: Icons.phone_outlined,
                          label: user?.phone ?? '+63 917 654 3210',
                          subtitle: 'Phone number',
                          onTap: () {
                            Get.to(() => const DriverEditProfileScreen());
                          },
                        ),
                        _ProfileItem(
                          icon: Icons.lock_outline_rounded,
                          label: 'Change Password',
                          onTap: () {
                            Get.to(() => const DriverChangePasswordScreen());
                          },
                        ),
                      ],
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),
              _ProfileSection(
                title: 'Work',
                items: [
                  _ProfileItem(
                    icon: Icons.directions_bus_rounded,
                    label: 'Bus Information',
                    onTap: () {
                      final bus = driverCtrl.assignedBus.value;
                      if (bus == null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.cardDark,
                            title: Text(
                              'No Bus Assigned',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            content: Text(
                              'You currently have no bus assigned. Please contact your administrator.',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Close',
                                  style: GoogleFonts.inter(color: AppColors.accent),
                                ),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.cardDark,
                          title: Text(
                            'Bus Information',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoRow('Bus Number', bus.busNumber),
                              _InfoRow('Plate Number', bus.plateNumber),
                              _InfoRow('Route', bus.routeName),
                              _InfoRow('Capacity', '${bus.capacity} seats'),
                              _InfoRow('Status', bus.statusLabel),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Close',
                                style: GoogleFonts.inter(color: AppColors.accent),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _ProfileItem(
                    icon: Icons.route_rounded,
                    label: 'Route Assignment',
                    trailing: Obx(() {
                      final bus = driverCtrl.assignedBus.value;
                      return Text(
                        bus?.busNumber ?? 'N/A',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                    onTap: () {
                      final bus = driverCtrl.assignedBus.value;
                      if (bus == null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.cardDark,
                            title: Text(
                              'No Route Assigned',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            content: Text(
                              'You currently have no route assigned. Please contact your administrator.',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Close',
                                  style: GoogleFonts.inter(color: AppColors.accent),
                                ),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      // Find the route details
                      final route = BusRouteModel.mockRoutes.firstWhere(
                        (r) => r.id == bus.routeId,
                        orElse: () => BusRouteModel.mockRoutes.first,
                      );

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.cardDark,
                          title: Text(
                            'Route Assignment',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoRow('Route ID', bus.routeId),
                              _InfoRow('Route Name', bus.routeName),
                              _InfoRow('Distance', route.distance),
                              _InfoRow('Duration', route.duration),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Close',
                                style: GoogleFonts.inter(color: AppColors.accent),
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
                      const Icon(Icons.logout_rounded,
                          color: AppColors.error, size: 18),
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

class _DriverStat extends StatelessWidget {
  final String label;
  final String value;

  const _DriverStat({required this.label, required this.value});

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
                color: AppColors.accent,
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

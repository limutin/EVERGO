import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/models/bus_model.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../controllers/commuter_controller.dart';
import '../screens/commuter_dashboard_screen.dart';
import '../screens/commuter_map_screen.dart';
import '../screens/commuter_routes_screen.dart';
import '../screens/commuter_schedules_screen.dart';
import '../screens/commuter_notifications_screen.dart';
import '../screens/commuter_profile_screen.dart';

class CommuterShell extends StatelessWidget {
  const CommuterShell({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CommuterController());
    final ctrl = CommuterController.to;

    final screens = [
      const CommuterDashboardScreen(),
      const CommuterMapScreen(),
      const CommuterRoutesScreen(),
      const CommuterSchedulesScreen(),
      const CommuterNotificationsScreen(),
      const CommuterProfileScreen(),
    ];

    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: screens[ctrl.selectedTabIndex.value],
        bottomNavigationBar: _CommuterNavBar(controller: ctrl),
      ),
    );
  }
}

class _CommuterNavBar extends StatelessWidget {
  final CommuterController controller;

  const _CommuterNavBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border(
            top: BorderSide(color: AppColors.dividerDark, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: AppSizes.bottomNavHeight,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Home',
                  index: 0,
                  controller: controller,
                ),
                _NavItem(
                  icon: Icons.map_rounded,
                  label: 'Track',
                  index: 1,
                  controller: controller,
                ),
                _NavItem(
                  icon: Icons.route_rounded,
                  label: 'Routes',
                  index: 2,
                  controller: controller,
                ),
                _NavItem(
                  icon: Icons.schedule_rounded,
                  label: 'Schedule',
                  index: 3,
                  controller: controller,
                ),
                _NotificationNavItem(controller: controller),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  index: 5,
                  controller: controller,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final CommuterController controller;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedTabIndex.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => controller.changeTab(index),
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textMuted,
                  size: 22,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _NotificationNavItem extends StatelessWidget {
  final CommuterController controller;

  const _NotificationNavItem({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedTabIndex.value == 4;
      final unread = controller.unreadNotificationCount;

      return Expanded(
        child: GestureDetector(
          onTap: () => controller.changeTab(4),
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.notifications_rounded,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                  if (unread > 0)
                    Positioned(
                      top: 2,
                      right: 8,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'Alerts',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../controllers/driver_controller.dart';
import '../screens/driver_dashboard_screen.dart';
import '../screens/driver_active_route_screen.dart';
import '../screens/driver_schedule_screen.dart';
import '../screens/driver_reports_screen.dart';
import '../screens/driver_profile_screen.dart';

class DriverShell extends StatelessWidget {
  const DriverShell({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DriverController());
    final ctrl = DriverController.to;

    final screens = [
      const DriverDashboardScreen(),
      const DriverActiveRouteScreen(),
      const DriverScheduleScreen(),
      const DriverReportsScreen(),
      const DriverProfileScreen(),
    ];

    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: screens[ctrl.selectedTabIndex.value],
        bottomNavigationBar: _DriverNavBar(controller: ctrl),
      ),
    );
  }
}

class _DriverNavBar extends StatelessWidget {
  final DriverController controller;

  const _DriverNavBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.dashboard_rounded, label: 'Dashboard'),
      (icon: Icons.directions_bus_rounded, label: 'Route'),
      (icon: Icons.schedule_rounded, label: 'Schedule'),
      (icon: Icons.report_rounded, label: 'Reports'),
      (icon: Icons.person_rounded, label: 'Profile'),
    ];

    return Obx(() => Container(
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
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected =
                      controller.selectedTabIndex.value == index;
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
                                  ? AppColors.accent.withOpacity(0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item.icon,
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.textMuted,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ));
  }
}

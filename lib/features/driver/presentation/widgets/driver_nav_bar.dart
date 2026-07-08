import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/route_names.dart';
import '../controllers/driver_controller.dart';

class DriverShell extends StatelessWidget {
  final Widget child;
  const DriverShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(DriverController());
    
    // Sync tab index with current route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
      ctrl.setTabFromRoute(location);
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: child,
      bottomNavigationBar: _DriverNavBar(controller: ctrl),
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
      (icon: Icons.navigation_rounded, label: 'Active'),
      (icon: Icons.route_rounded, label: 'Routes'),
      (icon: Icons.report_rounded, label: 'Reports'),
      (icon: Icons.person_rounded, label: 'Profile'),
    ];

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
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  return Expanded(
                    child: Obx(() {
                      final isSelected =
                          controller.selectedTabIndex.value == index;
                      return GestureDetector(
                        onTap: () {
                          controller.changeTab(index);
                          _navigateToDriverTab(context, index);
                        },
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
                                    ? AppColors.accent.withValues(alpha: 0.12)
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
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        );
  }

  void _navigateToDriverTab(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.driverDashboard);
        break;
      case 1:
        context.go(RouteNames.driverActiveRoute);
        break;
      case 2:
        context.go(RouteNames.driverRoutes);
        break;
      case 3:
        context.go(RouteNames.driverReports);
        break;
      case 4:
        context.go(RouteNames.driverProfile);
        break;
    }
  }
  }


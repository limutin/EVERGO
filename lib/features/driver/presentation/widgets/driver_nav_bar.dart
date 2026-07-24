import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../controllers/driver_controller.dart';

/// Shell widget that wraps driver screens with a bottom navigation bar
class DriverShell extends StatefulWidget {
  final Widget child;

  const DriverShell({super.key, required this.child});

  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  late DriverController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize DriverController if not already initialized
    if (!Get.isRegistered<DriverController>()) {
      Get.put(DriverController());
    }
    _controller = Get.find<DriverController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: const DriverNavBar(),
    );
  }
}

/// Bottom navigation bar for driver screens
class DriverNavBar extends StatelessWidget {
  const DriverNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DriverController>();

    return Obx(() => Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            border: Border(
              top: BorderSide(
                color: AppColors.dividerDark,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    isActive: ctrl.selectedTabIndex.value == 0,
                    onTap: () {
                      ctrl.changeTab(0);
                      context.go(RouteNames.driverDashboard);
                    },
                  ),
                  _NavItem(
                    icon: Icons.timeline_rounded,
                    label: 'Active',
                    isActive: ctrl.selectedTabIndex.value == 1,
                    onTap: () {
                      ctrl.changeTab(1);
                      context.go(RouteNames.driverActiveRoute);
                    },
                  ),
                  _NavItem(
                    icon: Icons.route_rounded,
                    label: 'Routes',
                    isActive: ctrl.selectedTabIndex.value == 2,
                    onTap: () {
                      ctrl.changeTab(2);
                      context.go(RouteNames.driverRoutes);
                    },
                  ),
                  _NavItem(
                    icon: Icons.assessment_rounded,
                    label: 'Reports',
                    isActive: ctrl.selectedTabIndex.value == 3,
                    onTap: () {
                      ctrl.changeTab(3);
                      context.go(RouteNames.driverReports);
                    },
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    isActive: ctrl.selectedTabIndex.value == 4,
                    onTap: () {
                      ctrl.changeTab(4);
                      context.go(RouteNames.driverProfile);
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isActive
                        ? AppColors.accent
                        : AppColors.textMuted,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? AppColors.accent
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

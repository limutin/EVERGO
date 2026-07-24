import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../controllers/commuter_controller.dart';

/// Shell widget that wraps commuter screens with a bottom navigation bar
class CommuterShell extends StatefulWidget {
  final Widget child;

  const CommuterShell({super.key, required this.child});

  @override
  State<CommuterShell> createState() => _CommuterShellState();
}

class _CommuterShellState extends State<CommuterShell> {
  late CommuterController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize CommuterController if not already initialized
    if (!Get.isRegistered<CommuterController>()) {
      Get.put(CommuterController());
    }
    _controller = Get.find<CommuterController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: const CommuterNavBar(),
    );
  }
}

/// Bottom navigation bar for commuter screens
class CommuterNavBar extends StatelessWidget {
  const CommuterNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CommuterController>();

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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isActive: ctrl.selectedTabIndex.value == 0,
                    onTap: () {
                      ctrl.changeTab(0);
                      context.go(RouteNames.commuterDashboard);
                    },
                  ),
                  _NavItem(
                    icon: Icons.map_rounded,
                    label: 'Map',
                    isActive: ctrl.selectedTabIndex.value == 1,
                    onTap: () {
                      ctrl.changeTab(1);
                      context.go(RouteNames.commuterMap);
                    },
                  ),
                  _NavItem(
                    icon: Icons.route_rounded,
                    label: 'Routes',
                    isActive: ctrl.selectedTabIndex.value == 2,
                    onTap: () {
                      ctrl.changeTab(2);
                      context.go(RouteNames.commuterRoutes);
                    },
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    isActive: ctrl.selectedTabIndex.value == 3,
                    onTap: () {
                      ctrl.changeTab(3);
                      context.go(RouteNames.commuterProfile);
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textMuted,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? AppColors.primary
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

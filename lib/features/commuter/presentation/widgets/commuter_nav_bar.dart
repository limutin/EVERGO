import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/route_names.dart';
import '../controllers/commuter_controller.dart';

class CommuterShell extends StatelessWidget {
  final Widget child;
  const CommuterShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(CommuterController());
    
    // Sync tab index with current route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
      ctrl.setTabFromRoute(location);
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: child,
      bottomNavigationBar: _CommuterNavBar(controller: ctrl),
    );
  }
}

class _CommuterNavBar extends StatelessWidget {
  final CommuterController controller;

  const _CommuterNavBar({required this.controller});

  @override
  Widget build(BuildContext context) {
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
                icon: Icons.person_rounded,
                label: 'Profile',
                index: 3,
                controller: controller,
              ),
            ],
          ),
        ),
      ),
    );
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
          onTap: () {
            controller.changeTab(index);
            _navigateToTab(context, index);
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
                      ? AppColors.primary.withValues(alpha: 0.12)
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

  void _navigateToTab(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.commuterDashboard);
        break;
      case 1:
        context.go(RouteNames.commuterMap);
        break;
      case 2:
        context.go(RouteNames.commuterRoutes);
        break;
      case 3:
        context.go(RouteNames.commuterProfile);
        break;
    }
  }
}

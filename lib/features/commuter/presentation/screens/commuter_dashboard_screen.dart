import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../shared/models/bus_model.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../controllers/commuter_controller.dart';

class CommuterDashboardScreen extends StatelessWidget {
  const CommuterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CommuterController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.cardDark,
          onRefresh: () async =>
              await Future.delayed(const Duration(seconds: 1)),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header
                _DashboardHeader(ctrl: ctrl),
                const SizedBox(height: 24),

                // Stats Row
                _StatsRow(ctrl: ctrl),
                const SizedBox(height: 24),

                // Quick Actions
                _QuickActions(),
                const SizedBox(height: 24),

                // Active Buses
                _SectionHeader(
                  title: 'Active Buses',
                  action: 'View Map',
                  onAction: () => context.go(RouteNames.commuterMap),
                ),
                const SizedBox(height: 12),
                _NearbyBusesList(ctrl: ctrl),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final CommuterController ctrl;

  const _DashboardHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Obx(() => Text(
                    ctrl.currentUser?.name.split(' ').first ?? 'Commuter',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  )),
            ],
          ),
        ),
        // Avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: const Center(
            child: Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Notification Bell (Disabled - No notifications feature)
        Obx(() {
          final unread = ctrl.unreadNotificationCount;
          return Opacity(
            opacity: 0.5,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.dividerDark),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$unread',
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
          );
        }),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final CommuterController ctrl;

  const _StatsRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            _StatCard(
              label: 'Active Buses',
              value: '${ctrl.onlineBusCount}',
              icon: Icons.directions_bus_rounded,
              color: AppColors.success,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Routes',
              value: '${ctrl.routes.length}',
              icon: Icons.route_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            const _StatCard(
              label: 'Avg Wait',
              value: '8 min',
              icon: Icons.timer_rounded,
              color: AppColors.accent,
            ),
          ],
        ));
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.dividerDark),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flash_on_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Quick Actions',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _QuickActionBtn(
                icon: Icons.my_location_rounded,
                label: 'Track Bus',
                onTap: () => context.go(RouteNames.commuterMap),
              ),
              _QuickActionBtn(
                icon: Icons.route_rounded,
                label: 'Routes',
                onTap: () => context.go(RouteNames.commuterRoutes),
              ),
              _QuickActionBtn(
                icon: Icons.person_rounded,
                label: 'Profile',
                onTap: () => context.go(RouteNames.commuterProfile),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
          ),
          child: Text(
            action,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _NearbyBusesList extends StatelessWidget {
  final CommuterController ctrl;

  const _NearbyBusesList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoadingBuses.value) {
        return Column(
          children: const [
            SkeletonBusCard(),
            SkeletonBusCard(),
            SkeletonBusCard(),
          ],
        );
      }

      final buses = ctrl.nearbyBuses.take(3).toList();
      
      if (buses.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.dividerDark),
          ),
          child: Column(
            children: [
              Icon(
                Icons.directions_bus_outlined,
                size: 48,
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No Active Buses',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'There are no buses running at the moment',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return Column(
        children: buses
            .map((bus) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BusCard(bus: bus, ctrl: ctrl),
                ))
            .toList(),
      );
    });
  }
}

class _BusCard extends StatelessWidget {
  final BusModel bus;
  final CommuterController ctrl;

  const _BusCard({required this.bus, required this.ctrl});

  Color get _statusColor {
    switch (bus.status) {
      case BusStatus.online:
        return AppColors.busOnline;
      case BusStatus.offline:
        return AppColors.busOffline;
      case BusStatus.idle:
        return AppColors.busIdle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vacantSeats = bus.capacity - bus.passengerCount;
    final occupancyPercent = (bus.passengerCount / bus.capacity * 100).round();
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.dividerDark),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Bus Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.directions_bus_rounded,
                  color: _statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          bus.busNumber,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                      label: bus.statusLabel,
                      color: _statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Route Name
                Row(
                  children: [
                    Icon(
                      Icons.route_rounded,
                      size: 12,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        bus.routeName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Speed and Driver
                Row(
                  children: [
                    const Icon(
                      Icons.speed_rounded,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${bus.speed.toStringAsFixed(0)} km/h',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        bus.driverName,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (bus.status == BusStatus.online)
            GestureDetector(
              onTap: () {
                ctrl.selectBus(bus);
                context.go(RouteNames.commuterMap);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Track',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 10),
      // Current Stop Indicator (if bus is online)
      if (bus.status == BusStatus.online)
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('busProgress')
              .doc(bus.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data?.data() == null) {
              return const SizedBox.shrink();
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final currentStopIndex = data['currentStopIndex'] as int? ?? 0;
            
            // Find the route and stop name
            final route = BusRouteModel.mockRoutes.firstWhere(
              (r) => r.id == bus.routeId,
              orElse: () => BusRouteModel.mockRoutes.first,
            );
            
            // Use directional stops based on bus direction
            final directionalStops = route.getDirectionalStops(bus.isReversed);
            
            if (currentStopIndex >= 0 && currentStopIndex < directionalStops.length) {
              final currentStop = directionalStops[currentStopIndex];
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Currently at: ',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        currentStop.name,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      if (bus.status == BusStatus.online)
        const SizedBox(height: 10),
      const SizedBox(height: 12),
      // Passenger Information Bar
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: vacantSeats > 10
              ? AppColors.success.withValues(alpha: 0.08)
              : vacantSeats > 0
                  ? AppColors.warning.withValues(alpha: 0.08)
                  : AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: vacantSeats > 10
                ? AppColors.success.withValues(alpha: 0.2)
                : vacantSeats > 0
                    ? AppColors.warning.withValues(alpha: 0.2)
                    : AppColors.error.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Passengers
            Icon(
              Icons.people_rounded,
              size: 16,
              color: vacantSeats > 10
                  ? AppColors.success
                  : vacantSeats > 0
                      ? AppColors.warning
                      : AppColors.error,
            ),
            const SizedBox(width: 6),
            Text(
              '${bus.passengerCount}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              ' / ${bus.capacity}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 1,
              height: 16,
              color: AppColors.dividerDark,
            ),
            const SizedBox(width: 12),
            // Vacant Seats
            Icon(
              Icons.event_seat_rounded,
              size: 16,
              color: vacantSeats > 10
                  ? AppColors.success
                  : vacantSeats > 0
                      ? AppColors.warning
                      : AppColors.error,
            ),
            const SizedBox(width: 6),
            Text(
              '$vacantSeats',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: vacantSeats > 10
                    ? AppColors.success
                    : vacantSeats > 0
                        ? AppColors.warning
                        : AppColors.error,
              ),
            ),
            Text(
              ' vacant',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            // Occupancy Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: vacantSeats > 10
                    ? AppColors.success
                    : vacantSeats > 0
                        ? AppColors.warning
                        : AppColors.error,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$occupancyPercent%',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
  }
}


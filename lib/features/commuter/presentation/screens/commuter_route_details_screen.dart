import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/models/bus_model.dart';
import '../controllers/commuter_controller.dart';

class CommuterRouteDetailsScreen extends StatelessWidget {
  final BusRouteModel route;

  const CommuterRouteDetailsScreen({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CommuterController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Route Details',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route Header Card
                    _RouteHeaderCard(route: route),
                    const SizedBox(height: 16),

                    // Active Buses Section
                    Obx(() {
                      final activeBuses = ctrl.nearbyBuses
                          .where((bus) => bus.routeId == route.id && bus.status == BusStatus.online)
                          .toList();

                      if (activeBuses.isEmpty) {
                        return _NoBusesAvailable();
                      }

                      return _ActiveBusesSection(buses: activeBuses);
                    }),
                    const SizedBox(height: 16),

                    // Stops Section
                    _StopsSection(route: route),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteHeaderCard extends StatelessWidget {
  final BusRouteModel route;

  const _RouteHeaderCard({required this.route});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Route name with badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  route.name,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'MY ROUTE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            route.description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _HeaderStat(
                icon: Icons.straighten_rounded,
                label: route.distance,
              ),
              const SizedBox(width: 16),
              _HeaderStat(
                icon: Icons.access_time_rounded,
                label: route.duration,
              ),
              const SizedBox(width: 16),
              Obx(() {
                final activeBusCount = Get.find<CommuterController>()
                    .nearbyBuses
                    .where((bus) => bus.routeId == route.id && bus.status == BusStatus.online)
                    .length;
                return _HeaderStat(
                  icon: Icons.directions_bus_rounded,
                  label: '$activeBusCount ${activeBusCount == 1 ? 'bus' : 'buses'}',
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderStat({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

class _ActiveBusesSection extends StatelessWidget {
  final List<BusModel> buses;

  const _ActiveBusesSection({required this.buses});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Buses on this Route',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...buses.map((bus) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BusCard(bus: bus),
            )),
      ],
    );
  }
}

class _BusCard extends StatelessWidget {
  final BusModel bus;

  const _BusCard({required this.bus});

  @override
  Widget build(BuildContext context) {
    final seatsLeft = bus.capacity - bus.passengerCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.dividerDark),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // Bus icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_bus_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Bus info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      bus.busNumber,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Online',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${bus.driverName} • ${bus.plateNumber}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Passenger count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${bus.passengerCount}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '$seatsLeft seats left',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoBusesAvailable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.dividerDark),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.textMuted,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Active Buses',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'There are currently no buses online on this route',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
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

class _StopsSection extends StatelessWidget {
  final BusRouteModel route;

  const _StopsSection({required this.route});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stops (${route.stops.length})',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(route.stops.length, (index) {
          final stop = route.stops[index];
          final isFirst = index == 0;
          final isLast = index == route.stops.length - 1;

          return _StopItem(
            stop: stop,
            isFirst: isFirst,
            isLast: isLast,
          );
        }),
      ],
    );
  }
}

class _StopItem extends StatelessWidget {
  final RouteStop stop;
  final bool isFirst;
  final bool isLast;

  const _StopItem({
    required this.stop,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        SizedBox(
          width: 24,
          child: Column(
            children: [
              // Top line
              if (!isFirst)
                Container(
                  width: 2,
                  height: 12,
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              // Circle
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFirst ? AppColors.success : AppColors.cardDark,
                  border: Border.all(
                    color: isFirst ? AppColors.success : AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              // Bottom line
              if (!isLast)
                Container(
                  width: 2,
                  height: 32,
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Stop name
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Text(
              stop.name,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: isFirst ? FontWeight.w700 : FontWeight.w500,
                color: isFirst ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/models/bus_model.dart';
import '../controllers/commuter_controller.dart';

class CommuterRoutesScreen extends StatefulWidget {
  const CommuterRoutesScreen({super.key});

  @override
  State<CommuterRoutesScreen> createState() => _CommuterRoutesScreenState();
}

class _CommuterRoutesScreenState extends State<CommuterRoutesScreen> {
  int? _expandedIndex;
  String? _trackedBusId; // Track specific bus

  @override
  Widget build(BuildContext context) {
    final routes = BusRouteModel.mockRoutes;
    final ctrl = Get.find<CommuterController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: Text(
          'Routes',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded,
                color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
        children: [
          const SizedBox(height: 8),
          // Search
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.dividerDark),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search_rounded,
                    color: AppColors.textMuted, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Search routes...',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(routes.length, (index) {
            final route = routes[index];
            final isExpanded = _expandedIndex == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                border: Border.all(
                  color: isExpanded
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.dividerDark,
                ),
                boxShadow: isExpanded
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  // Route Header
                  GestureDetector(
                    onTap: () => setState(() {
                      _expandedIndex = isExpanded ? null : index;
                    }),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.route_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      route.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      route.description,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _RouteChip(
                                icon: Icons.straighten_rounded,
                                label: route.distance,
                              ),
                              const SizedBox(width: 8),
                              _RouteChip(
                                icon: Icons.timer_rounded,
                                label: route.duration,
                              ),
                              const SizedBox(width: 8),
                              _RouteChip(
                                icon: Icons.directions_bus_rounded,
                                label: '${route.activeBuses} buses',
                                color: AppColors.success,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Expanded Stops
                  if (isExpanded) ...[
                    const Divider(color: AppColors.dividerDark, height: 1),
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Active Buses Header with count
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Active Buses on this Route',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Obx(() {
                                final activeBuses = ctrl.nearbyBuses
                                    .where((b) =>
                                        b.routeId == route.id &&
                                        b.status == BusStatus.online)
                                    .length;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: activeBuses > 0
                                        ? AppColors.success
                                            .withValues(alpha: 0.12)
                                        : AppColors.textMuted
                                            .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.directions_bus_rounded,
                                        size: 11,
                                        color: activeBuses > 0
                                            ? AppColors.success
                                            : AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$activeBuses active',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: activeBuses > 0
                                              ? AppColors.success
                                              : AppColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Active Buses List (trackable)
                          Obx(() {
                            final activeBuses = ctrl.nearbyBuses
                                .where((b) =>
                                    b.routeId == route.id &&
                                    b.status == BusStatus.online)
                                .toList();

                            if (activeBuses.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.cardDark2,
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.radiusMd),
                                  border: Border.all(
                                      color: AppColors.dividerDark),
                                ),
                                child: Center(
                                  child: Text(
                                    'No active buses on this route',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: activeBuses.map((bus) {
                                final vacantSeats =
                                    bus.capacity - bus.passengerCount;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardDark2,
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMd),
                                    border: Border.all(
                                        color: AppColors.dividerDark),
                                  ),
                                  child: Row(
                                    children: [
                                      // Bus Icon
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: AppColors.accent
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.directions_bus_rounded,
                                          color: AppColors.accent,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Bus Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              bus.busNumber,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              '$vacantSeats vacant seats',
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: vacantSeats > 10
                                                    ? AppColors.success
                                                    : vacantSeats > 0
                                                        ? AppColors.warning
                                                        : AppColors.error,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Track Button
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            // Toggle tracking
                                            _expandedIndex = index;
                                            _trackedBusId =
                                                _trackedBusId == bus.id
                                                    ? null
                                                    : bus.id;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: _trackedBusId == bus.id
                                                ? AppColors.accent
                                                : AppColors.accent
                                                    .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _trackedBusId == bus.id
                                                    ? Icons.visibility_rounded
                                                    : Icons
                                                        .visibility_off_rounded,
                                                size: 14,
                                                color: _trackedBusId == bus.id
                                                    ? Colors.white
                                                    : AppColors.accent,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _trackedBusId == bus.id
                                                    ? 'Tracking'
                                                    : 'Track',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: _trackedBusId == bus.id
                                                      ? Colors.white
                                                      : AppColors.accent,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          }),
                          
                          const SizedBox(height: 16),
                          const Divider(color: AppColors.dividerDark, height: 1),
                          const SizedBox(height: 16),
                          
                          // Stops Header
                          Text(
                            'Stops (${route.stops.length})',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Live Progress for tracked bus or all buses
                          ...List.generate(route.stops.length, (si) {
                            final stop = route.stops[si];
                            final isFirst = si == 0;
                            final isLast = si == route.stops.length - 1;

                            return StreamBuilder<QuerySnapshot>(
                              stream: _trackedBusId != null
                                  ? FirebaseFirestore.instance
                                      .collection('busProgress')
                                      .where('routeId', isEqualTo: route.id)
                                      .where(FieldPath.documentId,
                                          isEqualTo: _trackedBusId)
                                      .snapshots()
                                  : FirebaseFirestore.instance
                                      .collection('busProgress')
                                      .where('routeId', isEqualTo: route.id)
                                      .snapshots(),
                              builder: (context, snapshot) {
                                // Determine if tracked bus or any bus is at/passed this stop
                                bool hasActiveBusHere = false;
                                bool hasPassedBusHere = false;
                                List<String> busesAtStop = [];

                                if (snapshot.hasData) {
                                  for (var doc in snapshot.data!.docs) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final currentStopIndex =
                                        data['currentStopIndex'] as int? ?? 0;

                                    if (currentStopIndex == si) {
                                      hasActiveBusHere = true;
                                      // Get bus number
                                      final bus = ctrl.nearbyBuses.firstWhereOrNull(
                                        (b) => b.id == doc.id,
                                      );
                                      if (bus != null) {
                                        busesAtStop.add(bus.busNumber);
                                      }
                                    } else if (currentStopIndex > si) {
                                      hasPassedBusHere = true;
                                    }
                                  }
                                }

                                final stopColor = hasActiveBusHere
                                    ? AppColors.accent
                                    : hasPassedBusHere
                                        ? AppColors.success
                                        : (isFirst || isLast)
                                            ? AppColors.primary
                                            : AppColors.textMuted;

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Timeline
                                    SizedBox(
                                      width: 24,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: hasActiveBusHere ||
                                                      hasPassedBusHere
                                                  ? stopColor
                                                  : (isFirst || isLast)
                                                      ? stopColor
                                                      : AppColors.cardDark2,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: stopColor,
                                                width: 2,
                                              ),
                                            ),
                                            child: hasActiveBusHere
                                                ? const Icon(
                                                    Icons
                                                        .radio_button_checked_rounded,
                                                    size: 10,
                                                    color: Colors.white,
                                                  )
                                                : hasPassedBusHere
                                                    ? const Icon(
                                                        Icons.check_rounded,
                                                        size: 10,
                                                        color: Colors.white,
                                                      )
                                                    : null,
                                          ),
                                          if (!isLast)
                                            Container(
                                              width: 2,
                                              height: 32,
                                              color: hasPassedBusHere
                                                  ? AppColors.success
                                                      .withValues(alpha: 0.5)
                                                  : AppColors.primary
                                                      .withValues(alpha: 0.3),
                                              margin: const EdgeInsets.only(
                                                  top: 2, bottom: 2),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    stop.name,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          hasActiveBusHere
                                                              ? FontWeight.w700
                                                              : FontWeight.w600,
                                                      color: hasActiveBusHere
                                                          ? AppColors.accent
                                                          : hasPassedBusHere
                                                              ? AppColors
                                                                  .textSecondary
                                                              : AppColors
                                                                  .textPrimary,
                                                    ),
                                                  ),
                                                ),
                                                if (hasActiveBusHere &&
                                                    busesAtStop.isNotEmpty)
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.accent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      busesAtStop.join(', '),
                                                      style: GoogleFonts.inter(
                                                        fontSize: 9,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            if (stop.estimatedTime != null)
                                              Text(
                                                stop.estimatedTime!,
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  color: AppColors.textMuted,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _RouteChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _RouteChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: c),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: c,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

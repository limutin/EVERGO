import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../controllers/driver_controller.dart';

class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DriverController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _DriverHeader(ctrl: ctrl),
              const SizedBox(height: 20),
              _TripStatusCard(ctrl: ctrl),
              const SizedBox(height: 20),
              _StatsRow(ctrl: ctrl),
              const SizedBox(height: 20),
              _AssignedBusCard(ctrl: ctrl),
              const SizedBox(height: 20),
              _RecentActivityCard(ctrl: ctrl),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverHeader extends StatelessWidget {
  final DriverController ctrl;

  const _DriverHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Driver Portal',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Obx(() => Text(
                    ctrl.currentUser?.name.split(' ').first ??
                        'Driver',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  )),
            ],
          ),
        ),
        // Location sharing indicator
        Obx(() => Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ctrl.isSharingLocation.value
                    ? AppColors.success.withValues(alpha: 0.12)
                    : AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                border: Border.all(
                  color: ctrl.isSharingLocation.value
                      ? AppColors.success.withValues(alpha: 0.4)
                      : AppColors.dividerDark,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    ctrl.isSharingLocation.value
                        ? Icons.location_on_rounded
                        : Icons.location_off_rounded,
                    size: 14,
                    color: ctrl.isSharingLocation.value
                        ? AppColors.success
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    ctrl.isSharingLocation.value ? 'Live' : 'Offline',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ctrl.isSharingLocation.value
                          ? AppColors.success
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _TripStatusCard extends StatelessWidget {
  final DriverController ctrl;

  const _TripStatusCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = ctrl.tripStatus.value;
      final isInProgress = status == DriverTripState.inProgress;

      return Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          gradient: isInProgress
              ? AppColors.accentGradient
              : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          boxShadow: [
            BoxShadow(
              color: (isInProgress ? AppColors.accent : AppColors.primary)
                  .withValues(alpha: 0.3),
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
                  Icons.directions_bus_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  ctrl.assignedBusNumber,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ctrl.tripStatusLabel,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ctrl.assignedRoute,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            if (isInProgress)
              Obx(() => Text(
                    '${ctrl.currentSpeed.value.toStringAsFixed(0)} km/h  •  ${ctrl.passengerCount} passengers',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  )),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                if (status == DriverTripState.notStarted ||
                    status == DriverTripState.completed)
                  _TripButton(
                    label: 'Start Trip',
                    icon: Icons.play_arrow_rounded,
                    onTap: () => ctrl.startTrip(context),
                  )
                else if (status == DriverTripState.inProgress) ...[
                  _TripButton(
                    label: 'Pause',
                    icon: Icons.pause_rounded,
                    onTap: ctrl.pauseTrip,
                    outline: true,
                  ),
                  const SizedBox(width: 10),
                  _TripButton(
                    label: 'End Trip',
                    icon: Icons.stop_rounded,
                    onTap: ctrl.endTrip,
                  ),
                ] else if (status == DriverTripState.paused) ...[
                  _TripButton(
                    label: 'Resume',
                    icon: Icons.play_arrow_rounded,
                    onTap: ctrl.resumeTrip,
                  ),
                  const SizedBox(width: 10),
                  _TripButton(
                    label: 'End Trip',
                    icon: Icons.stop_rounded,
                    onTap: ctrl.endTrip,
                    outline: true,
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _TripButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outline;

  const _TripButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.outline = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: Colors.white.withValues(alpha: outline ? 0.6 : 1),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: outline
                  ? Colors.white.withValues(alpha: 0.9)
                  : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: outline
                    ? Colors.white.withValues(alpha: 0.9)
                    : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final DriverController ctrl;

  const _StatsRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            _StatCard(
              label: "Today's Trips",
              value: '${ctrl.todayTrips.value}',
              icon: Icons.loop_rounded,
              color: AppColors.accent,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Distance',
              value: '${ctrl.totalDistance.value.toStringAsFixed(0)} km',
              icon: Icons.straighten_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Passengers',
              value: '${ctrl.passengerCount.value}',
              icon: Icons.people_rounded,
              color: AppColors.warning,
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
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
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

class _AssignedBusCard extends StatelessWidget {
  final DriverController ctrl;

  const _AssignedBusCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bus = ctrl.assignedBus.value;
      final isLoading = ctrl.isLoadingBus.value;

      if (isLoading) {
        return Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.dividerDark),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assigned Bus',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.directions_bus_rounded,
                      color: AppColors.accent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.dividerDark,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 80,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.dividerDark,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      if (bus == null) {
        return Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.dividerDark),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                'Please contact admin for bus assignment',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      final vacantSeats = bus.capacity - bus.passengerCount;

      return Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.dividerDark),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assigned Bus',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.directions_bus_rounded,
                    color: AppColors.accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus.busNumber,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        bus.plateNumber,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Capacity',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      '${bus.capacity} seats',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.dividerDark, height: 1),
            const SizedBox(height: 14),
            // Passenger Count Display
            Row(
              children: [
                Expanded(
                  child: _PassengerInfoCard(
                    icon: Icons.people_rounded,
                    label: 'Passengers',
                    value: '${bus.passengerCount}',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PassengerInfoCard(
                    icon: Icons.event_seat_rounded,
                    label: 'Vacant Seats',
                    value: '$vacantSeats',
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Passenger Counter with +/- Buttons
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Update Passenger Count',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                // Minus Button
                GestureDetector(
                  onTap: ctrl.decrementPassengerCount,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.cardDark2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.accent.withOpacity(0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.remove_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Count Display
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${ctrl.passengerCount.value}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                )),
                const SizedBox(width: 12),
                // Plus Button
                GestureDetector(
                  onTap: ctrl.incrementPassengerCount,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                  '${ctrl.passengerCount.value} / ${bus.capacity}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                )),
                Obx(() => Text(
                  '${((ctrl.passengerCount.value / bus.capacity) * 100).toStringAsFixed(0)}% full',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                )),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _PassengerInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _PassengerInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final DriverController ctrl;

  const _RecentActivityCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Reports',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => ctrl.reports.isEmpty
            ? const SizedBox.shrink()
            : Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(color: AppColors.dividerDark),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  children: ctrl.reports
                      .take(2)
                      .map((r) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: r.status == 'Submitted'
                                        ? AppColors.warning
                                        : AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${r.type}: ${r.description}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  r.status,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: r.status == 'Submitted'
                                        ? AppColors.warning
                                        : AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              )),
      ],
    );
  }
}

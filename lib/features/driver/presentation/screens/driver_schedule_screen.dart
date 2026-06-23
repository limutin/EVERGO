import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../controllers/driver_controller.dart';

class DriverScheduleScreen extends StatelessWidget {
  const DriverScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = DriverController.to;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text(
          'My Schedule',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Obx(() {
        final schedule = ctrl.schedule;
        final completed = schedule.where((s) => s.isCompleted).length;
        final total = schedule.length;
        final progress = total > 0 ? completed / total : 0.0;

        return Column(
          children: [
            // Progress Header
            Padding(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Today\'s Progress',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$completed/$total trips',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% complete',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Schedule List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.pagePadding),
                itemCount: schedule.length,
                itemBuilder: (context, i) {
                  final entry = schedule[i];
                  return _DriverScheduleCard(
                    entry: entry,
                    index: i,
                    isLast: i == schedule.length - 1,
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _DriverScheduleCard extends StatelessWidget {
  final DriverScheduleEntry entry;
  final int index;
  final bool isLast;

  const _DriverScheduleCard({
    required this.entry,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = entry.isCompleted
        ? AppColors.textMuted
        : entry.isCurrent
            ? AppColors.accent
            : AppColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline
        SizedBox(
          width: 40,
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: entry.isCompleted
                      ? AppColors.success.withOpacity(0.12)
                      : entry.isCurrent
                          ? AppColors.accent.withOpacity(0.12)
                          : AppColors.cardDark,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: entry.isCompleted
                        ? AppColors.success
                        : entry.isCurrent
                            ? AppColors.accent
                            : AppColors.dividerDark,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    entry.isCompleted
                        ? Icons.check_rounded
                        : entry.isCurrent
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: entry.isCompleted
                        ? AppColors.success
                        : entry.isCurrent
                            ? AppColors.accent
                            : AppColors.textMuted,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 48,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: AppColors.dividerDark,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Card
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: entry.isCurrent
                  ? AppColors.accent.withOpacity(0.06)
                  : AppColors.cardDark,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: entry.isCurrent
                    ? AppColors.accent.withOpacity(0.3)
                    : AppColors.dividerDark,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.routeName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: entry.isCurrent
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: entry.isCompleted
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (entry.isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'NOW',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    if (entry.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Done',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: statusColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${entry.departure} → ${entry.arrival}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.directions_bus_rounded,
                      size: 12,
                      color: statusColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      entry.busNumber,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

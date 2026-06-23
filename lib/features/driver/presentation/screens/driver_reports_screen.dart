import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../controllers/driver_controller.dart';

class DriverReportsScreen extends StatefulWidget {
  const DriverReportsScreen({super.key});

  @override
  State<DriverReportsScreen> createState() => _DriverReportsScreenState();
}

class _DriverReportsScreenState extends State<DriverReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final ctrl = DriverController.to;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text(
          'Reports',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_rounded,
              color: AppColors.accent,
              size: 28,
            ),
            onPressed: () => _showSubmitReportSheet(context, ctrl),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.report_off_outlined,
                  size: 64,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  'No reports yet',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          itemCount: ctrl.reports.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            return _ReportCard(report: ctrl.reports[i]);
          },
        );
      }),
    );
  }

  void _showSubmitReportSheet(
      BuildContext context, DriverController ctrl) {
    final typeCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedType = 'Delay';
    final types = ['Delay', 'Maintenance', 'Incident', 'Passenger', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.dividerDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Submit Report',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Type selector
                Text(
                  'Report Type',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: types.map((t) {
                    final isSelected = selectedType == t;
                    return GestureDetector(
                      onTap: () =>
                          setSheetState(() => selectedType = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.cardDark,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusFull),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.dividerDark,
                          ),
                        ),
                        child: Text(
                          t,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Description
                Text(
                  'Description',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 4,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Describe the incident or issue...',
                    filled: true,
                    fillColor: AppColors.cardDark,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: const BorderSide(
                          color: AppColors.dividerDark),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: const BorderSide(
                          color: AppColors.dividerDark),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                      borderSide:
                          const BorderSide(color: AppColors.accent),
                    ),
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Button
                GestureDetector(
                  onTap: () {
                    if (descCtrl.text.trim().isNotEmpty) {
                      ctrl.submitReport(
                        type: selectedType,
                        description: descCtrl.text.trim(),
                      );
                      Navigator.pop(ctx);
                      Get.snackbar(
                        'Report Submitted',
                        'Your report has been sent successfully.',
                        backgroundColor: AppColors.success.withOpacity(0.15),
                        colorText: AppColors.success,
                        snackPosition: SnackPosition.TOP,
                        icon: const Icon(Icons.check_circle_rounded,
                            color: AppColors.success),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Submit Report',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final DriverReport report;

  const _ReportCard({required this.report});

  Color get _statusColor {
    switch (report.status) {
      case 'Submitted':
        return AppColors.warning;
      case 'Reviewed':
        return AppColors.primary;
      case 'Resolved':
        return AppColors.success;
      default:
        return AppColors.textMuted;
    }
  }

  Color get _typeColor {
    switch (report.type) {
      case 'Delay':
        return AppColors.warning;
      case 'Maintenance':
        return AppColors.primary;
      case 'Incident':
        return AppColors.error;
      case 'Passenger':
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _typeIcon {
    switch (report.type) {
      case 'Delay':
        return Icons.timer_off_rounded;
      case 'Maintenance':
        return Icons.build_rounded;
      case 'Incident':
        return Icons.warning_rounded;
      case 'Passenger':
        return Icons.people_rounded;
      default:
        return Icons.report_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTime(report.timestamp);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.dividerDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _typeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_typeIcon, color: _typeColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  report.type,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _statusColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  report.status,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            report.description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            timeAgo,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

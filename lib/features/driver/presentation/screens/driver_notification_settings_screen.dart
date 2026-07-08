import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class DriverNotificationSettingsScreen extends StatefulWidget {
  const DriverNotificationSettingsScreen({super.key});

  @override
  State<DriverNotificationSettingsScreen> createState() =>
      _DriverNotificationSettingsScreenState();
}

class _DriverNotificationSettingsScreenState
    extends State<DriverNotificationSettingsScreen> {
  bool _tripAssignments = true;
  bool _scheduleChanges = true;
  bool _emergencyAlerts = true;
  bool _maintenanceReminders = true;
  bool _systemUpdates = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tripAssignments = prefs.getBool('driver_notif_trip_assignments') ?? true;
      _scheduleChanges = prefs.getBool('driver_notif_schedule_changes') ?? true;
      _emergencyAlerts = prefs.getBool('driver_notif_emergency_alerts') ?? true;
      _maintenanceReminders = prefs.getBool('driver_notif_maintenance') ?? true;
      _systemUpdates = prefs.getBool('driver_notif_system_updates') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('driver_notif_trip_assignments', _tripAssignments);
    await prefs.setBool('driver_notif_schedule_changes', _scheduleChanges);
    await prefs.setBool('driver_notif_emergency_alerts', _emergencyAlerts);
    await prefs.setBool('driver_notif_maintenance', _maintenanceReminders);
    await prefs.setBool('driver_notif_system_updates', _systemUpdates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: Text(
          'Notification Settings',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          const SizedBox(height: 8),
          
          _buildSection('Work Notifications', [
            _buildSwitchTile(
              'Trip Assignments',
              'Alerts for new trip assignments',
              Icons.assignment_rounded,
              _tripAssignments,
              (value) => setState(() {
                _tripAssignments = value;
                _saveSettings();
              }),
            ),
            _buildSwitchTile(
              'Schedule Changes',
              'Updates to your work schedule',
              Icons.schedule_rounded,
              _scheduleChanges,
              (value) => setState(() {
                _scheduleChanges = value;
                _saveSettings();
              }),
            ),
            _buildSwitchTile(
              'Emergency Alerts',
              'Critical safety and emergency notices',
              Icons.warning_rounded,
              _emergencyAlerts,
              (value) => setState(() {
                _emergencyAlerts = value;
                _saveSettings();
              }),
            ),
            _buildSwitchTile(
              'Maintenance Reminders',
              'Bus maintenance and inspection alerts',
              Icons.build_rounded,
              _maintenanceReminders,
              (value) => setState(() {
                _maintenanceReminders = value;
                _saveSettings();
              }),
            ),
          ]),

          const SizedBox(height: 24),

          _buildSection('General', [
            _buildSwitchTile(
              'System Updates',
              'App updates and announcements',
              Icons.info_outline_rounded,
              _systemUpdates,
              (value) => setState(() {
                _systemUpdates = value;
                _saveSettings();
              }),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.dividerDark),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.dividerDark, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

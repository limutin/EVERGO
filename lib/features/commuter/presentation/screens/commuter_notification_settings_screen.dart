import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class CommuterNotificationSettingsScreen extends StatefulWidget {
  const CommuterNotificationSettingsScreen({super.key});

  @override
  State<CommuterNotificationSettingsScreen> createState() =>
      _CommuterNotificationSettingsScreenState();
}

class _CommuterNotificationSettingsScreenState
    extends State<CommuterNotificationSettingsScreen> {
  bool _busArrivals = true;
  bool _scheduleChanges = true;
  bool _delays = true;
  bool _promotions = false;
  bool _systemUpdates = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _busArrivals = prefs.getBool('notif_bus_arrivals') ?? true;
      _scheduleChanges = prefs.getBool('notif_schedule_changes') ?? true;
      _delays = prefs.getBool('notif_delays') ?? true;
      _promotions = prefs.getBool('notif_promotions') ?? false;
      _systemUpdates = prefs.getBool('notif_system_updates') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_bus_arrivals', _busArrivals);
    await prefs.setBool('notif_schedule_changes', _scheduleChanges);
    await prefs.setBool('notif_delays', _delays);
    await prefs.setBool('notif_promotions', _promotions);
    await prefs.setBool('notif_system_updates', _systemUpdates);
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          const SizedBox(height: 8),
          
          _buildSection('Bus Updates', [
            _buildSwitchTile(
              'Bus Arrivals',
              'Get notified when your bus is nearby',
              Icons.directions_bus_rounded,
              _busArrivals,
              (value) => setState(() {
                _busArrivals = value;
                _saveSettings();
              }),
            ),
            _buildSwitchTile(
              'Schedule Changes',
              'Alerts for schedule modifications',
              Icons.schedule_rounded,
              _scheduleChanges,
              (value) => setState(() {
                _scheduleChanges = value;
                _saveSettings();
              }),
            ),
            _buildSwitchTile(
              'Delays & Cancellations',
              'Real-time delay notifications',
              Icons.warning_rounded,
              _delays,
              (value) => setState(() {
                _delays = value;
                _saveSettings();
              }),
            ),
          ]),

          const SizedBox(height: 24),

          _buildSection('General', [
            _buildSwitchTile(
              'Promotions & Offers',
              'Special deals and discounts',
              Icons.local_offer_rounded,
              _promotions,
              (value) => setState(() {
                _promotions = value;
                _saveSettings();
              }),
            ),
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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
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
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

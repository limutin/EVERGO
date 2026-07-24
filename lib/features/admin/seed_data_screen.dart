import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/seed_firestore.dart';
import '../../core/constants/app_colors.dart';

/// Admin screen to seed Firestore database with initial data
/// Run this once to populate routes and buses
class SeedDataScreen extends StatefulWidget {
  const SeedDataScreen({super.key});

  @override
  State<SeedDataScreen> createState() => _SeedDataScreenState();
}

class _SeedDataScreenState extends State<SeedDataScreen> {
  final _seed = FirestoreSeed();
  final _driver1Controller = TextEditingController();
  final _driver2Controller = TextEditingController();
  final _driver3Controller = TextEditingController();
  
  bool _isSeeding = false;
  String _status = 'Ready to seed database';
  bool _routeExists = false;
  bool _busesExist = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkExistingData();
  }

  @override
  void dispose() {
    _driver1Controller.dispose();
    _driver2Controller.dispose();
    _driver3Controller.dispose();
    super.dispose();
  }

  Future<void> _checkExistingData() async {
    setState(() => _isChecking = true);
    
    try {
      final routeExists = await _seed.routeExists();
      final busesExist = await _seed.busesExist();
      
      setState(() {
        _routeExists = routeExists;
        _busesExist = busesExist;
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error checking data: $e';
        _isChecking = false;
      });
    }
  }

  Future<void> _seedRoute() async {
    setState(() {
      _isSeeding = true;
      _status = 'Seeding route...';
    });

    try {
      await _seed.seedRoute();
      setState(() {
        _status = '✅ Route seeded successfully!';
        _routeExists = true;
      });
      
      Get.snackbar(
        'Success',
        'Route added to Firestore',
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
      Get.snackbar(
        'Error',
        'Failed to seed route: $e',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isSeeding = false);
    }
  }

  Future<void> _seedBuses() async {
    // Validate driver IDs
    if (_driver1Controller.text.isEmpty ||
        _driver2Controller.text.isEmpty ||
        _driver3Controller.text.isEmpty) {
      Get.snackbar(
        'Missing Information',
        'Please provide all 3 driver UIDs from Firebase Authentication',
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isSeeding = true;
      _status = 'Seeding buses...';
    });

    try {
      await _seed.seedBuses(
        driver1Id: _driver1Controller.text.trim(),
        driver2Id: _driver2Controller.text.trim(),
        driver3Id: _driver3Controller.text.trim(),
      );
      
      setState(() {
        _status = '✅ Buses seeded successfully!';
        _busesExist = true;
      });
      
      Get.snackbar(
        'Success',
        '3 buses added to Firestore',
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
      Get.snackbar(
        'Error',
        'Failed to seed buses: $e',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isSeeding = false);
    }
  }

  Future<void> _seedAll() async {
    setState(() {
      _isSeeding = true;
      _status = 'Seeding all data...';
    });

    try {
      await _seed.seedAll(
        driver1Id: _driver1Controller.text.trim().isEmpty 
            ? null 
            : _driver1Controller.text.trim(),
        driver2Id: _driver2Controller.text.trim().isEmpty 
            ? null 
            : _driver2Controller.text.trim(),
        driver3Id: _driver3Controller.text.trim().isEmpty 
            ? null 
            : _driver3Controller.text.trim(),
      );
      
      await _checkExistingData();
      
      setState(() => _status = '✅ Database seeded successfully!');
      
      Get.snackbar(
        'Success',
        'Database seeded successfully',
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
      Get.snackbar(
        'Error',
        'Failed to seed database: $e',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seed Database',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isChecking
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Card
                  _buildStatusCard(),
                  const SizedBox(height: 24),

                  // Existing Data Status
                  _buildExistingDataCard(),
                  const SizedBox(height: 24),

                  // Route Section
                  _buildSectionTitle('1. Seed Route'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    'Adds the Dipolog ↔ Dapitan route with 10 stops',
                    Icons.route,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _routeExists || _isSeeding ? null : _seedRoute,
                    icon: _routeExists
                        ? const Icon(Icons.check_circle)
                        : const Icon(Icons.upload),
                    label: Text(_routeExists ? 'Route Already Exists' : 'Seed Route'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _routeExists ? Colors.grey : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Buses Section
                  _buildSectionTitle('2. Seed Buses (Optional)'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    'Requires driver UIDs from Firebase Authentication',
                    Icons.directions_bus,
                  ),
                  const SizedBox(height: 16),

                  // Instructions
                  _buildInstructionsCard(),
                  const SizedBox(height: 16),

                  // Driver ID Inputs
                  _buildTextField(
                    controller: _driver1Controller,
                    label: 'Driver 1 UID (Juan dela Cruz)',
                    hint: 'e.g., abc123xyz789...',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _driver2Controller,
                    label: 'Driver 2 UID (Pedro Reyes)',
                    hint: 'e.g., def456uvw012...',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _driver3Controller,
                    label: 'Driver 3 UID (Carlos Mendoza)',
                    hint: 'e.g., ghi789rst345...',
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: _busesExist || _isSeeding ? null : _seedBuses,
                    icon: _busesExist
                        ? const Icon(Icons.check_circle)
                        : const Icon(Icons.upload),
                    label: Text(_busesExist ? 'Buses Already Exist' : 'Seed Buses'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _busesExist ? Colors.grey : AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Seed All Button
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Quick Seed Everything'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isSeeding ? null : _seedAll,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Seed All Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerDark),
      ),
      child: Row(
        children: [
          if (_isSeeding)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              _status.startsWith('✅') ? Icons.check_circle : Icons.info_outline,
              color: _status.startsWith('✅') ? Colors.green : AppColors.textSecondary,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _status,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingDataCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Existing Data',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusRow('Route', _routeExists),
          const SizedBox(height: 8),
          _buildStatusRow('Buses', _busesExist),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool exists) {
    return Row(
      children: [
        Icon(
          exists ? Icons.check_circle : Icons.cancel,
          color: exists ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          exists ? 'Exists' : 'Not Found',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInfoCard(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'How to get Driver UIDs',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1. Open Firebase Console\n'
            '2. Go to Authentication\n'
            '3. Find your driver users\n'
            '4. Copy their User UID\n'
            '5. Paste here',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.orange[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: AppColors.surfaceDark,
      ),
      style: GoogleFonts.inter(fontSize: 14),
    );
  }
}

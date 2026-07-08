import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/models/bus_model.dart';
import '../../../../shared/models/bus_progress_model.dart';
import '../controllers/driver_controller.dart';

class DriverActiveRouteTimelineScreen extends StatefulWidget {
  const DriverActiveRouteTimelineScreen({super.key});

  @override
  State<DriverActiveRouteTimelineScreen> createState() =>
      _DriverActiveRouteTimelineScreenState();
}

class _DriverActiveRouteTimelineScreenState
    extends State<DriverActiveRouteTimelineScreen> {
  final MapController _mapController = MapController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _updateBusProgress(String busId, String routeId, String stopId,
      int stopIndex, BusProgressStatus status) async {
    try {
      // Update busProgress collection
      await _firestore.collection('busProgress').doc(busId).set({
        'busId': busId,
        'routeId': routeId,
        'currentStopId': stopId,
        'currentStopIndex': stopIndex,
        'updatedAt': FieldValue.serverTimestamp(),
        'status': status.name,
      }, SetOptions(merge: true));

      // Also update the active trip if there is one
      final ctrl = Get.find<DriverController>();
      final activeTrip = ctrl.activeTrip.value;
      if (activeTrip != null) {
        await _firestore.collection('trips').doc(activeTrip.id).update({
          'currentStopIndex': stopIndex,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Show success feedback
      Get.snackbar(
        'Location Updated',
        'Your current stop has been updated',
        backgroundColor: AppColors.success.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      print('Error updating progress: $e');
      Get.snackbar(
        'Update Failed',
        'Could not update your location',
        backgroundColor: AppColors.error.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DriverController>();
    final route = BusRouteModel.mockRoutes.first;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Obx(() {
        final bus = ctrl.assignedBus.value;

        return Stack(
          children: [
            // Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: ctrl.currentPosition.value,
                initialZoom: 14,
                backgroundColor: const Color(0xFFF5F5F5), // Light gray background
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.evergo.evergo_bus_tracker',
                  retinaMode: true,
                ),
                // Route Polyline
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: route.polyline,
                      color: AppColors.accent.withValues(alpha: 0.8),
                      strokeWidth: 5,
                    ),
                  ],
                ),
                // Stop markers
                MarkerLayer(
                  markers: route.stops.map((stop) {
                    return Marker(
                      point: stop.position,
                      width: 32,
                      height: 32,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accent,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppColors.accent,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                // Driver's current position
                MarkerLayer(
                  markers: [
                    Marker(
                      point: ctrl.currentPosition.value,
                      width: 56,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.5),
                              blurRadius: 12,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_bus_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Top Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark.withValues(alpha: 0.97),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMd),
                            border: Border.all(color: AppColors.dividerDark),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.route_rounded,
                                color: AppColors.accent,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                route.name,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Location share toggle
                      GestureDetector(
                        onTap: () {
                          if (ctrl.isSharingLocation.value) {
                            ctrl.pauseTrip();
                          } else {
                            ctrl.resumeTrip();
                          }
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: ctrl.isSharingLocation.value
                                ? AppColors.success
                                : AppColors.cardDark,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: ctrl.isSharingLocation.value
                                  ? AppColors.success
                                  : AppColors.dividerDark,
                            ),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Icon(
                            ctrl.isSharingLocation.value
                                ? Icons.location_on_rounded
                                : Icons.location_off_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Map controls
            Positioned(
              right: AppSizes.md,
              bottom: 350,
              child: Column(
                children: [
                  _MapBtn(
                    icon: Icons.add_rounded,
                    onTap: () => _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MapBtn(
                    icon: Icons.remove_rounded,
                    onTap: () => _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MapBtn(
                    icon: Icons.my_location_rounded,
                    onTap: () {
                      _mapController.move(
                        ctrl.currentPosition.value,
                        14,
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom Sheet — Interactive Timeline
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                margin: const EdgeInsets.all(AppSizes.md),
                padding: const EdgeInsets.all(AppSizes.md),
                constraints: const BoxConstraints(maxHeight: 320),
                decoration: BoxDecoration(
                  color: AppColors.cardDark.withValues(alpha: 0.97),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                  border: Border.all(color: AppColors.dividerDark),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
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
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          'Route Progress',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          ctrl.isSharingLocation.value
                              ? '🟢 Sharing location'
                              : '🔴 Not sharing',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap on a stop to update your current location',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Interactive Timeline
                    Expanded(
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: bus != null
                            ? _firestore
                                .collection('busProgress')
                                .doc(bus.id)
                                .snapshots()
                            : null,
                        builder: (context, snapshot) {
                          int currentStopIndex = 0;
                          if (snapshot.hasData && snapshot.data != null) {
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>?;
                            currentStopIndex =
                                data?['currentStopIndex'] as int? ?? 0;
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: route.stops.length,
                            itemBuilder: (context, index) {
                              final stop = route.stops[index];
                              final isFirst = index == 0;
                              final isLast = index == route.stops.length - 1;
                              final isCurrent = index == currentStopIndex;
                              final isPassed = index < currentStopIndex;

                              return GestureDetector(
                                onTap: bus != null
                                    ? () => _updateBusProgress(
                                          bus.id,
                                          route.id,
                                          stop.id,
                                          index,
                                          BusProgressStatus.atStop,
                                        )
                                    : null,
                                child: Container(
                                  width: 140,
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? AppColors.accent
                                            .withValues(alpha: 0.15)
                                        : isPassed
                                            ? AppColors.success
                                                .withValues(alpha: 0.08)
                                            : AppColors.cardDark2,
                                    borderRadius:
                                        BorderRadius.circular(AppSizes.radiusMd),
                                    border: Border.all(
                                      color: isCurrent
                                          ? AppColors.accent
                                          : isPassed
                                              ? AppColors.success
                                                  .withValues(alpha: 0.3)
                                              : AppColors.dividerDark,
                                      width: isCurrent ? 2 : 1,
                                    ),
                                    boxShadow: isCurrent
                                        ? [
                                            BoxShadow(
                                              color: AppColors.accent
                                                  .withValues(alpha: 0.2),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: isCurrent
                                                  ? AppColors.accent
                                                  : isPassed
                                                      ? AppColors.success
                                                      : AppColors.dividerDark,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                isPassed
                                                    ? Icons.check_rounded
                                                    : isCurrent
                                                        ? Icons
                                                            .radio_button_checked_rounded
                                                        : Icons
                                                            .radio_button_unchecked_rounded,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              isFirst
                                                  ? 'START'
                                                  : isLast
                                                      ? 'END'
                                                      : 'STOP ${index + 1}',
                                              style: GoogleFonts.inter(
                                                fontSize: 9,
                                                color: isCurrent
                                                    ? AppColors.accent
                                                    : isPassed
                                                        ? AppColors.success
                                                        : AppColors.textMuted,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        stop.name,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (stop.estimatedTime != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time_rounded,
                                              size: 10,
                                              color: AppColors.textMuted,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              stop.estimatedTime!,
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (isCurrent) ...[
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'YOU ARE HERE',
                                            style: GoogleFonts.inter(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.cardDark.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.dividerDark),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}

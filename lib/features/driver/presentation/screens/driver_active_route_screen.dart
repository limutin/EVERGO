import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/models/bus_model.dart';
import '../controllers/driver_controller.dart';

class DriverActiveRouteScreen extends StatefulWidget {
  const DriverActiveRouteScreen({super.key});

  @override
  State<DriverActiveRouteScreen> createState() =>
      _DriverActiveRouteScreenState();
}

class _DriverActiveRouteScreenState extends State<DriverActiveRouteScreen> {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DriverController>();
    final route = BusRouteModel.mockRoutes.first;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Map
          Obx(() {
            final isReversed = ctrl.assignedBus.value?.isReversed ?? false;
            final directionalStops = route.getDirectionalStops(isReversed);
            final directionalPolyline = route.getDirectionalPolyline(isReversed);
            
            return FlutterMap(
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
                // Route Polyline (updates with direction)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: directionalPolyline,
                      color: AppColors.accent.withValues(alpha: 0.8),
                      strokeWidth: 5,
                    ),
                  ],
                ),
                // Stop markers (updates with direction)
                MarkerLayer(
                  markers: directionalStops.map((stop) {
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
            );
          }),

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
                            Expanded(
                              child: Obx(() {
                                final bus = ctrl.assignedBus.value;
                                final displayName = bus?.directionAwareRouteName ?? route.name;
                                return Text(
                                  displayName,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Direction toggle button (NEW!)
                    Obx(() => GestureDetector(
                          onTap: () => ctrl.toggleDirection(),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.cardDark.withValues(alpha: 0.97),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              ctrl.assignedBus.value?.isReversed == true
                                  ? Icons.arrow_back_rounded
                                  : Icons.arrow_forward_rounded,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ),
                        )),
                    const SizedBox(width: 10),
                    // Location share toggle (IMPROVED: Better visibility)
                    Obx(() => GestureDetector(
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
                                  : Colors.red.shade400, // Red when OFF for visibility
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: ctrl.isSharingLocation.value
                                    ? AppColors.success
                                    : Colors.red.shade600,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: ctrl.isSharingLocation.value
                                      ? AppColors.success.withValues(alpha: 0.3)
                                      : Colors.red.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              ctrl.isSharingLocation.value
                                  ? Icons.location_on_rounded
                                  : Icons.location_off_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),

          // Map controls
          Positioned(
            right: AppSizes.md,
            bottom: 200,
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
                    final ctrl = Get.find<DriverController>();
                    _mapController.move(
                      ctrl.currentPosition.value,
                      14,
                    );
                  },
                ),
              ],
            ),
          ),

          // Bottom Sheet — Stops
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.all(AppSizes.md),
              padding: const EdgeInsets.all(AppSizes.md),
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
                        'Route Stops',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Obx(() => Text(
                            ctrl.isSharingLocation.value
                                ? '🟢 Sharing location'
                                : '🔴 Not sharing',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 82),
                    child: Obx(() {
                      // Get stops in correct direction based on isReversed flag
                      final isReversed = ctrl.assignedBus.value?.isReversed ?? false;
                      final directionalStops = route.getDirectionalStops(isReversed);
                      
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: directionalStops.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final stop = directionalStops[i];
                          final isFirst = i == 0;
                          final isLast = i == directionalStops.length - 1;
                          return Container(
                            width: 130,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isFirst || isLast
                                  ? AppColors.accent.withValues(alpha: 0.08)
                                  : AppColors.cardDark2,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isFirst || isLast
                                    ? AppColors.accent.withValues(alpha: 0.3)
                                    : AppColors.dividerDark,
                              ),
                              boxShadow: AppColors.cardShadow,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isFirst
                                      ? 'START'
                                      : isLast
                                          ? 'END'
                                          : 'STOP ${i + 1}',
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  stop.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (stop.estimatedTime != null)
                                  Text(
                                    stop.estimatedTime!,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

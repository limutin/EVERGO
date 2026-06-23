import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/models/bus_model.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../controllers/commuter_controller.dart';

class CommuterMapScreen extends StatefulWidget {
  const CommuterMapScreen({super.key});

  @override
  State<CommuterMapScreen> createState() => _CommuterMapScreenState();
}

class _CommuterMapScreenState extends State<CommuterMapScreen> {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = CommuterController.to;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Map
          Obx(() => FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: ctrl.mapCenter.value,
                  initialZoom: ctrl.mapZoom.value,
                  backgroundColor: const Color(0xFF1A1F2E),
                  onTap: (_, __) => ctrl.clearSelectedBus(),
                ),
                children: [
                  // Dark Map Tiles
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.evergo.evergo_bus_tracker',
                  ),

                  // Route Polylines
                  PolylineLayer(
                    polylines: BusRouteModel.mockRoutes.map((route) {
                      return Polyline(
                        points: route.polyline,
                        color: AppColors.mapRoute.withOpacity(0.7),
                        strokeWidth: 4,
                      );
                    }).toList(),
                  ),

                  // Bus Markers
                  MarkerLayer(
                    markers: ctrl.nearbyBuses.map((bus) {
                      return Marker(
                        point: bus.position,
                        width: 48,
                        height: 48,
                        child: GestureDetector(
                          onTap: () => ctrl.selectBus(bus),
                          child: _BusMarker(bus: bus),
                        ),
                      );
                    }).toList(),
                  ),

                  // Stop Markers
                  MarkerLayer(
                    markers: BusRouteModel.mockRoutes
                        .expand((route) => route.stops)
                        .map((stop) {
                      return Marker(
                        point: stop.position,
                        width: 12,
                        height: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              )),

          // Top Search Bar
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
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark.withOpacity(0.95),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(color: AppColors.dividerDark),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.textMuted,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Search stops or routes...',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _MapActionBtn(
                      icon: Icons.layers_rounded,
                      onTap: () {},
                    ),
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
                _MapActionBtn(
                  icon: Icons.add_rounded,
                  onTap: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                ),
                const SizedBox(height: 8),
                _MapActionBtn(
                  icon: Icons.remove_rounded,
                  onTap: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                ),
                const SizedBox(height: 8),
                _MapActionBtn(
                  icon: Icons.my_location_rounded,
                  onTap: () {
                    _mapController.move(
                      const LatLng(8.2280, 123.3317),
                      13.0,
                    );
                  },
                ),
              ],
            ),
          ),

          // Bottom bus detail sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(() {
              final bus = ctrl.selectedBus.value;
              if (bus != null) {
                return _BusDetailSheet(bus: bus, ctrl: ctrl);
              }
              return _BusList(ctrl: ctrl);
            }),
          ),
        ],
      ),
    );
  }
}

class _BusMarker extends StatelessWidget {
  final BusModel bus;

  const _BusMarker({required this.bus});

  Color get _color {
    switch (bus.status) {
      case BusStatus.online:
        return AppColors.busOnline;
      case BusStatus.offline:
        return AppColors.busOffline;
      case BusStatus.idle:
        return AppColors.busIdle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _color.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.directions_bus_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

class _MapActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapActionBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.cardDark.withOpacity(0.95),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.dividerDark),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}

class _BusDetailSheet extends StatelessWidget {
  final BusModel bus;
  final CommuterController ctrl;

  const _BusDetailSheet({required this.bus, required this.ctrl});

  Color get _statusColor {
    switch (bus.status) {
      case BusStatus.online:
        return AppColors.busOnline;
      case BusStatus.offline:
        return AppColors.busOffline;
      case BusStatus.idle:
        return AppColors.busIdle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.dividerDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
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
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.directions_bus_rounded,
                  color: _statusColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          bus.busNumber,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          label: bus.statusLabel,
                          color: _statusColor,
                        ),
                      ],
                    ),
                    Text(
                      bus.routeName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textMuted, size: 20),
                onPressed: ctrl.clearSelectedBus,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats
          Row(
            children: [
              _DetailChip(
                icon: Icons.speed_rounded,
                label: '${bus.speed.toStringAsFixed(0)} km/h',
              ),
              const SizedBox(width: 8),
              _DetailChip(
                icon: Icons.people_rounded,
                label: '${bus.passengerCount}/${bus.capacity}',
              ),
              const SizedBox(width: 8),
              _DetailChip(
                icon: Icons.person_outlined,
                label: bus.driverName.split(' ').first,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Occupancy bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Occupancy',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${(bus.occupancyRate * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: bus.occupancyRate,
                  backgroundColor: AppColors.dividerDark,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    bus.occupancyRate > 0.8
                        ? AppColors.error
                        : bus.occupancyRate > 0.5
                            ? AppColors.warning
                            : AppColors.success,
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardDark2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dividerDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BusList extends StatelessWidget {
  final CommuterController ctrl;

  const _BusList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: AppSizes.md,
        right: AppSizes.md,
        bottom: AppSizes.md,
      ),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.cardDark.withOpacity(0.97),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.dividerDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
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
          Text(
            'Active Buses',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ctrl.nearbyBuses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final bus = ctrl.nearbyBuses[i];
                    final color = bus.status == BusStatus.online
                        ? AppColors.busOnline
                        : bus.status == BusStatus.idle
                            ? AppColors.busIdle
                            : AppColors.busOffline;
                    return GestureDetector(
                      onTap: () => ctrl.selectBus(bus),
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.dividerDark),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_bus_rounded,
                                  size: 14,
                                  color: color,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  bus.busNumber,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              bus.statusLabel,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${bus.speed.toStringAsFixed(0)} km/h',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )),
        ],
      ),
    );
  }
}

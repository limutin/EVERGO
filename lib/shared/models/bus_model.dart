import 'package:latlong2/latlong.dart';

/// Bus status
enum BusStatus { online, offline, idle }

/// Bus model
class BusModel {
  final String id;
  final String busNumber;
  final String plateNumber;
  final String driverName;
  final String routeId;
  final String routeName;
  final LatLng position;
  final BusStatus status;
  final double speed; // km/h
  final int passengerCount;
  final int capacity;
  final DateTime lastUpdated;
  final double heading; // degrees

  const BusModel({
    required this.id,
    required this.busNumber,
    required this.plateNumber,
    required this.driverName,
    required this.routeId,
    required this.routeName,
    required this.position,
    required this.status,
    this.speed = 0,
    this.passengerCount = 0,
    this.capacity = 50,
    required this.lastUpdated,
    this.heading = 0,
  });

  String get statusLabel {
    switch (status) {
      case BusStatus.online:
        return 'Online';
      case BusStatus.offline:
        return 'Offline';
      case BusStatus.idle:
        return 'Idle';
    }
  }

  double get occupancyRate => passengerCount / capacity;

  // Mock buses along Dipolog-Dapitan route
  static List<BusModel> mockBuses = [
    BusModel(
      id: 'bus001',
      busNumber: 'EG-001',
      plateNumber: 'ABC 1234',
      driverName: 'Juan dela Cruz',
      routeId: 'route001',
      routeName: 'Dipolog → Dapitan',
      position: const LatLng(8.2280, 123.3317),
      status: BusStatus.online,
      speed: 42.5,
      passengerCount: 32,
      capacity: 50,
      lastUpdated: DateTime.now(),
      heading: 45,
    ),
    BusModel(
      id: 'bus002',
      busNumber: 'EG-002',
      plateNumber: 'DEF 5678',
      driverName: 'Pedro Reyes',
      routeId: 'route001',
      routeName: 'Dapitan → Dipolog',
      position: const LatLng(8.2420, 123.3590),
      status: BusStatus.online,
      speed: 38.0,
      passengerCount: 28,
      capacity: 50,
      lastUpdated: DateTime.now(),
      heading: 225,
    ),
    BusModel(
      id: 'bus003',
      busNumber: 'EG-003',
      plateNumber: 'GHI 9012',
      driverName: 'Carlos Mendoza',
      routeId: 'route001',
      routeName: 'Dipolog → Dapitan',
      position: const LatLng(8.2150, 123.3150),
      status: BusStatus.idle,
      speed: 0,
      passengerCount: 0,
      capacity: 50,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
      heading: 0,
    ),
    BusModel(
      id: 'bus004',
      busNumber: 'EG-004',
      plateNumber: 'JKL 3456',
      driverName: 'Roberto Garcia',
      routeId: 'route002',
      routeName: 'Dipolog → Sindangan',
      position: const LatLng(8.2310, 123.3450),
      status: BusStatus.offline,
      speed: 0,
      passengerCount: 0,
      capacity: 50,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
      heading: 90,
    ),
  ];
}

/// Route stop model
class RouteStop {
  final String id;
  final String name;
  final LatLng position;
  final int orderIndex;
  final String? estimatedTime;

  const RouteStop({
    required this.id,
    required this.name,
    required this.position,
    required this.orderIndex,
    this.estimatedTime,
  });
}

/// Bus route model
class BusRouteModel {
  final String id;
  final String name;
  final String description;
  final List<RouteStop> stops;
  final List<LatLng> polyline;
  final String distance; // e.g. "22 km"
  final String duration; // e.g. "45 min"
  final double fare;
  final int activeBuses;
  final bool isActive;

  const BusRouteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.stops,
    required this.polyline,
    required this.distance,
    required this.duration,
    required this.fare,
    this.activeBuses = 0,
    this.isActive = true,
  });

  static List<BusRouteModel> mockRoutes = [
    BusRouteModel(
      id: 'route001',
      name: 'Dipolog → Dapitan',
      description: 'Main route via Baroy and Linabo Peak junction',
      stops: [
        RouteStop(
          id: 's1',
          name: 'Dipolog City Terminal',
          position: const LatLng(8.2280, 123.3317),
          orderIndex: 0,
          estimatedTime: '7:00 AM',
        ),
        RouteStop(
          id: 's2',
          name: 'Dipolog Airport',
          position: const LatLng(8.2350, 123.3400),
          orderIndex: 1,
          estimatedTime: '7:08 AM',
        ),
        RouteStop(
          id: 's3',
          name: 'Baroy Junction',
          position: const LatLng(8.2420, 123.3590),
          orderIndex: 2,
          estimatedTime: '7:18 AM',
        ),
        RouteStop(
          id: 's4',
          name: 'Linabo Peak Junction',
          position: const LatLng(8.2600, 123.3800),
          orderIndex: 3,
          estimatedTime: '7:32 AM',
        ),
        RouteStop(
          id: 's5',
          name: 'Dapitan City Terminal',
          position: const LatLng(8.6500, 123.4200),
          orderIndex: 4,
          estimatedTime: '7:45 AM',
        ),
      ],
      polyline: [
        const LatLng(8.2280, 123.3317),
        const LatLng(8.2350, 123.3400),
        const LatLng(8.2420, 123.3590),
        const LatLng(8.2600, 123.3800),
        const LatLng(8.6500, 123.4200),
      ],
      distance: '22 km',
      duration: '45 min',
      fare: 28.00,
      activeBuses: 3,
    ),
    BusRouteModel(
      id: 'route002',
      name: 'Dipolog → Sindangan',
      description: 'Northern route via Polanco and Jose Dalman',
      stops: [
        RouteStop(
          id: 's6',
          name: 'Dipolog City Terminal',
          position: const LatLng(8.2280, 123.3317),
          orderIndex: 0,
          estimatedTime: '6:00 AM',
        ),
        RouteStop(
          id: 's7',
          name: 'Polanco Town Proper',
          position: const LatLng(8.5000, 123.3600),
          orderIndex: 1,
          estimatedTime: '6:35 AM',
        ),
        RouteStop(
          id: 's8',
          name: 'Sindangan Terminal',
          position: const LatLng(8.2280, 122.9999),
          orderIndex: 2,
          estimatedTime: '7:30 AM',
        ),
      ],
      polyline: [
        const LatLng(8.2280, 123.3317),
        const LatLng(8.5000, 123.3600),
        const LatLng(8.2280, 122.9999),
      ],
      distance: '54 km',
      duration: '1h 30min',
      fare: 65.00,
      activeBuses: 1,
    ),
  ];
}

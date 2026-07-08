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

  // Mock buses for Dipolog ↔ Dapitan route
  static List<BusModel> mockBuses = [
    BusModel(
      id: 'bus001',
      busNumber: 'EG-001',
      plateNumber: 'ABC 1234',
      driverName: 'Juan dela Cruz',
      routeId: 'route001',
      routeName: 'Dipolog ↔ Dapitan',
      position: const LatLng(8.6450, 123.4050), // At Polo
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
      routeName: 'Dipolog ↔ Dapitan',
      position: const LatLng(8.7050, 123.4650), // At Larayan
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
      routeName: 'Dipolog ↔ Dapitan',
      position: const LatLng(8.5834, 123.3417), // At Dipolog Terminal
      status: BusStatus.idle,
      speed: 0,
      passengerCount: 0,
      capacity: 50,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
      heading: 0,
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

  // Single route: Dipolog ↔ Dapitan (Based on Evergood Transportation ticket)
  static List<BusRouteModel> mockRoutes = [
    const BusRouteModel(
      id: 'route001',
      name: 'Dipolog ↔ Dapitan',
      description: 'Via Minaog, Lawa-an, Polo, San Pedro, Owawon, Larayan, Upper Sicayab, and Sicayab',
      stops: [
        RouteStop(
          id: 's1',
          name: 'Dipolog',
          position: LatLng(8.5834, 123.3417), // Dipolog City
          orderIndex: 0,
        ),
        RouteStop(
          id: 's2',
          name: 'Minaog',
          position: LatLng(8.6050, 123.3650),
          orderIndex: 1,
        ),
        RouteStop(
          id: 's3',
          name: 'Lawa-an',
          position: LatLng(8.6250, 123.3850),
          orderIndex: 2,
        ),
        RouteStop(
          id: 's4',
          name: 'Polo',
          position: LatLng(8.6450, 123.4050),
          orderIndex: 3,
        ),
        RouteStop(
          id: 's5',
          name: 'San Pedro',
          position: LatLng(8.6650, 123.4250),
          orderIndex: 4,
        ),
        RouteStop(
          id: 's6',
          name: 'Owawon',
          position: LatLng(8.6850, 123.4450),
          orderIndex: 5,
        ),
        RouteStop(
          id: 's7',
          name: 'Larayan',
          position: LatLng(8.7050, 123.4650),
          orderIndex: 6,
        ),
        RouteStop(
          id: 's8',
          name: 'Upper Sicayab',
          position: LatLng(8.7250, 123.4850),
          orderIndex: 7,
        ),
        RouteStop(
          id: 's9',
          name: 'Sicayab',
          position: LatLng(8.7450, 123.5050),
          orderIndex: 8,
        ),
        RouteStop(
          id: 's10',
          name: 'Dapitan',
          position: LatLng(8.6500, 123.4242), // Dapitan City
          orderIndex: 9,
        ),
      ],
      polyline: [
        LatLng(8.5834, 123.3417), // Dipolog
        LatLng(8.6050, 123.3650), // Minaog
        LatLng(8.6250, 123.3850), // Lawa-an
        LatLng(8.6450, 123.4050), // Polo
        LatLng(8.6650, 123.4250), // San Pedro
        LatLng(8.6850, 123.4450), // Owawon
        LatLng(8.7050, 123.4650), // Larayan
        LatLng(8.7250, 123.4850), // Upper Sicayab
        LatLng(8.7450, 123.5050), // Sicayab
        LatLng(8.6500, 123.4242), // Dapitan
      ],
      distance: '53 km',
      duration: '1h 30min',
      fare: 0, // No fare system
      activeBuses: 3,
    ),
  ];
}

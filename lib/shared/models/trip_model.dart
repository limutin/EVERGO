import 'package:cloud_firestore/cloud_firestore.dart';

/// Unified Trip model for both commuters and drivers
class TripModel {
  final String id;
  final String busId;
  final String busNumber;
  final String plateNumber;
  final String driverName;
  final String driverId;
  final String routeId;
  final String routeName;
  final String departureTime;
  final String arrivalTime;
  final String? estimatedArrival;
  final double fare;
  final TripStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int currentStopIndex;
  final int totalStops;
  final int passengerCount;
  final int capacity;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TripModel({
    required this.id,
    required this.busId,
    required this.busNumber,
    required this.plateNumber,
    required this.driverName,
    required this.driverId,
    required this.routeId,
    required this.routeName,
    required this.departureTime,
    required this.arrivalTime,
    this.estimatedArrival,
    required this.fare,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.currentStopIndex = 0,
    required this.totalStops,
    this.passengerCount = 0,
    required this.capacity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TripModel(
      id: doc.id,
      busId: data['busId'] as String,
      busNumber: data['busNumber'] as String,
      plateNumber: data['plateNumber'] as String,
      driverName: data['driverName'] as String,
      driverId: data['driverId'] as String,
      routeId: data['routeId'] as String,
      routeName: data['routeName'] as String,
      departureTime: data['departureTime'] as String,
      arrivalTime: data['arrivalTime'] as String,
      estimatedArrival: data['estimatedArrival'] as String?,
      fare: (data['fare'] as num).toDouble(),
      status: _parseStatus(data['status'] as String?),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      currentStopIndex: data['currentStopIndex'] as int? ?? 0,
      totalStops: data['totalStops'] as int,
      passengerCount: data['passengerCount'] as int? ?? 0,
      capacity: data['capacity'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'busId': busId,
      'busNumber': busNumber,
      'plateNumber': plateNumber,
      'driverName': driverName,
      'driverId': driverId,
      'routeId': routeId,
      'routeName': routeName,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'estimatedArrival': estimatedArrival,
      'fare': fare,
      'status': status.name,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'currentStopIndex': currentStopIndex,
      'totalStops': totalStops,
      'passengerCount': passengerCount,
      'capacity': capacity,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static TripStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'scheduled':
        return TripStatus.scheduled;
      case 'in_progress':
        return TripStatus.inProgress;
      case 'completed':
        return TripStatus.completed;
      case 'cancelled':
        return TripStatus.cancelled;
      default:
        return TripStatus.scheduled;
    }
  }

  TripModel copyWith({
    String? id,
    String? busId,
    String? busNumber,
    String? plateNumber,
    String? driverName,
    String? driverId,
    String? routeId,
    String? routeName,
    String? departureTime,
    String? arrivalTime,
    String? estimatedArrival,
    double? fare,
    TripStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    int? currentStopIndex,
    int? totalStops,
    int? passengerCount,
    int? capacity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      busId: busId ?? this.busId,
      busNumber: busNumber ?? this.busNumber,
      plateNumber: plateNumber ?? this.plateNumber,
      driverName: driverName ?? this.driverName,
      driverId: driverId ?? this.driverId,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      fare: fare ?? this.fare,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      currentStopIndex: currentStopIndex ?? this.currentStopIndex,
      totalStops: totalStops ?? this.totalStops,
      passengerCount: passengerCount ?? this.passengerCount,
      capacity: capacity ?? this.capacity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get vacantSeats => capacity - passengerCount;
  double get occupancyPercentage => (passengerCount / capacity * 100);
  bool get isActive => status == TripStatus.inProgress;
  bool get isScheduled => status == TripStatus.scheduled;
  bool get isCompleted => status == TripStatus.completed;
}

enum TripStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
}

extension TripStatusExtension on TripStatus {
  String get label {
    switch (this) {
      case TripStatus.scheduled:
        return 'Scheduled';
      case TripStatus.inProgress:
        return 'In Progress';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }
}

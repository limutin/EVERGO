/// Model for tracking bus progress along a route
class BusProgressModel {
  final String busId;
  final String routeId;
  final String currentStopId;
  final int currentStopIndex;
  final DateTime updatedAt;
  final BusProgressStatus status;

  const BusProgressModel({
    required this.busId,
    required this.routeId,
    required this.currentStopId,
    required this.currentStopIndex,
    required this.updatedAt,
    required this.status,
  });

  factory BusProgressModel.fromFirestore(Map<String, dynamic> data) {
    return BusProgressModel(
      busId: data['busId'] as String? ?? '',
      routeId: data['routeId'] as String? ?? '',
      currentStopId: data['currentStopId'] as String? ?? '',
      currentStopIndex: data['currentStopIndex'] as int? ?? 0,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as dynamic).toDate()
          : DateTime.now(),
      status: _parseStatus(data['status'] as String?),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'busId': busId,
      'routeId': routeId,
      'currentStopId': currentStopId,
      'currentStopIndex': currentStopIndex,
      'updatedAt': updatedAt,
      'status': status.name,
    };
  }

  static BusProgressStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'at_stop':
        return BusProgressStatus.atStop;
      case 'in_transit':
        return BusProgressStatus.inTransit;
      case 'completed':
        return BusProgressStatus.completed;
      default:
        return BusProgressStatus.inTransit;
    }
  }

  BusProgressModel copyWith({
    String? busId,
    String? routeId,
    String? currentStopId,
    int? currentStopIndex,
    DateTime? updatedAt,
    BusProgressStatus? status,
  }) {
    return BusProgressModel(
      busId: busId ?? this.busId,
      routeId: routeId ?? this.routeId,
      currentStopId: currentStopId ?? this.currentStopId,
      currentStopIndex: currentStopIndex ?? this.currentStopIndex,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }
}

enum BusProgressStatus {
  atStop,
  inTransit,
  completed,
}

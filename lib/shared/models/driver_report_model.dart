/// Driver report model
class DriverReport {
  final String id;
  final String type;
  final String description;
  final DateTime timestamp;
  final String status;

  const DriverReport({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.status,
  });

  factory DriverReport.fromMap(Map<String, dynamic> map) {
    return DriverReport(
      id: map['id'] as String,
      type: map['type'] as String,
      description: map['description'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }
}

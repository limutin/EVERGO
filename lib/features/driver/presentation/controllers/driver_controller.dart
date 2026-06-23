import 'dart:async';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../../shared/models/bus_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

enum TripStatus { notStarted, inProgress, completed, paused }

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

  static List<DriverReport> mockReports = [
    DriverReport(
      id: 'r001',
      type: 'Delay',
      description: 'Road construction near Baroy Junction caused 15-min delay.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      status: 'Submitted',
    ),
    DriverReport(
      id: 'r002',
      type: 'Maintenance',
      description: 'Left rear tire needs replacement.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Reviewed',
    ),
    DriverReport(
      id: 'r003',
      type: 'Incident',
      description: 'Minor collision at Dipolog Airport junction. No injuries.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Resolved',
    ),
  ];
}

class DriverScheduleEntry {
  final String routeName;
  final String departure;
  final String arrival;
  final String busNumber;
  final bool isCompleted;
  final bool isCurrent;

  const DriverScheduleEntry({
    required this.routeName,
    required this.departure,
    required this.arrival,
    required this.busNumber,
    this.isCompleted = false,
    this.isCurrent = false,
  });

  static List<DriverScheduleEntry> mockSchedule = const [
    DriverScheduleEntry(
      routeName: 'Dipolog → Dapitan',
      departure: '6:00 AM',
      arrival: '6:45 AM',
      busNumber: 'EG-001',
      isCompleted: true,
    ),
    DriverScheduleEntry(
      routeName: 'Dapitan → Dipolog',
      departure: '7:00 AM',
      arrival: '7:45 AM',
      busNumber: 'EG-001',
      isCompleted: true,
    ),
    DriverScheduleEntry(
      routeName: 'Dipolog → Dapitan',
      departure: '9:00 AM',
      arrival: '9:45 AM',
      busNumber: 'EG-001',
      isCurrent: true,
    ),
    DriverScheduleEntry(
      routeName: 'Dapitan → Dipolog',
      departure: '10:00 AM',
      arrival: '10:45 AM',
      busNumber: 'EG-001',
    ),
    DriverScheduleEntry(
      routeName: 'Dipolog → Dapitan',
      departure: '12:00 PM',
      arrival: '12:45 PM',
      busNumber: 'EG-001',
    ),
  ];
}

class DriverController extends GetxController {
  static DriverController get to => Get.find();

  final RxInt selectedTabIndex = 0.obs;
  final Rx<TripStatus> tripStatus = TripStatus.notStarted.obs;
  final RxBool isSharingLocation = false.obs;
  final RxDouble currentSpeed = 0.0.obs;
  final RxInt passengerCount = 0.obs;
  final RxInt todayTrips = 3.obs;
  final RxDouble totalDistance = 66.5.obs;
  final RxList<DriverReport> reports = <DriverReport>[].obs;
  final RxList<DriverScheduleEntry> schedule = <DriverScheduleEntry>[].obs;
  final Rx<LatLng> currentPosition =
      const LatLng(8.2280, 123.3317).obs;

  Timer? _locationTimer;
  Timer? _speedTimer;

  @override
  void onInit() {
    super.onInit();
    reports.assignAll(DriverReport.mockReports);
    schedule.assignAll(DriverScheduleEntry.mockSchedule);
  }

  @override
  void onClose() {
    _locationTimer?.cancel();
    _speedTimer?.cancel();
    super.onClose();
  }

  UserModel? get currentUser =>
      Get.find<AuthController>().currentUser.value;

  String get assignedBusNumber => 'EG-001';
  String get assignedRoute => 'Dipolog ↔ Dapitan';

  void changeTab(int index) => selectedTabIndex.value = index;

  void startTrip() {
    tripStatus.value = TripStatus.inProgress;
    isSharingLocation.value = true;
    _startLocationSimulation();
  }

  void pauseTrip() {
    tripStatus.value = TripStatus.paused;
    _locationTimer?.cancel();
    currentSpeed.value = 0;
  }

  void resumeTrip() {
    tripStatus.value = TripStatus.inProgress;
    _startLocationSimulation();
  }

  void endTrip() {
    tripStatus.value = TripStatus.completed;
    isSharingLocation.value = false;
    _locationTimer?.cancel();
    _speedTimer?.cancel();
    currentSpeed.value = 0;
    todayTrips.value++;
  }

  void _startLocationSimulation() {
    _locationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final current = currentPosition.value;
      currentPosition.value = LatLng(
        current.latitude + 0.0002,
        current.longitude + 0.0001,
      );
      currentSpeed.value =
          30 + (DateTime.now().second % 20).toDouble();
    });
  }

  void updatePassengerCount(int count) {
    passengerCount.value = count;
  }

  void submitReport({
    required String type,
    required String description,
  }) {
    final report = DriverReport(
      id: 'r${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      description: description,
      timestamp: DateTime.now(),
      status: 'Submitted',
    );
    reports.insert(0, report);
  }

  String get tripStatusLabel {
    switch (tripStatus.value) {
      case TripStatus.notStarted:
        return 'Ready to Start';
      case TripStatus.inProgress:
        return 'Trip in Progress';
      case TripStatus.paused:
        return 'Trip Paused';
      case TripStatus.completed:
        return 'Trip Completed';
    }
  }
}

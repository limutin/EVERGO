import 'dart:async';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../../shared/models/bus_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class CommuterController extends GetxController {
  static CommuterController get to => Get.find();

  final RxInt selectedTabIndex = 0.obs;
  final RxList<BusModel> nearbyBuses = <BusModel>[].obs;
  final RxList<BusRouteModel> routes = <BusRouteModel>[].obs;
  final Rx<BusModel?> selectedBus = Rx<BusModel?>(null);
  final RxBool isLoadingBuses = false.obs;
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;

  // Map center (Dipolog City)
  final Rx<LatLng> mapCenter = const LatLng(8.2280, 123.3317).obs;
  final RxDouble mapZoom = 13.0.obs;

  Timer? _locationUpdateTimer;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    _startBusLocationUpdates();
    _loadMockNotifications();
  }

  @override
  void onClose() {
    _locationUpdateTimer?.cancel();
    super.onClose();
  }

  UserModel? get currentUser => Get.find<AuthController>().currentUser.value;

  void _loadInitialData() {
    nearbyBuses.assignAll(BusModel.mockBuses);
    routes.assignAll(BusRouteModel.mockRoutes);
  }

  void _startBusLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _simulateBusMovement(),
    );
  }

  void _simulateBusMovement() {
    final updated = nearbyBuses.map((bus) {
      if (bus.status == BusStatus.online) {
        // Slightly move buses to simulate real-time tracking
        final newLat =
            bus.position.latitude + (0.0001 * (DateTime.now().second % 2 == 0 ? 1 : -1));
        final newLng =
            bus.position.longitude + (0.0001 * (DateTime.now().second % 3 == 0 ? 1 : -1));
        return BusModel(
          id: bus.id,
          busNumber: bus.busNumber,
          plateNumber: bus.plateNumber,
          driverName: bus.driverName,
          routeId: bus.routeId,
          routeName: bus.routeName,
          position: LatLng(newLat, newLng),
          status: bus.status,
          speed: 35 + (DateTime.now().second % 15).toDouble(),
          passengerCount: bus.passengerCount,
          capacity: bus.capacity,
          lastUpdated: DateTime.now(),
          heading: bus.heading,
        );
      }
      return bus;
    }).toList();
    nearbyBuses.assignAll(updated);
  }

  void selectBus(BusModel bus) {
    selectedBus.value = bus;
    mapCenter.value = bus.position;
    mapZoom.value = 15.0;
  }

  void clearSelectedBus() {
    selectedBus.value = null;
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  int get onlineBusCount =>
      nearbyBuses.where((b) => b.status == BusStatus.online).length;

  int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;

  void markNotificationAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
    }
  }

  void markAllNotificationsRead() {
    for (var i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
  }

  void _loadMockNotifications() {
    notifications.assignAll([
      NotificationItem(
        id: 'n1',
        title: 'Bus EG-001 is nearby',
        body: 'Your bus is 2 stops away — estimated arrival in 5 minutes.',
        type: NotificationType.arrival,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      NotificationItem(
        id: 'n2',
        title: 'Schedule Update',
        body:
            'The 8:30 AM Dipolog → Dapitan trip has been rescheduled to 8:45 AM.',
        type: NotificationType.schedule,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: true,
      ),
      NotificationItem(
        id: 'n3',
        title: 'New Route Available',
        body: 'Express service from Dipolog to Dapitan now available on weekends.',
        type: NotificationType.info,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationItem(
        id: 'n4',
        title: 'Trip Delayed',
        body: 'Bus EG-003 on the Dipolog → Dapitan route is running 15 minutes late.',
        type: NotificationType.delay,
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        isRead: true,
      ),
    ]);
  }
}

enum NotificationType { arrival, schedule, delay, info }

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Schedule model
class ScheduleEntry {
  final String busNumber;
  final String routeName;
  final String departure;
  final String arrival;
  final String days;
  final bool isActive;
  final double fare;

  const ScheduleEntry({
    required this.busNumber,
    required this.routeName,
    required this.departure,
    required this.arrival,
    required this.days,
    this.isActive = true,
    required this.fare,
  });

  static List<ScheduleEntry> mockSchedules = [
    ScheduleEntry(
      busNumber: 'EG-001',
      routeName: 'Dipolog → Dapitan',
      departure: '6:00 AM',
      arrival: '6:45 AM',
      days: 'Mon - Sun',
      fare: 28,
    ),
    ScheduleEntry(
      busNumber: 'EG-002',
      routeName: 'Dipolog → Dapitan',
      departure: '7:30 AM',
      arrival: '8:15 AM',
      days: 'Mon - Sun',
      fare: 28,
    ),
    ScheduleEntry(
      busNumber: 'EG-003',
      routeName: 'Dipolog → Dapitan',
      departure: '9:00 AM',
      arrival: '9:45 AM',
      days: 'Mon - Sat',
      fare: 28,
    ),
    ScheduleEntry(
      busNumber: 'EG-001',
      routeName: 'Dapitan → Dipolog',
      departure: '7:00 AM',
      arrival: '7:45 AM',
      days: 'Mon - Sun',
      fare: 28,
    ),
    ScheduleEntry(
      busNumber: 'EG-002',
      routeName: 'Dapitan → Dipolog',
      departure: '8:30 AM',
      arrival: '9:15 AM',
      days: 'Mon - Sun',
      fare: 28,
    ),
    ScheduleEntry(
      busNumber: 'EG-004',
      routeName: 'Dipolog → Sindangan',
      departure: '6:00 AM',
      arrival: '7:30 AM',
      days: 'Mon - Fri',
      fare: 65,
    ),
    ScheduleEntry(
      busNumber: 'EG-004',
      routeName: 'Dipolog → Sindangan',
      departure: '12:00 PM',
      arrival: '1:30 PM',
      days: 'Mon - Fri',
      fare: 65,
    ),
  ];
}

import 'dart:async';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../../shared/models/bus_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/notification_model.dart';
import '../../../../shared/models/trip_model.dart';
import '../../../../shared/services/bus_service.dart';
import '../../../../shared/services/notification_service.dart';
import '../../../../shared/services/trip_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class CommuterController extends GetxController {
  static CommuterController get to => Get.find();

  // Services
  final _busService = BusService();
  final _notificationService = NotificationService();
  final _tripService = TripService();

  // Observables
  final RxInt selectedTabIndex = 0.obs;
  final RxList<BusModel> nearbyBuses = <BusModel>[].obs;
  final RxList<BusRouteModel> routes = <BusRouteModel>[].obs;
  final RxList<TripModel> activeTrips = <TripModel>[].obs;
  final Rx<BusModel?> selectedBus = Rx<BusModel?>(null);
  final RxBool isLoadingBuses = false.obs;
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;

  // Map center (Dipolog City)
  final Rx<LatLng> mapCenter = const LatLng(8.2280, 123.3317).obs;
  final RxDouble mapZoom = 13.0.obs;

  // Subscriptions
  StreamSubscription? _busesSubscription;
  StreamSubscription? _routesSubscription;
  StreamSubscription? _notificationsSubscription;
  StreamSubscription? _tripsSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  @override
  void onClose() {
    _busesSubscription?.cancel();
    _routesSubscription?.cancel();
    _notificationsSubscription?.cancel();
    _tripsSubscription?.cancel();
    super.onClose();
  }

  /// Initialize data streams from Firebase
  void _initializeData() {
    isLoadingBuses.value = true;

    // Watch buses
    _busesSubscription = _busService.watchActiveBuses().listen(
      (buses) {
        nearbyBuses.value = buses;
        isLoadingBuses.value = false;
      },
      onError: (error) {
        print('Error loading buses: $error');
        isLoadingBuses.value = false;
        // Fallback to mock data if Firebase fails
        nearbyBuses.assignAll(BusModel.mockBuses);
      },
    );

    // Watch routes
    _routesSubscription = _busService.watchRoutes().listen(
      (routesList) {
        routes.value = routesList;
      },
      onError: (error) {
        print('Error loading routes: $error');
        // Fallback to mock data if Firebase fails
        routes.assignAll(BusRouteModel.mockRoutes);
      },
    );

    // Watch notifications
    _notificationsSubscription =
        _notificationService.watchUserNotifications().listen(
      (notifs) {
        notifications.value = notifs;
      },
      onError: (error) {
        print('Error loading notifications: $error');
      },
    );
    // Watch active trips
    _tripsSubscription = _tripService.watchActiveTrips().listen(
      (tripsList) {
        activeTrips.value = tripsList;
      },
      onError: (error) {
        print('Error loading active trips: $error');
      },
    );
  }

  UserModel? get currentUser => Get.find<AuthController>().currentUser.value;

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

  void setTabFromRoute(String routeName) {
    switch (routeName) {
      case '/commuter/dashboard':
        selectedTabIndex.value = 0;
        break;
      case '/commuter/map':
        selectedTabIndex.value = 1;
        break;
      case '/commuter/routes':
        selectedTabIndex.value = 2;
        break;
      case '/commuter/profile':
        selectedTabIndex.value = 3;
        break;
    }
  }

  int get onlineBusCount =>
      nearbyBuses.where((b) => b.status == BusStatus.online).length;

  int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;

  void markNotificationAsRead(String id) {
    _notificationService.markAsRead(id);
  }

  void markAllNotificationsRead() {
    _notificationService.markAllAsRead();
  }

  /// Refresh data manually
  void refreshData() {
    isLoadingBuses.value = true;
    // Streams will automatically update
    Future.delayed(const Duration(seconds: 1), () {
      isLoadingBuses.value = false;
    });
  }
}

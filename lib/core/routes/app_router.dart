import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/commuter/presentation/widgets/commuter_nav_bar.dart';
import '../../features/commuter/presentation/screens/commuter_dashboard_screen.dart';
import '../../features/commuter/presentation/screens/commuter_map_screen.dart';
import '../../features/commuter/presentation/screens/commuter_routes_screen.dart';
import '../../features/commuter/presentation/screens/commuter_notifications_screen.dart';
import '../../features/commuter/presentation/screens/commuter_profile_screen.dart';
import '../../features/driver/presentation/widgets/driver_nav_bar.dart';
import '../../features/driver/presentation/screens/driver_dashboard_screen.dart';
import '../../features/driver/presentation/screens/driver_active_route_timeline_screen.dart';
import '../../features/driver/presentation/screens/driver_routes_screen.dart';
import '../../features/driver/presentation/screens/driver_reports_screen.dart';
import '../../features/driver/presentation/screens/driver_profile_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    routes: [
      // Auth Routes
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SplashScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => _fadeTransitionPage(
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.roleSelection,
        name: 'role-selection',
        pageBuilder: (context, state) => _slideUpPage(
          state: state,
          child: const RoleSelectionScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        pageBuilder: (context, state) => _slideUpPage(
          state: state,
          child: const LoginScreen(),
        ),
        routes: [
          GoRoute(
            path: 'signup',
            name: 'signup',
            pageBuilder: (context, state) => _slideUpPage(
              state: state,
              child: const SignupScreen(),
            ),
          ),
          GoRoute(
            path: 'forgot-password',
            name: 'forgot-password',
            pageBuilder: (context, state) => _slideUpPage(
              state: state,
              child: const ForgotPasswordScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.signup,
        name: 'signup-standalone',
        pageBuilder: (context, state) => _slideUpPage(
          state: state,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgot-password-standalone',
        pageBuilder: (context, state) => _slideUpPage(
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),

      // Commuter Shell
      ShellRoute(
        builder: (context, state, child) => CommuterShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.commuterDashboard,
            name: 'commuter-dashboard',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const CommuterDashboardScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.commuterMap,
            name: 'commuter-map',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const CommuterMapScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.commuterRoutes,
            name: 'commuter-routes',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const CommuterRoutesScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.commuterNotifications,
            name: 'commuter-notifications',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const CommuterNotificationsScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.commuterProfile,
            name: 'commuter-profile',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const CommuterProfileScreen(),
            ),
          ),
        ],
      ),

      // Driver Shell
      ShellRoute(
        builder: (context, state, child) => DriverShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.driverDashboard,
            name: 'driver-dashboard',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const DriverDashboardScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.driverActiveRoute,
            name: 'driver-active-route',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const DriverActiveRouteTimelineScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.driverRoutes,
            name: 'driver-routes',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const DriverRoutesScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.driverReports,
            name: 'driver-reports',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const DriverReportsScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.driverProfile,
            name: 'driver-profile',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const DriverProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );

  static CustomTransitionPage _fadeTransitionPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage _slideUpPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut));
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }
}

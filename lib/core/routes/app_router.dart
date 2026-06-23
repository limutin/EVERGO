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
import '../../features/driver/presentation/widgets/driver_nav_bar.dart';

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
        builder: (context, state, child) => const CommuterShell(),
        routes: [
          GoRoute(
            path: RouteNames.commuterDashboard,
            name: 'commuter-dashboard',
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: RouteNames.commuterMap,
            name: 'commuter-map',
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: RouteNames.commuterRoutes,
            name: 'commuter-routes',
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: RouteNames.commuterSchedules,
            name: 'commuter-schedules',
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: RouteNames.commuterNotifications,
            name: 'commuter-notifications',
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: RouteNames.commuterProfile,
            name: 'commuter-profile',
            builder: (context, state) => const SizedBox.shrink(),
          ),
        ],
      ),

      // Driver Shell
      ShellRoute(
        builder: (context, state, child) => const DriverShell(),
        routes: [
          GoRoute(
            path: RouteNames.driverDashboard,
            name: 'driver-dashboard',
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: RouteNames.driverActiveRoute,
            name: 'driver-active-route',
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: RouteNames.driverSchedule,
            name: 'driver-schedule',
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: RouteNames.driverReports,
            name: 'driver-reports',
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: RouteNames.driverProfile,
            name: 'driver-profile',
            builder: (context, state) => const SizedBox.shrink(),
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
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
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

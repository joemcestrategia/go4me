import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go4me/features/home/home_page.dart';
import 'package:go4me/features/donor/donor_dashboard.dart';
import 'package:go4me/features/missionary/missionary_main_page.dart';
import 'package:go4me/features/auth/login_page.dart';
import 'package:go4me/features/auth/onboarding_page.dart';
import 'package:go4me/features/auth/controllers/auth_controller.dart';
import 'package:go4me/features/missionary/stripe_tutorial_page.dart';
import 'package:go4me/features/landing/missionary_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider).value;
  final isAuthenticated = authState?.session != null;

  final userProfile = ref.watch(userProfileProvider).value;
  final userRole = userProfile?.role?.name;

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final location = state.matchedLocation;

      final isPublicRoute = location == '/' ||
          location == '/login' ||
          location == '/onboarding' ||
          location == '/forgot-password' ||
          location.startsWith('/m/');

      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      if (isAuthenticated && (location == '/login' || location == '/onboarding')) {
        if (userRole == 'missionary') {
          return '/missionary';
        }
        return '/donor';
      }

      if (isAuthenticated && location == '/') {
        if (userRole == 'missionary') {
          return '/missionary';
        }
        return '/donor';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      GoRoute(
        path: '/donor',
        builder: (context, state) => const DonorDashboard(),
      ),

      GoRoute(
        path: '/missionary',
        builder: (context, state) => const MissionaryMainPage(),
        routes: [
          GoRoute(
            path: 'stripe-tutorial',
            builder: (context, state) => const StripeTutorialPage(),
          ),
        ],
      ),

      GoRoute(
        path: '/m/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return MissionaryPage(slug: slug);
        },
      ),
    ],
  );
});

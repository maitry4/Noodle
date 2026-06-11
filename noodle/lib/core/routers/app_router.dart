// ignore: dangling_library_doc_comments
/// This page will have go_router Navigation.
import 'package:go_router/go_router.dart';
import 'package:noodle/features/brain/presentation/floating_character.dart';
import 'package:noodle/features/onboarding/presentation/pages/onboarding_screen1.dart';
import 'package:noodle/features/onboarding/presentation/pages/onboarding_screen2.dart';
import 'package:noodle/features/onboarding/presentation/pages/onboarding_screen3.dart';
import 'package:noodle/features/onboarding/presentation/pages/onboarding_screen4.dart';
import 'package:noodle/features/onboarding/presentation/pages/save_user_api.dart';
import 'package:noodle/features/splash/presentation/pages/splash_screen.dart';


import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding1,
      builder: (context, state) => const OnboardingScreen1(),
    ),
    GoRoute(
      path: AppRoutes.onboarding2,
      builder: (context, state) => const OnboardingScreen2(),
    ),
    GoRoute(
      path: AppRoutes.onboarding3,
      builder: (context, state) => const OnboardingScreen3(),
    ),
    GoRoute(
      path: AppRoutes.onboarding4,
      builder: (context, state) => const OnboardingScreen4(),
    ),
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.saveSettings,
      builder: (context, state) => const SaveUserApi(),
    ),
    GoRoute(
      path: AppRoutes.brain,
      builder: (context, state) => const FloatingCharacter(),
    ),
  ],
);
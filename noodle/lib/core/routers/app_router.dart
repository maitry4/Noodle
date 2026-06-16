import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:noodle/core/providers/app_providers.dart';

import 'package:noodle/features/brain/presentation/floating_character.dart';

import 'package:noodle/features/onboarding/presentation/pages/onboarding_screen1.dart';
import 'package:noodle/features/onboarding/presentation/pages/onboarding_screen2.dart';
import 'package:noodle/features/onboarding/presentation/pages/onboarding_screen3.dart';
import 'package:noodle/features/onboarding/presentation/pages/onboarding_screen4.dart';
import 'package:noodle/features/onboarding/presentation/pages/save_user_api.dart';

import 'package:noodle/features/settings/presentation/save_settings.dart';

import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.brain,

    redirect: (context, state) {
      final completed = ref
          .read(hiveServiceProvider)
          .getAppSettings()
          .onboardingCompleted;

      final location = state.matchedLocation;

      final isOnboardingFlow =
          location == AppRoutes.onboarding1 ||
          location == AppRoutes.onboarding2 ||
          location == AppRoutes.onboarding3 ||
          location == AppRoutes.onboarding4 ||
          location == AppRoutes.saveApi;

      // user has not completed onboarding
      // force onboarding

      if (!completed && !isOnboardingFlow) {
        return AppRoutes.onboarding1;
      }

      // user already completed onboarding
      // don't show onboarding again

      if (completed && isOnboardingFlow) {
        return AppRoutes.brain;
      }

      return null;
    },

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
        path: AppRoutes.saveApi,

        builder: (context, state) => const SaveUserApi(),
      ),

      GoRoute(
        path: AppRoutes.saveSettings,

        builder: (context, state) => const SaveUserSettings(),
      ),

      GoRoute(
        path: AppRoutes.brain,

        builder: (context, state) => const FloatingCharacter(),
      ),
    ],
  );
});

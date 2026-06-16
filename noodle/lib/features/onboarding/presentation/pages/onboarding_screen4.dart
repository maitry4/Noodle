import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:noodle/core/routers/app_routes.dart';
import 'package:noodle/core/widgets/transparent_button.dart';

import 'package:noodle/features/onboarding/data/save_data.dart';
import 'package:noodle/features/onboarding/presentation/widgets/onboarding_widget.dart';

class OnboardingScreen4 extends ConsumerWidget {
  const OnboardingScreen4({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnboardingScreenWidget(
      imagePath: 'assets/onboarding_screen4.webp',

      overlays: [
        Positioned(
          bottom: 130,

          left: 35,

          child: Row(
            children: [
              TransparentButton(
                width: 150,

                height: 50,

                onTap: () async {
                  await ref.read(onboardingDataProvider).selectSharedBrain();

                  await ref.read(onboardingDataProvider).completeOnboarding();

                  if (context.mounted) {
                    context.go(AppRoutes.brain);
                  }
                },
              ),

              const SizedBox(width: 40),

              TransparentButton(
                width: 150,

                height: 50,

                onTap: () {
                  context.go(AppRoutes.saveApi);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

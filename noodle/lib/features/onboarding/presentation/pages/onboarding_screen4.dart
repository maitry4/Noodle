import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noodle/core/routers/app_routes.dart';
import 'package:noodle/core/widgets/transparent_button.dart';
import 'package:noodle/features/onboarding/presentation/widgets/onboarding_widget.dart';

class OnboardingScreen4 extends StatelessWidget {
  const OnboardingScreen4({super.key});

  @override
  Widget build(BuildContext context) {
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
                onTap: () {
                  context.go(AppRoutes.splash);
                  // save settings as shared brain in hive.
                },
              ),
              SizedBox(
                width: 40,
              ),
              TransparentButton(
                width: 150,
                height: 50,
                onTap: () {
                  context.go(AppRoutes.saveSettings);
                  // go to get api form
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noodle/core/routers/app_routes.dart';
import 'package:noodle/core/widgets/transparent_button.dart';
import 'package:noodle/features/onboarding/presentation/widgets/onboarding_widget.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreenWidget(
      imagePath: 'assets/onboarding_screen2.webp',
      overlays: [
        Positioned(
          bottom: 112,
          left: 68,
          child: TransparentButton(
            width: 278,
            height: 60,
            onTap: () {
              context.go(AppRoutes.onboarding3);
            },
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noodle/core/routers/app_routes.dart';
import 'package:noodle/core/widgets/transparent_button.dart';
import 'package:noodle/features/onboarding/presentation/widgets/onboarding_widget.dart';


class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreenWidget(
      imagePath: 'assets/onboarding_screen1.webp',
      overlays: [
        Positioned(
          bottom: 120,
          left: 70,
          child: TransparentButton(
            width: 273,
            height: 60,
            onTap: () {
              context.go(AppRoutes.onboarding2);
            },
          ),
        ),
      ],
    );
  }
}
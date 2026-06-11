import 'package:flutter/material.dart';

class OnboardingScreenWidget extends StatelessWidget {
  final String imagePath;
  final List<Widget> overlays;

  const OnboardingScreenWidget({
    super.key,
    required this.imagePath,
    this.overlays = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
          ...overlays,
        ],
      ),
    );
  }
}
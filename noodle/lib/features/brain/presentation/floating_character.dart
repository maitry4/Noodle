// ignore: dangling_library_doc_comments
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noodle/core/routers/app_routes.dart';
import 'package:noodle/core/theme/app_colors.dart';
import 'package:noodle/core/widgets/noodle_button.dart';

/// The floating overlay with buttons based on what's happening.
/// It will also have a small settings gear that takes you to modify options page.
class FloatingCharacter extends StatelessWidget {
  const FloatingCharacter({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Character image
         Image.asset(
                'assets/floating_noodle_image.webp',
                height: 150,
              ),

          // Main button
          Positioned(
            bottom: -20,
            child: NoodleButton(
              text: "Get API Key",
              color: AppColors.accentBrown,
              onPressed: () {
                context.go(AppRoutes.splash);
              },
            ),
          ),

          // Settings gear
          Positioned(
            top: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  // Open settings/options page
                },
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.settings,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
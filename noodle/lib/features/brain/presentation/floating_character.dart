// ignore: dangling_library_doc_comments
/// The floating overlay with buttons based on what's happening.
/// It will also have a small settings gear that takes you to modify options page.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noodle/core/routers/app_router.dart';
import 'package:noodle/core/routers/app_routes.dart';
import 'package:noodle/core/theme/app_colors.dart';
import 'package:noodle/core/widgets/noodle_button.dart';

class FloatingCharacter extends StatelessWidget {
  const FloatingCharacter({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Character image
         Image.asset(
                'assets/floating_noodle_image.webp',
                height: 150,
              ),
          NoodleButton(text: "Dump", color: AppColors.accentBrown, onPressed: () {
            context.go(AppRoutes.saveSettings);
          }),

         ],
      ),
    );
  }
}
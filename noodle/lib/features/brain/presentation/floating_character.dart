// ignore: dangling_library_doc_comments
/// The floating overlay with buttons based on what's happening.
/// It will also have a small settings gear that takes you to modify options page.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:noodle/core/theme/app_colors.dart';
import 'package:noodle/core/widgets/noodle_button.dart';
import 'package:noodle/core/routers/app_routes.dart';

import '../data/respond_user.dart';

class FloatingCharacter extends StatefulWidget {
  const FloatingCharacter({super.key});

  @override
  State<FloatingCharacter> createState() => _FloatingCharacterState();
}

class _FloatingCharacterState extends State<FloatingCharacter> {
  late final RespondUser controller = RespondUser();

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/floating_noodle_image.webp', height: 180),

                const SizedBox(height: 20),

                Text(
                  controller.statusText,
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 20),

                if (!controller.isProcessing)
                  ElevatedButton(
                    onPressed: controller.isPlaying
                        ? null
                        : () async {
                            if (controller.isRecording) {
                              await controller.stopDump();
                            } else {
                              await controller.startDump();
                            }
                          },
                    child: Text(
                      controller.isPlaying
                          ? "Speaking..."
                          : controller.isRecording
                          ? "Stop"
                          : "Dump",
                    ),
                  ),
              ],
            ),

            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  context.go(AppRoutes.saveSettings);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

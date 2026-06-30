import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:noodle/core/routers/app_routes.dart';
import 'package:noodle/core/theme/app_colors.dart';

import '../data/respond_user.dart';
import 'widgets/dump_button.dart';
import 'widgets/noodle_character.dart';
import 'widgets/noodle_overlays.dart';
import 'widgets/steam_layer.dart';

const _bgTop = Color(0xFF1C0F05);
const _bgBottom = Color(0xFF2E1A0E);

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
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onCharacterTap() async {
    if (controller.isRecording) {
      await controller.stopDump();
    } else {
      await controller.startDump();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgTop,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: SteamLayer(active: controller.isPlaying)),
              Positioned(
                top: 12,
                left: 16,
                child: Row(
                  children: [
                    _LangChip(
                      label: 'EN',
                      code: 'en-US',
                      controller: controller,
                    ),
                    const SizedBox(width: 6),
                    _LangChip(
                      label: 'IN',
                      code: 'en-IN',
                      controller: controller,
                    ),
                    const SizedBox(width: 6),
                    _LangChip(
                      label: 'हि',
                      code: 'hi-IN',
                      controller: controller,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 16,
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.saveSettings),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.lightBrown.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      color: AppColors.lightBrown.withOpacity(0.4),
                      size: 18,
                    ),
                  ),
                ),
              ),

              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (controller.errorText == null)
                      NoodleSpeechBubble(text: controller.statusText),

                    const SizedBox(height: 16),

                    NoodleCharacter(
                      isRecording: controller.isRecording,
                      isPlaying: controller.isPlaying,
                      isProcessing: controller.isProcessing,
                      onTap: (controller.isPlaying || controller.isProcessing)
                          ? null
                          : _onCharacterTap,
                    ),

                    const SizedBox(height: 28),

                    if (controller.errorText != null)
                      NoodleErrorBanner(
                        message: controller.errorText!,
                        onDismiss: controller.clearError,
                      )
                    else if (controller.isProcessing)
                      const ProcessingDots()
                    else
                      DumpButton(
                        isRecording: controller.isRecording,
                        isPlaying: controller.isPlaying,
                        onTap: (controller.isPlaying || controller.isProcessing)
                            ? null
                            : _onCharacterTap,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final String code;
  final RespondUser controller;

  const _LangChip({
    required this.label,
    required this.code,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final selected = controller.languageCode == code;
    return GestureDetector(
      onTap: () => controller.setLanguage(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lightBrown.withOpacity(0.25)
              : AppColors.lightBrown.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.lightBrown.withOpacity(selected ? 0.9 : 0.4),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

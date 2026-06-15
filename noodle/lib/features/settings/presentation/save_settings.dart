// ignore: dangling_library_doc_comments
/// This file will display options to switch between shared brain and personal brain. and will allow to modify the personal key. (in future can give option to modify other files)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noodle/core/routers/app_routes.dart';
import 'package:noodle/core/theme/app_colors.dart';
import 'package:noodle/core/widgets/noodle_button.dart';
import 'package:noodle/core/widgets/noodle_text_field.dart';

class SaveUserSettings extends StatefulWidget {
  const SaveUserSettings({super.key});

  @override
  State<SaveUserSettings> createState() => _SaveUserSettingsState();
}

class _SaveUserSettingsState extends State<SaveUserSettings> {
  bool useOwnBrain = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Column(
            children: [
              Image.asset(
                'assets/noodle_save_settings.webp',
                height: 140,
              ),

              const SizedBox(height: 12),

              const Text(
                'Save Settings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'CustomCursive',
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Choose how Noodle should run and save your preferences.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'CustomCursive',
                ),
              ),

              const SizedBox(height: 24),

              /// Brain Selection
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.accentBrown,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.psychology_outlined),
                        SizedBox(width: 10),
                        Text(
                          'Choose Brain',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'CustomCursive',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _BrainOptionTile(
                      title: 'Shared Brain',
                      subtitle:
                          'Use Noodle\'s AI with no setup required.',
                      selected: !useOwnBrain,
                      onTap: () {
                        setState(() {
                          useOwnBrain = false;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    _BrainOptionTile(
                      title: 'My Brain',
                      subtitle:
                          'Use your own Gemini API key for higher limits.',
                      selected: useOwnBrain,
                      onTap: () {
                        setState(() {
                          useOwnBrain = true;
                        });
                      },
                    ),
                  ],
                ),
              ),

              if (useOwnBrain) ...[
                const SizedBox(height: 24),

                /// API Key Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.accentBrown,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.key),
                          SizedBox(width: 10),
                          Text(
                            'Your API Key',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'CustomCursive',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Your key is stored securely on your device and never shared.',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'CustomCursive',
                        ),
                      ),

                      const SizedBox(height: 18),

                      const NoodleTextField(
                        hintText: 'Enter your Gemini API key',
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: NoodleButton(
                          text: "Get API Key",
                          color: AppColors.accentBrown,
                          onPressed: () {
                            context.go(AppRoutes.splash);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: NoodleButton(
                  text: "Save Settings",
                  color: AppColors.buttonGreen,
                  onPressed: () {
                    context.go(AppRoutes.splash);
                  },
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'You can change these settings anytime.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'CustomCursive',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrainOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _BrainOptionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.accentBrown
                : AppColors.accentBrown.withOpacity(.35),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'CustomCursive',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'CustomCursive',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: AppColors.accentBrown,
            ),
          ],
        ),
      ),
    );
  }
}
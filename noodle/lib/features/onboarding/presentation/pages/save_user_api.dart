import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:noodle/core/routers/app_routes.dart';
import 'package:noodle/core/theme/app_colors.dart';
import 'package:noodle/core/widgets/noodle_button.dart';
import 'package:noodle/core/widgets/noodle_text_field.dart';

import 'package:noodle/features/onboarding/data/save_data.dart';

class SaveUserApi extends ConsumerStatefulWidget {
  const SaveUserApi({super.key});

  @override
  ConsumerState<SaveUserApi> createState() => _SaveUserApiState();
}

class _SaveUserApiState extends ConsumerState<SaveUserApi> {
  final TextEditingController apiController = TextEditingController();

  @override
  void dispose() {
    apiController.dispose();

    super.dispose();
  }

  void showApiKeyInstructions() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Get Gemini API Key",
            style: TextStyle(
              fontFamily: 'CustomCursive',
              fontWeight: FontWeight.w600,
            ),
          ),

          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  "Follow these steps:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 12),

                Text("1. Go to aistudio.google.com"),

                SizedBox(height: 8),

                Text(
                  "2. Login with your Google account, "
                  "then click 'Acknowledge and continue'.",
                ),

                SizedBox(height: 8),

                Text(
                  "3. Open the three-line menu "
                  "and click the key icon/button.",
                ),

                SizedBox(height: 8),

                Text(
                  "4. Copy the default API key "
                  "and paste it here.",
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("Got it"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(AppRoutes.onboarding4);
          },
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),

          child: Column(
            children: [
              Image.asset('assets/noodle_save_api.webp', height: 150),

              const Text(
                'Save Your API Key',
                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 32, fontFamily: 'CustomCursive'),
              ),

              const Text(
                'Enter your Gemini API key to unlock\n'
                'the full power of Noodle.',

                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 13, fontFamily: 'CustomCursive'),
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),

                  border: Border.all(color: AppColors.accentBrown),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Row(
                      children: [
                        Icon(Icons.key),

                        SizedBox(width: 10),

                        Text(
                          'Gemini API Key',

                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'CustomCursive',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    NoodleTextField(
                      controller: apiController,

                      hintText: 'Enter your API key here',
                    ),

                    const SizedBox(height: 20),

                    const Row(
                      children: [
                        Icon(Icons.lock_outline, size: 20),

                        SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            'Your key is stored securely on your device and never shared.',

                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'CustomCursive',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,

                      child: NoodleButton(
                        text: "Save Key",

                        color: AppColors.buttonGreen,

                        onPressed: () async {
                          final key = apiController.text.trim();

                          if (key.isEmpty) {
                            return;
                          }

                          await ref
                              .read(onboardingDataProvider)
                              .selectOwnApiKey(key);

                          await ref
                              .read(onboardingDataProvider)
                              .completeOnboarding();

                          if (context.mounted) {
                            context.go(AppRoutes.brain);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),

                  border: Border.all(color: AppColors.accentBrown),
                ),

                child: Column(
                  children: [
                    const Text(
                      "Don't have an API key?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    NoodleButton(
                      text: "Get API Key",

                      color: AppColors.accentBrown,

                      onPressed: () {
                        showApiKeyInstructions();
                      },
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

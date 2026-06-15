import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noodle/core/routers/app_routes.dart';
import 'package:noodle/core/theme/app_colors.dart';
import 'package:noodle/core/widgets/noodle_button.dart';
import 'package:noodle/core/widgets/noodle_text_field.dart';

class SaveUserApi extends StatelessWidget {
  const SaveUserApi({super.key});

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
              
              // const SizedBox(height: 18),

              Image.asset(
                'assets/noodle_save_api.webp',
                height: 150,
              ),

              // const SizedBox(height: 24),

              const Text(
                'Save Your API Key',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontFamily: 'CustomCursive', 
                ),
              ),

              // const SizedBox(height: 12),

              const Text(
                'Enter your Gemini API key to unlock\nthe full power of Noodle.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'CustomCursive', 
                ),
              ),

              const SizedBox(height: 25),

              /// Save key card
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

                    const NoodleTextField(
                      hintText: 'Enter your API key here',
                    ),

                    const SizedBox(height: 20),

                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Your key is stored securely on your device and never shared.',
                              style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'CustomCursive', 
                              fontWeight: FontWeight.w600,
                            ),
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
                        onPressed: () {
                          context.go(AppRoutes.brain);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// Get key card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.accentBrown,
                  ),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Don't have an API key?",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Get one from Google AI Studio.',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    NoodleButton(
                      text: "Get API Key",
                      color: AppColors.accentBrown,
                      onPressed: () {
                        context.go(AppRoutes.splash);
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
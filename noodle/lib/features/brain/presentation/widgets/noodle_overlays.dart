import 'package:flutter/material.dart';
import 'package:noodle/core/theme/app_colors.dart';

class NoodleSpeechBubble extends StatelessWidget {
  final String text;

  const NoodleSpeechBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.lightBrown.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBrown.withOpacity(0.15)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.lightBrown.withOpacity(0.75),
          fontSize: 15,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class NoodleErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const NoodleErrorBanner({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.4),
        border: Border.all(color: Colors.red.shade800.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade300, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.lightBrown.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close,
              color: AppColors.lightBrown.withOpacity(0.35),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
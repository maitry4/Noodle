import 'package:flutter/material.dart';
import 'package:noodle/core/theme/app_colors.dart';

class NoodleButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;
  const NoodleButton({
    super.key,
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.only(top:18, bottom: 18, left:25, right: 25),
        backgroundColor: color, 
        side: BorderSide(
          color: theme.colorScheme.outline,
          width: 2.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.borderBrown, 
          fontFamily: 'CustomCursive', 
          fontSize: 18   
        ),
      ),
    );
  }
}
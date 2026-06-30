
import 'package:flutter/material.dart';

class TransparentButton extends StatelessWidget {
  final VoidCallback onTap;
  final double width;
  final double height;

  const TransparentButton({
    super.key,
    required this.onTap,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: height,
      ),
    );
  }
}
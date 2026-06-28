import 'dart:math';
import 'package:flutter/material.dart';
import 'package:noodle/core/theme/app_colors.dart';

class DumpButton extends StatelessWidget {
  final bool isRecording;
  final bool isPlaying;
  final VoidCallback? onTap;

  const DumpButton({
    super.key,
    required this.isRecording,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = isPlaying ? "Speaking…" : isRecording ? "Stop" : "Dump It";
    final icon = isRecording ? Icons.stop_rounded : Icons.mic_rounded;
    final bg = isRecording ? Colors.red.shade700 : AppColors.accentBrown;
    final fg = isRecording ? Colors.white : AppColors.borderBrown;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        decoration: BoxDecoration(
          color: onTap == null ? AppColors.accentBrown.withOpacity(0.3) : bg,
          borderRadius: BorderRadius.circular(40),
          boxShadow: onTap == null
              ? []
              : [
                  BoxShadow(
                    color: bg.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProcessingDots extends StatefulWidget {
  const ProcessingDots({super.key});

  @override
  State<ProcessingDots> createState() => _ProcessingDotsState();
}

class _ProcessingDotsState extends State<ProcessingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (_ctrl.value - i * 0.15).clamp(0.0, 1.0);
            final y = -6 * sin(phase * pi);
            return Transform.translate(
              offset: Offset(0, y),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.accentBrown.withOpacity(0.6 + phase * 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
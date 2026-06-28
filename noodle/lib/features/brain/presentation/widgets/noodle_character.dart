import 'package:flutter/material.dart';
import 'package:noodle/core/theme/app_colors.dart';

class NoodleCharacter extends StatefulWidget {
  final bool isRecording;
  final bool isPlaying;
  final bool isProcessing;
  final VoidCallback? onTap;

  const NoodleCharacter({
    super.key,
    required this.isRecording,
    required this.isPlaying,
    required this.isProcessing,
    required this.onTap,
  });

  @override
  State<NoodleCharacter> createState() => _NoodleCharacterState();
}

class _NoodleCharacterState extends State<NoodleCharacter>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _floatCtrl;
  late final Animation<double> _pulse;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _float = CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  String get _asset {
    if (widget.isRecording) return 'assets/noodle_listening.webp';
    if (widget.isProcessing) return 'assets/noodle_thinking.webp';
    if (widget.isPlaying) return 'assets/noodle_speaking.webp';
    return 'assets/noodle_listening.webp'; 
  }

  Color get _glowColor {
    if (widget.isRecording) return Colors.red.shade400;
    if (widget.isProcessing) return AppColors.accentBrown.withOpacity(0.5);
    if (widget.isPlaying) return AppColors.accentBrown;
    return AppColors.accentBrown.withOpacity(0.6);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulse, _float]),
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, -8 + _float.value * 16),
          child: SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(260, 260),
                  painter: _GlowPainter(_pulse.value, _glowColor),
                ),
                GestureDetector(
                  onTap: widget.onTap,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Image.asset(
                      _asset,
                      key: ValueKey(_asset),
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GlowPainter extends CustomPainter {
  final double pulse;
  final Color color;
  _GlowPainter(this.pulse, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * (0.85 + pulse * 0.12);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.28 + pulse * 0.12),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_GlowPainter old) =>
      old.pulse != pulse || old.color != color;
}
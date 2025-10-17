// lib/widgets/animated_aurora.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math';

class AnimatedPurpleAuroraBackground extends StatefulWidget {
  const AnimatedPurpleAuroraBackground({super.key});

  @override
  State<AnimatedPurpleAuroraBackground> createState() =>
      _AnimatedPurpleAuroraBackgroundState();
}

class _AnimatedPurpleAuroraBackgroundState
    extends State<AnimatedPurpleAuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Stack: CustomPaint untuk blob, lalu BackdropFilter untuk blur glow
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: [
            CustomPaint(
              painter: _BlurredBlobPainter(_controller.value),
              size: MediaQuery.of(context).size,
            ),
            // Lapisan blur halus di atas blob => buat efek glow lembut
            Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BlurredBlobPainter extends CustomPainter {
  final double t;
  _BlurredBlobPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..blendMode = BlendMode.plus;

    // Background gelap
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0A0010),
    );

    // Fungsi animasi sinus halus
    double wave(double base, double amplitude, double speed) {
      return base + sin(t * 2 * pi * speed) * amplitude;
    }

    // Blob 1 (atas)
    paint.shader = ui.Gradient.radial(
      Offset(
        wave(size.width * 0.3, 40, 0.4),
        wave(size.height * 0.2, 30, 0.5),
      ),
      size.width * 0.6,
      [
        const Color(0xFFB5179E).withOpacity(0.65),
        Colors.transparent,
      ],
    );
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.2),
      size.width * 0.5,
      paint,
    );

    // Blob 2 (tengah)
    paint.shader = ui.Gradient.radial(
      Offset(
        wave(size.width * 0.7, 60, 0.3),
        wave(size.height * 0.5, 40, 0.4),
      ),
      size.width * 0.7,
      [
        const Color(0xFF9C1AFF).withOpacity(0.55),
        Colors.transparent,
      ],
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.5),
      size.width * 0.6,
      paint,
    );

    // Blob 3 (bawah)
    paint.shader = ui.Gradient.radial(
      Offset(
        wave(size.width * 0.4, 50, 0.6),
        wave(size.height * 0.85, 25, 0.7),
      ),
      size.width * 0.55,
      [
        const Color(0xFFD03AFF).withOpacity(0.45),
        Colors.transparent,
      ],
    );
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.85),
      size.width * 0.55,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BlurredBlobPainter oldDelegate) => true;
}

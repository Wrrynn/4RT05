import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const PlasmaApp());

class PlasmaApp extends StatelessWidget {
  const PlasmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: PlasmaBackground(),
      ),
    );
  }
}

class PlasmaBackground extends StatefulWidget {
  const PlasmaBackground({super.key});

  @override
  State<PlasmaBackground> createState() => _PlasmaBackgroundState();
}

class _PlasmaBackgroundState extends State<PlasmaBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: PlasmaPainter(_controller.value),
          child: Container(),
        );
      },
    );
  }
}

class PlasmaPainter extends CustomPainter {
  final double time;
  PlasmaPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..blendMode = BlendMode.plus
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    final colors = [
      Colors.purpleAccent.withOpacity(0.6),
      Colors.deepPurpleAccent.withOpacity(0.4),
      Colors.pinkAccent.withOpacity(0.3),
    ];

    for (int i = 0; i < 4; i++) {
      final angle = (time * 2 * pi) + (i * pi / 2);
      final x = size.width / 2 + cos(angle) * (size.width * 0.3);
      final y = size.height / 2 + sin(angle) * (size.height * 0.3);
      final radius = size.width * (0.3 + 0.1 * sin(time * 2 * pi + i));
      paint.color = colors[i % colors.length];
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Latar belakang gelap
    final bg = Paint()..color = Colors.black.withOpacity(0.9);
    canvas.drawRect(Offset.zero & size, bg);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

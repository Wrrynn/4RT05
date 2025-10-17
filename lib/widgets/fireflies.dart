// lib/widgets/floating_fireflies.dart
import 'dart:math';
import 'package:flutter/material.dart';

class FloatingFireflies extends StatefulWidget {
  final int count;
  const FloatingFireflies({super.key, this.count = 15});

  @override
  State<FloatingFireflies> createState() => _FloatingFirefliesState();
}

class _FloatingFirefliesState extends State<FloatingFireflies>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Random _random = Random();
  late List<_Firefly> _fireflies;

  @override
  void initState() {
    super.initState();

    // Membuat data posisi acak untuk setiap kunang"
    _fireflies = List.generate(widget.count, (_) => _Firefly(_random));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
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
      builder: (context, _) {
        return CustomPaint(
          painter: _FireflyPainter(_fireflies, _controller.value),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

// Kelas data kunang"
class _Firefly {
  double x, y;
  double radius;
  double speedX, speedY;
  Color color;

  _Firefly(Random random)
      : x = random.nextDouble(),
        y = random.nextDouble(),
        radius = random.nextDouble() * 2 + 1.5,
        speedX = (random.nextDouble() - 0.5) * 0.003,
        speedY = (random.nextDouble() - 0.5) * 0.003,
        color = Colors.primaries[random.nextInt(Colors.primaries.length)]
            .withOpacity(0.7);

  void update(double t) {
    // update posisi acak lembut
    x += sin(t * 2 * pi * speedX);
    y += cos(t * 2 * pi * speedY);
  }
}

// Painter untuk menggambar kunang"
class _FireflyPainter extends CustomPainter {
  final List<_Firefly> fireflies;
  final double t;

  _FireflyPainter(this.fireflies, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    for (final f in fireflies) {
      f.update(t);
      final dx = (f.x % 1) * size.width;
      final dy = (f.y % 1) * size.height;
      paint.color = f.color;
      canvas.drawCircle(Offset(dx, dy), f.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FireflyPainter oldDelegate) => true;
}

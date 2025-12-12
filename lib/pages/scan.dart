import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';

class ScanQrPage extends StatelessWidget {
  const ScanQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: BackgroundApp(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                // area atas: frame scan
                _buildScanArea(),
                const SizedBox(height: 24),
                // area bawah: instruksi
                _buildInstructionCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- APPBAR ----------------

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            centerTitle: true,
            title: const Text(
              'Scan QR Code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              // ikon flashlight (belum fungsi, UI dulu)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GlassContainer(
                  width: 34,
                  height: 34,
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFAC00FF),
                      Color(0xFF3C00FF),
                    ],
                  ),
                  child: const Icon(
                    Icons.flashlight_on_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- AREA SCAN ----------------

  Widget _buildScanArea() {
    return GlassContainer(
      width: double.infinity,
      height: 320,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      gradient: LinearGradient(
        colors: [
          Colors.black.withOpacity(0.15),
          Colors.black.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: Colors.white.withOpacity(0.18),
      child: Center(
        child: Container(
          width: 230,
          height: 230,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFAC00FF),
                Color(0xFF3C00FF),
              ],
            ),
          ),
          child: Stack(
            children: [
              // frame sudut-sudut
              Positioned.fill(
                child: CustomPaint(
                  painter: _CornerBorderPainter(
                    color: Colors.white.withOpacity(0.8),
                    strokeWidth: 6,
                    radius: 32,
                    cornerLength: 40,
                  ),
                ),
              ),
              // ikon kamera di tengah
              Center(
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- KARTU INSTRUKSI ----------------

  Widget _buildInstructionCard() {
    return GlassContainer(
      width: double.infinity,
      height: 200,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      gradient: LinearGradient(
        colors: [
          const Color(0xFF3C003F).withOpacity(0.9),
          const Color(0xFF130021).withOpacity(0.9),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: Colors.white.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Scan Instruksi",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _buildInstructionRow(
            number: "1",
            text: "Posisikan QR code dengan bingkai scan.",
          ),
          const SizedBox(height: 8),
          _buildInstructionRow(
            number: "2",
            text: "Tahan dengan stabil hingga scan selesai.",
          ),
          const SizedBox(height: 8),
          _buildInstructionRow(
            number: "3",
            text: "Lakukan konfirmasi pembayaran.",
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionRow({required String number, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF6339A).withOpacity(0.9),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

/// Painter untuk bikin garis di keempat sudut frame scan
class _CornerBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double cornerLength;

  _CornerBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.cornerLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // helper gambar satu sudut
    void drawCorner(Path path, double dx, double dy, bool isTop, bool isLeft) {
      final double signX = isLeft ? 1 : -1;
      final double signY = isTop ? 1 : -1;

      final double startX = isLeft ? dx : size.width - dx;
      final double startY = isTop ? dy : size.height - dy;

      path.moveTo(startX, startY + signY * cornerLength);
      path.lineTo(startX, startY + signY * radius);
      path.quadraticBezierTo(
        startX,
        startY,
        startX + signX * radius,
        startY,
      );
      path.lineTo(startX + signX * cornerLength, startY);
    }

    final Path path = Path();

    const double padding = 12;

    // kiri atas
    drawCorner(path, padding, padding, true, true);
    // kanan atas
    drawCorner(path, padding, padding, true, false);
    // kiri bawah
    drawCorner(path, padding, padding, false, true);
    // kanan bawah
    drawCorner(path, padding, padding, false, false);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

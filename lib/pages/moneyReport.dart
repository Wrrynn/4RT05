import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';

class LaporanKeuanganPage extends StatelessWidget {
  const LaporanKeuanganPage({super.key});

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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTopSummaryRow(),
                        const SizedBox(height: 14),
                        _buildSavingCard(),
                        const SizedBox(height: 18),
                        _buildChartCard(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildDownloadButton(),
                const SizedBox(height: 8),
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
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: const Text(
              "Laporan Keuangan",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- SUMMARY TOP ----------------

  Widget _buildTopSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            title: "Pemasukan",
            amount: "Rp. 000000",
            subtitle: "+10% Vs Bulan Lalu",
            borderColor: const Color(0xFF1DD45E),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            title: "Pengeluaran",
            amount: "Rp. 000000",
            subtitle: "-10% Vs Bulan Lalu",
            borderColor: const Color(0xFFFF4C4C),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String amount,
    required String subtitle,
    required Color borderColor,
  }) {
    return GlassContainer(
      width: double.infinity,
      height: 110,
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.black.withOpacity(0.4),
          Colors.black.withOpacity(0.2),
        ],
      ),
      borderColor: borderColor.withOpacity(0.9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: borderColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SAVING CARD ----------------

  Widget _buildSavingCard() {
    return GlassContainer(
      width: double.infinity,
      height: 130,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF7C1CF5),
          Color(0xFFBF2BD4),
        ],
      ),
      borderColor: Colors.white.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Penghematan",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Rp. 1000",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Tingkat Tabungan: 10%",
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- CHART CARD ----------------

  Widget _buildChartCard() {
    return GlassContainer(
      width: double.infinity,
      height: 280,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      gradient: LinearGradient(
        colors: [
          Colors.black.withOpacity(0.4),
          Colors.black.withOpacity(0.25),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: Colors.white.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Income vs Expenses",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              painter: _IncomeExpenseChartPainter(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _LegendDot(color: Color(0xFF1DD45E), label: "Income"),
              SizedBox(width: 20),
              _LegendDot(color: Color(0xFFFF4C9A), label: "Expenses"),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ---------------- DOWNLOAD BUTTON ----------------

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          // TODO: generate & download laporan (PDF / CSV) jika perlu
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFAC00FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Unduh Laporan",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ---------- LEGEND DOT ----------

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ---------- SIMPLE CUSTOM CHART PAINTER ----------

class _IncomeExpenseChartPainter extends CustomPainter {
  final List<double> income = [4800, 5000, 4700, 5200, 5600, 5400];
  final List<double> expense = [3800, 3900, 3700, 4100, 4000, 3900];

  @override
  void paint(Canvas canvas, Size size) {
    final double maxY = 6000;
    final double minY = 0;
    final double chartHeight = size.height - 40;
    final double chartWidth = size.width - 40;

    final double dx = chartWidth / (income.length - 1);

    // axis paint
    final axisPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;

    // draw y axis & x axis
    canvas.drawLine(
      Offset(32, 10),
      Offset(32, chartHeight + 10),
      axisPaint,
    );
    canvas.drawLine(
      Offset(32, chartHeight + 10),
      Offset(chartWidth + 32, chartHeight + 10),
      axisPaint,
    );

    // helpers
    Offset pointFor(double value, int index) {
      final double normY = (value - minY) / (maxY - minY);
      final double y = chartHeight + 10 - normY * chartHeight;
      final double x = 32 + dx * index;
      return Offset(x, y);
    }

    // draw lines
    final incomePaint = Paint()
      ..color = const Color(0xFF1DD45E)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final expensePaint = Paint()
      ..color = const Color(0xFFFF4C9A)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final incomePath = Path()..moveTo(pointFor(income[0], 0).dx, pointFor(income[0], 0).dy);
    final expensePath = Path()..moveTo(pointFor(expense[0], 0).dx, pointFor(expense[0], 0).dy);

    for (int i = 1; i < income.length; i++) {
      incomePath.lineTo(pointFor(income[i], i).dx, pointFor(income[i], i).dy);
      expensePath.lineTo(pointFor(expense[i], i).dx, pointFor(expense[i], i).dy);
    }

    canvas.drawPath(incomePath, incomePaint);
    canvas.drawPath(expensePath, expensePaint);

    // draw dots
    final dotPaintIncome = Paint()..color = const Color(0xFF1DD45E);
    final dotPaintExpense = Paint()..color = const Color(0xFFFF4C9A);

    for (int i = 0; i < income.length; i++) {
      final p1 = pointFor(income[i], i);
      final p2 = pointFor(expense[i], i);
      canvas.drawCircle(p1, 3.5, dotPaintIncome);
      canvas.drawCircle(p2, 3.5, dotPaintExpense);
    }

    // draw month labels (Jan–Jun)
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < months.length; i++) {
      final x = 32 + dx * i;
      final y = chartHeight + 18;
      textPainter.text = TextSpan(
        text: months[i],
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

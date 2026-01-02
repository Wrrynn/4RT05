import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';
import 'package:artos/controller/laporanCtrl.dart';
import 'package:artos/service/db_service.dart';
import 'package:artos/pages/history.dart';
import 'package:artos/widgets/currency.dart';

class LaporanKeuanganPage extends StatefulWidget {
  const LaporanKeuanganPage({super.key});
  @override
  State<LaporanKeuanganPage> createState() => _LaporanKeuanganPageState();
}

class _LaporanKeuanganPageState extends State<LaporanKeuanganPage> {
  final LaporanKeuanganController _ctrl = LaporanKeuanganController();
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = true;
  
  double _income = 0;
  double _expense = 0;
  Map<String, double> _expenseCat = {};
  Map<String, double> _incomeCat = {};

  @override
  void initState() { super.initState(); _fetchData(); }

  Future<void> _fetchData() async {
  setState(() => _isLoading = true);

  final uid = DBService.client.auth.currentUser?.id ?? "";
  final data = await _ctrl.getMonthlyReportData(uid, _selectedMonth);

  setState(() {
    _income = data['pemasukan'];
    _expense = data['pengeluaran'];
    _expenseCat = Map<String, double>.from(data['expense_categories']);
    _incomeCat = Map<String, double>.from(data['income_categories']);
    _isLoading = false;
  });
}


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: BackgroundApp(
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildMonthPicker(),
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _buildHistogramSection(),
                            const SizedBox(height: 25),
                            const TabBar(
                              indicatorColor: Color(0xFFAC00FF),
                              indicatorWeight: 3,
                              tabs: [Tab(text: "Pemasukan"), Tab(text: "Pengeluaran")], // Posisi ditukar
                            ),
                            SizedBox(
                              height: 500, 
                              child: TabBarView(
                                children: [
                                  _buildPieDetailSection(data: _incomeCat, total: _income, title: "Sumber Pemasukan"),
                                  _buildPieDetailSection(data: _expenseCat, total: _expense, title: "Rincian Kategori"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
                _buildHistoryButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: Row(
      children: [
        IconButton(
          // Menggunakan icon yang sama dengan topup.dart
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const Text(
          "Analisis Keuangan", 
          style: TextStyle(
            color: Colors.white, 
            fontSize: 22, 
            fontWeight: FontWeight.bold
          )
        ),
      ],
    ),
  );
}

  Widget _buildHistogramSection() {
    return GlassContainer(
      width: double.infinity,
      height: 200,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _barItem("Pemasukan", _income, const Color(0xFF1DD45E)),
                _barItem("Pengeluaran", _expense, const Color(0xFFFF4C9A)),
              ],
            ),
          ),
          Container(
            height: 2.5,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Text("Pemasukan", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text("Pengeluaran", style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _barItem(String label, double value, Color color) {
    double maxHeight = 100.0;
    double maxVal = (_income > _expense) ? _income : _expense;
    double ratio = (maxVal == 0) ? 0 : (value / maxVal);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(formatCurrency(value), 
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          width: 45,
          height: (ratio * maxHeight).clamp(4, maxHeight),
          decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(8))), 
        ),
      ],
    );
  }

  Widget _buildPieDetailSection({required Map<String, double> data, required double total, required String title}) {
    if (total == 0) return const Center(child: Text("Belum ada data.", style: TextStyle(color: Colors.white54)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Center(
          child: SizedBox(
            height: 180, width: 180,
            child: CustomPaint(
              painter: _PieChartPainter(data: data, total: total), 
              child: Center(child: Text("Total\n${formatCurrency(total)}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13))),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              String name = data.keys.elementAt(index);
              double val = data.values.elementAt(index);
              double pct = (val / total) * 100;
              final colors = [Colors.yellowAccent, Colors.orangeAccent, Colors.lightBlueAccent, Colors.greenAccent, Colors.purpleAccent, Colors.pinkAccent];
              Color color = colors[index % colors.length];

              return Row(
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        Text(
                          formatCurrency(val), 
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text("${pct.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () {
          setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1));
          _fetchData();
        }),
        Text("${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}", 
             style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), onPressed: () {
          setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1));
          _fetchData();
        }),
      ],
    );
  }

  Widget _buildHistoryButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFAC00FF), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage())),
        child: const Text("Lihat Riwayat Transaksi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  String _getMonthName(int month) => ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"][month - 1];
}

class _PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final double total;
  _PieChartPainter({required this.data, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 28..strokeCap = StrokeCap.butt;
    double startAngle = -math.pi / 2;
    int index = 0;
    final colors = [Colors.yellowAccent, Colors.orangeAccent, Colors.lightBlueAccent, Colors.greenAccent, Colors.purpleAccent, Colors.pinkAccent];

    data.forEach((key, value) {
      final sweepAngle = (value / total) * 2 * math.pi;
      paint.color = colors[index % colors.length];
      canvas.drawArc(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2), startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
      index++;
    });
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
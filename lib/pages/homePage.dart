import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:artos/widgets/glass.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/navbar.dart';
import 'package:artos/widgets/currency.dart';
import 'package:artos/model/pengguna.dart';
import 'package:artos/controller/homeCtrl.dart';
import 'package:artos/controller/logoutCtrl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

// Import Pages
import 'package:artos/pages/pool.dart';
import 'package:artos/pages/scan.dart';
import 'package:artos/pages/history.dart';

class Homepage extends StatefulWidget {
  final Pengguna pengguna;
  const Homepage({super.key, required this.pengguna});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _pageIndex = 0;
  final HomeController _ctrl = HomeController();
  final LogoutController _logoutCtrl = LogoutController();

  @override
  void initState() {
    super.initState();
    _ctrl.init(widget.pengguna);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _ctrl.loadDashboardData();
    if (mounted) setState(() {});
  }

  Future<void> _handleRefresh() async {
    final updated = await _ctrl.refreshData(_ctrl.pengguna.idPengguna);
    if (updated != null) {
      setState(() {
        _ctrl.pengguna = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _pageIndex == 0 ? _buildAppBar() : null,
      body: BackgroundApp(
        child: SafeArea(
          child: _buildPage(_pageIndex),
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _pageIndex,
        onItemTapped: (index) => setState(() => _pageIndex = index),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0: return _buildMainContent();
      case 1: return const PoolPage();
      case 2: return const ScanPage();
      case 3: return const HistoryPage();
      default: return const SizedBox();
    }
  }

  PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Artos', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                onPressed: () => _logoutCtrl.logout(context),
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
              const SizedBox(width: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return LiquidPullToRefresh(
      color: const Color(0xFF5900FF),
      onRefresh: () async {
        final updated = await _ctrl.refreshData(_ctrl.pengguna.idPengguna);
        if (updated != null) setState(() => _ctrl.pengguna = updated);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildDashboardCard(), // Card Utama
            const SizedBox(height: 30),
            _buildSectionTitle("Akses Cepat"),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 30),
            _buildSectionTitle("Fitur Aplikasi"),
            const SizedBox(height: 16),
            _buildFeatureList(),
            const SizedBox(height: 100), // Padding bawah agar tidak tertutup navbar
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard() {
    return GlassContainer(
      width: double.infinity,
      height: 240,
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        colors: [
          const Color(0xFFF6339A).withOpacity(0.15),
          const Color(0xFFAC00FF).withOpacity(0.15),
        ],
      ),
      borderColor: Colors.white.withOpacity(0.1),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- BAGIAN PROFIL (Tanpa Ikon Mata) ---
          Row(
            children: [
              CircleAvatar(
                radius: 30, 
                backgroundImage: AssetImage('assets/images/21.png')
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _ctrl.pengguna.namaLengkap, 
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 20, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                    Text(
                      "ID ${_ctrl.pengguna.rekening}", 
                      style: const TextStyle(
                        color: Colors.white60, 
                        fontSize: 13
                      )
                    ),
                  ],
                ),
              ),
              // Ikon mata dihapus dari sini agar tidak sejajar dengan nama
            ],
          ),

          const SizedBox(height: 15),

          // --- BAGIAN SALDO UTAMA & IKON MATA (Sejajar Horisontal) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Mendorong ikon ke kanan
            crossAxisAlignment: CrossAxisAlignment.center, // Sejajar secara vertikal
            children: [
              Text(
                _ctrl.isBalanceVisible 
                    ? formatCurrency(_ctrl.pengguna.saldo) 
                    : "********",
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 28, 
                  fontWeight: FontWeight.bold
                ),
              ),
              // Ikon mata dipindahkan ke sini agar sejajar dengan saldo
              IconButton(
                icon: Icon(
                  _ctrl.isBalanceVisible 
                      ? Icons.visibility_outlined 
                      : Icons.visibility_off_outlined, 
                  color: Colors.white70,
                  size: 28, // Ukuran sedikit diperbesar agar seimbang dengan saldo
                ),
                onPressed: () => setState(() => _ctrl.toggleVisibility()),
              ),
            ],
          ),

          const Spacer(),

          // --- BAGIAN STATISTIK (Pemasukan & Pengeluaran) ---
          Row(
            children: [
              _buildStatBox(
                "Pemasukan", 
                _ctrl.pemasukanBulanIni, 
                const Color(0xFF1DD45E), 
                Icons.arrow_downward
              ),
              const SizedBox(width: 12),
              _buildStatBox(
                "Pengeluaran", 
                _ctrl.pengeluaranBulanIni, 
                const Color(0xFFFF4C4C), 
                Icons.arrow_upward
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, double amount, Color color, IconData icon) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        borderRadius: BorderRadius.circular(16),
        borderColor: color.withOpacity(0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 4),
            // HAPUS 'const' di depan Text karena formatCurrency adalah dinamis
            Text(
              _ctrl.isBalanceVisible ? formatCurrency(amount) : "******",
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionBtn('assets/icons/topup.png', 'Top Up', '/topup'),
        _actionBtn('assets/icons/sendmoney.png', 'Kirim', '/send'),
        _actionBtn('assets/icons/payment.png', 'Bayar', '/payment'),
        _actionBtn('assets/icons/qrcode.png', 'Scan', '/scan'),
      ],
    );
  }

  Widget _actionBtn(String icon, String label, String route) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, route, arguments: _ctrl.pengguna),
          child: GlassContainer(
            width: 70, height: 70, borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(colors: [Color(0xFFAE00FF), Color(0xFF3C00FF)]),
            child: Center(child: Image.asset(icon, width: 35)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildFeatureList() {
    return Column(
      children: [
        _featureItem("Manajemen Uang", 'assets/icons/management.png', '/moneyManagement'),
        _featureItem("Laporan Keuangan", 'assets/icons/management.png', '/moneyReport'),
      ],
    );
  }

  Widget _featureItem(String title, String icon, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: GlassContainer(
        width: double.infinity, height: 80, margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gradient: LinearGradient(colors: [const Color(0xFFAC00FF).withOpacity(0.1), const Color(0xFF2B00FF).withOpacity(0.1)]),
        child: Row(
          children: [
            GlassContainer(width: 50, height: 50, borderRadius: BorderRadius.circular(12), child: Center(child: Image.asset(icon, width: 25, color: Colors.white))),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}
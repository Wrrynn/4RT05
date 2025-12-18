import 'dart:ui';
import 'package:artos/pages/pool.dart';
import 'package:flutter/material.dart';
//import 'package:artos/widgets/aurora.dart';
import 'package:artos/widgets/glass.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/navbar.dart';
import 'package:artos/pages/history.dart';
import 'package:artos/pages/scan.dart';

// import 'package:artos/widgets/fireflies.dart';
// import 'package:artos/widgets/plasma.dart';
import 'package:artos/model/pengguna.dart';
import 'package:artos/service/db_service.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:artos/widgets/currency.dart';

class Homepage extends StatefulWidget {
  final Pengguna pengguna;
  const Homepage({super.key, required this.pengguna});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _pageIndex = 0;
  late Pengguna _pengguna;
  bool _refreshing = false;
  @override
  void initState() {
    super.initState();
    _pengguna = widget.pengguna;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _pageIndex == 0 ? buildAppBar() : null,
      body: BackgroundApp(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: SafeArea(
                child: _buildPage(_pageIndex),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _pageIndex,
        onItemTapped: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildPage(int index) {
    if (index == 0) return buildMainContent();
    if (index == 1) return PoolPage();
    if (index == 2) return ScanPage();
    if (index == 3) return HistoryPage();

    return Container(); // default fallback
  }

  PreferredSize buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // blur halus
          child: AppBar(
            title: const Text(
              'Artos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: _refreshing
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              color: Color(0xFF5900FF),
                              strokeWidth: 2.4,
                            ),
                          )
                        : IconButton(
                            onPressed: () => _refreshData(),
                            icon: const Icon(Icons.refresh, color: Colors.white),
                          ),
                  ),
                ],
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleSpacing: 25,
            toolbarHeight: 80,
          ),
        ),
      ),
    );
  }
  /// Konten utama
  Widget buildMainContent() {
    return Column(
      children: [
        Expanded(
          child: LiquidPullToRefresh(
            showChildOpacityTransition: true,
            springAnimationDurationInMilliseconds: 500,
            color: const Color(0xFF5900FF),
            backgroundColor: Colors.white12,
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(0, _refreshing ? 40.0 : 0.0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildProfileCard(),
                    const SizedBox(height: 30),
                    buildAksesAplikasi(context),
                    const SizedBox(height: 30),
                    buildFiturAplikasi(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================== RIWAYAT TRANSAKSI ==================
  Widget _buildSearchBar() {
    return GlassContainer(
      width: double.infinity,
      height: 55,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gradient: LinearGradient(
        colors: [
          Colors.black.withOpacity(0.25),
          Colors.black.withOpacity(0.10),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: Colors.white.withOpacity(0.18),
      child: Row(
        children: const [
          Icon(Icons.search, color: Colors.white54, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Cari Transaksi",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    // simple modern refresh: fetch latest Pengguna record and update UI
    final currentId = DBService.client.auth.currentUser?.id ?? _pengguna.idPengguna;
    try {
      setState(() => _refreshing = true);
      final res = await DBService.client
          .from('Pengguna')
          .select()
          .eq('id_pengguna', currentId)
          .maybeSingle();
      if (res != null) {
        final updated = Pengguna.fromJson(res as Map<String, dynamic>);
        setState(() => _pengguna = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil diperbarui')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat menemukan data pengguna')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui: $e')),
      );
    } finally {
      setState(() => _refreshing = false);
    }
  }

  Widget buildAksesAplikasi(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Akses Cepat",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildFeatureButton(
            icon: 'assets/icons/topup.png',
            label: 'Top Up',
            onTap: () {
              Navigator.pushNamed(context, '/topup', arguments: _pengguna);
            },
          ),
          buildFeatureButton(
            icon: 'assets/icons/sendmoney.png',
            label: 'Kirim Uang',
            onTap: () {
              Navigator.pushNamed(context, '/send');
            },
          ),
          buildFeatureButton(
            icon: 'assets/icons/payment.png',
            label: 'Bayar',
            onTap: () {
              Navigator.pushNamed(context, '/payment');
            },
          ),
          buildFeatureButton(
            icon: 'assets/icons/qrcode.png',
            label: 'Scan',
            onTap: () {
              Navigator.pushNamed(context, '/scan');
            },
          ),
        ],
      ),
    ],
    );
  }

  Widget _buildTransactionCard({
    required String title,
    required String subtitle,
    required String amount,
    required bool isIncome,
  }) {
    final Color amountColor = isIncome
        ? const Color(0xFF1DD45E)
        : const Color(0xFFF6339A);

    return GlassContainer(
      width: double.infinity,
      height: 90,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF4B146D).withOpacity(0.7),
          const Color(0xFF120526).withOpacity(0.9),
        ],
      ),
      borderColor: Colors.white.withOpacity(0.15),
      child: Row(
        children: [
          GlassContainer(
            width: 40,
            height: 40,
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.10),
                Colors.white.withOpacity(0.03),
              ],
            ),
            borderColor: Colors.white.withOpacity(0.15),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: amountColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileCard() {
    return GlassContainer(
      width: double.infinity,
      height: 235,
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFF6339A).withOpacity(0.2),
          const Color(0xFFAC00FF).withOpacity(0.2),
          const Color(0xFF2B00FF).withOpacity(0.2),
        ],
      ),
      borderColor: Colors.white.withOpacity(0.1),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset('assets/images/21.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 15),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        _pengguna.namaLengkap,
                      style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "ID ${_pengguna.rekening}",
                          style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.copy_rounded,
                          size: 18,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "${formatCurrency(_pengguna.saldo)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.remove_red_eye_outlined,
                          color: Colors.white70,
                          size: 26,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Pemasukan & Pengeluaran
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Pemasukan",
                          style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Rp. 000",
                          style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Pengeluaran",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Rp. 000",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget buildFeatureButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: GlassContainer(
            width: 75,
            height: 75,
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Color(0xFFAE00FF), Color(0xFF3C00FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Center(child: Image.asset(icon, width: 40, height: 40)),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget buildFiturAplikasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Fitur Aplikasi",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        fiturButton(
          text: "Manajemen Uang",
          iconPath: 'assets/icons/management.png',
          onTap: () {
            Navigator.pushNamed(context, '/moneyManagement');
          },
        ),

        fiturButton(
          text: "Laporan Keuangan",
          iconPath: 'assets/icons/management.png',
          onTap: () {
            Navigator.pushNamed(context, '/moneyReport');
          },
        ),
      ],
    );
  }

  Widget fiturButton({
    required String text,
    required String iconPath,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        width: double.infinity,
        height: 85,
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        margin: const EdgeInsets.only(bottom: 12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFAC00FF).withOpacity(0.15),
            const Color(0xFF2B00FF).withOpacity(0.15),
          ],
        ),
        borderColor: Colors.white.withOpacity(0.15),

        child: Row(
          children: [
            // Ikon kiri
            GlassContainer(
              width: 55,
              height: 55,
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFFAC00FF), Color(0xFF3C00FF)],
              ),
              child: Center(
                child: Image.asset(
                  iconPath, // 🔹 bisa diubah bebas
                  width: 28,
                  height: 28,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // teks fitur (dinamis)
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Panah kanan
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
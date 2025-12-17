import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';


class ManajemenKeuanganPage extends StatelessWidget {
  const ManajemenKeuanganPage({super.key});

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTotalDanaCard(),
                        const SizedBox(height: 24),
                        const Text(
                          "Akun",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAccountCard(
                          name: "Akun Utama",
                          amount: "Rp. 000000",
                        ),
                        const SizedBox(height: 10),
                        _buildAccountCard(
                          name: "Bank",
                          amount: "Rp. 000000",
                        ),
                        const SizedBox(height: 24),
                        _buildAnggaranHeader(context),
                        const SizedBox(height: 12),
                        _buildBudgetCard(
                          title: "Makan dan Minuman",
                          usedText: "Rp. 50.000 dari Rp. 100.000",
                          progress: 0.5,
                        ),
                        const SizedBox(height: 12),
                        _buildBudgetCard(
                          title: "Belanja",
                          usedText: "Rp. 20.000 dari Rp. 100.000",
                          progress: 0.2,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildBottomButtons(context),
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
              "Manajemen Keuangan",
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

  // ---------------- TOTAL DANA ----------------

  Widget _buildTotalDanaCard() {
    return GlassContainer(
      width: double.infinity,
      height: 140,
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF4B2CCB),
          Color(0xFF9C22CF),
        ],
      ),
      borderColor: Colors.white.withOpacity(0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Total Dana",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Rp. 000000",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "+ 10.5% dari bulan terakhir",
            style: TextStyle(
              color: Color(0xFF28D17C),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- AKUN CARD ----------------

  Widget _buildAccountCard({
    required String name,
    required String amount,
  }) {
    return GlassContainer(
      width: double.infinity,
      height: 80,
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF4B146D).withOpacity(0.55),
          const Color(0xFF120526).withOpacity(0.85),
        ],
      ),
      borderColor: Colors.white.withOpacity(0.15),
      child: Row(
        children: [
          // icon kotak di kiri
          GlassContainer(
            width: 42,
            height: 42,
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.02),
              ],
            ),
            borderColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- ANGGRAN HEADER ----------------

  Widget _buildAnggaranHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Anggaran Perkategori",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: nanti arahkan ke halaman "Atur Budget" jika mau
            // Navigator.pushNamed(context, '/budget');
          },
          child: GlassContainer(
            width: 34,
            height: 34,
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF6339A),
                Color(0xFFAC00FF),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- BUDGET CARD ----------------
  Widget _buildBudgetCard({
    required String title,
    required String usedText,
    required double progress,
  }) {
    return GlassContainer(
      width: double.infinity,
      height: 100,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF4B146D).withOpacity(0.7),
          const Color(0xFF1E062D).withOpacity(0.9),
        ],
      ),
      borderColor: Colors.white.withOpacity(0.15),
      child: Row(
        children: [
          // Left side content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  usedText,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(0.12),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF6339A),
                            Color(0xFFAC00FF),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right side buttons
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Edit button
              GlassContainer(
                width: 32,
                height: 32,
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.15),
                    Colors.orange.withOpacity(0.05),
                  ],
                ),
                borderColor: Colors.orange.withOpacity(0.2),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.orangeAccent,
                  size: 16,
                ),
              ),
              // Delete button
              GlassContainer(
                width: 32,
                height: 32,
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withOpacity(0.15),
                    Colors.red.withOpacity(0.05),
                  ],
                ),
                borderColor: Colors.red.withOpacity(0.2),
                child: const Icon(
                  Icons.delete_rounded,
                  color: Colors.redAccent,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- BOTTOM BUTTONS ----------------
  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/moneyReport');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAC00FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Lihat Laporan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ], 
    );
  }
}

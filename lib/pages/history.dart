import 'package:flutter/material.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';
import 'package:artos/widgets/navbar.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        centerTitle: true,
        title: const Text(
          "Riwayat Transaksi",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: BackgroundApp(
        child: SafeArea(
          child: _buildRiwayatBody(),
        ),
      ),

      
    );
  }

  /// ======= ISI RIWAYAT =======
  Widget _buildRiwayatBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 24),

                const Text(
                  "Kemarin",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _buildTransactionCard(
                  title: "Nasi Padang",
                  subtitle: "Makanan • 14.30",
                  amount: "Rp. 500.000",
                  isIncome: false,
                ),

                const SizedBox(height: 24),
                const Text(
                  "28 Okt 2005",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _buildTransactionCard(
                  title: "Gucci",
                  subtitle: "Belanja • 18.30",
                  amount: "Rp. 50.000",
                  isIncome: false,
                ),
                const SizedBox(height: 10),

                _buildTransactionCard(
                  title: "Deposit",
                  subtitle: "Pendapatan • 21.50",
                  amount: "+Rp. 5.000",
                  isIncome: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ======= SEARCH BAR =======
  Widget _buildSearchBar() {
    return GlassContainer(
      width: double.infinity,
      height: 55,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.06),
          Colors.white.withOpacity(0.02),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: Colors.white.withOpacity(0.18),
      child: Row(
        children: const [
          Icon(Icons.search, color: Colors.white70, size: 20),
          SizedBox(width: 10),
          Text(
            "Cari Transaksi",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// ======= KARTU TRANSAKSI =======
  Widget _buildTransactionCard({
    required String title,
    required String subtitle,
    required String amount,
    required bool isIncome,
  }) {
    final Color amountColor =
        isIncome ? const Color(0xFF1DD45E) : const Color(0xFFF6339A);

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
          Colors.white.withOpacity(0.06),
          Colors.white.withOpacity(0.02),
        ],
      ),
      borderColor: Colors.white.withOpacity(0.18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Kiri: judul + subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          // Kanan: jumlah
          Text(
            amount,
            style: TextStyle(
              color: amountColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

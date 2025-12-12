import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';
import 'bukti.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBar(context),
      body: BackgroundApp(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _searchBar(),
                const SizedBox(height: 20),

                const Text(
                  "Kemarin",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _riwayatItem(
                  context,
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

                _riwayatItem(
                  context,
                  title: "Gucci",
                  subtitle: "Belanja • 18.30",
                  amount: "Rp. 50.000",
                  isIncome: false,
                ),

                const SizedBox(height: 10),

                _riwayatItem(
                  context,
                  title: "Deposit",
                  subtitle: "Pendapatan • 21.50",
                  amount: "+Rp. 5.000",
                  isIncome: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- APPBAR ----------------

  PreferredSizeWidget _appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: (){
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            title: const Text(
              "Riwayat Transaksi",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: const [
              Icon(Icons.filter_alt_rounded, color: Colors.white),
              SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- SEARCH ----------------

  Widget _searchBar() {
    return GlassContainer(
      width: double.infinity,
      height: 54,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: const [
          Icon(Icons.search, color: Colors.white54),
          SizedBox(width: 10),
          Text(
            "Cari Transaksi",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  // ---------------- ITEM ----------------

  Widget _riwayatItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String amount,
    required bool isIncome,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const BuktiPembayaranPage(),
          ),
        );
      },
      child: GlassContainer(
        width: double.infinity,
        height: 80,
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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
            ),
            Text(
              amount,
              style: TextStyle(
                color: isIncome ? Colors.greenAccent : Colors.pinkAccent,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';

class BuktiPembayaranPage extends StatelessWidget {
  const BuktiPembayaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBar(context),
      body: BackgroundApp(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Expanded(
                  child: GlassContainer(
                    width: double.infinity,
                    height: 520,
                    borderRadius: BorderRadius.circular(24),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Transaksi Berhasil",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        const Text(
                          "Pembayaran Berhasil Diselesaikan",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Jumlah",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),

                        const Text(
                          "Rp. 500.000",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24),

                        _row("Transaksi", "Nasi Padang"),
                        _row("Kategori", "Makanan"),
                        _row("Tanggal", "19 Oktober 2025"),
                        _row("Waktu", "14.30"),
                        _row("Metode", "QRIS"),
                        _row("Biaya Transfer", "Rp. 0"),
                        _row("Total Jumlah", "Rp. 500.000"),
                        _row("ID Transaksi", "#123456789"),
                        _row("Status", "Berhasil"),

                        const Divider(color: Colors.white24),
                        _row("Dari", "User123"),
                        _row("Ke", "Warung Naspad123"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Unduh",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAC00FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Bagikan",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Bukti Pembayaran",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Text(
            right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

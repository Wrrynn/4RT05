import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:artos/widgets/aurora.dart';
import 'package:artos/widgets/glass.dart'; // pastikan file glass.dart sudah ada
// import 'package:artos/widgets/fireflies.dart';
// import 'package:artos/widgets/plasma.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // biar aurora muncul di belakang AppBar
      appBar: buildAppBar(),
      body: Stack(
        children: [
          const AnimatedPurpleAuroraBackground(), // background aurora
          // const FloatingFireflies(count: 20), // opsional, kunang-kunang

          // Konten utama
          SafeArea(child: buildMainContent()),
        ],
      ),
    );
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildProfileCard(),
              const SizedBox(height: 30),
              buildFiturAplikasi(),
              const SizedBox(height: 30),
              buildManajemenKeuangan(),
              const SizedBox(height: 30),
              buildLaporanKeuangan(),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget buildProfileCard() {
  return GlassContainer(
    width: double.infinity,
    height: 120,
    borderRadius: BorderRadius.circular(20),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              'assets/images/21.png', // ganti sesuai asset kamu
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),

          // Info User
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Nama",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "ID xxxx",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "XXXXXX",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Icon Mata
          const Icon(
            Icons.remove_red_eye_outlined,
            color: Colors.white70,
            size: 26,
          ),
        ],
      ),
    ),
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
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildFeatureButton(icon: 'assets/icons/Eye.png', label: 'Top Up'),
          buildFeatureButton(icon: 'assets/icons/Eye.png', label: 'Kirim Uang'),
          buildFeatureButton(icon: 'assets/icons/Eye.png', label: 'Bayar'),
          buildFeatureButton(icon: 'assets/icons/Eye.png', label: 'Scan'),
        ],
      ),
    ],
  );
}

Widget buildManajemenKeuangan() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Manajemen Keuangan",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      GlassContainer(
        width: double.infinity,
        height: 120,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildSmallGlassButton(),
              buildSmallGlassButton(),
              buildSmallGlassButton(),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget buildLaporanKeuangan() {
  return GlassContainer(
    width: double.infinity,
    height: 60,
    borderRadius: BorderRadius.circular(16),
    child: const Center(
      child: Text(
        "Laporan Keuangan",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

Widget buildFeatureButton({required String icon, required String label}) {
  return Column(
    children: [
      GlassContainer(
        width: 80,
        height: 80,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Image.asset(icon, width: 28, height: 28),
        ),
      ),
      const SizedBox(height: 25),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
        ),
      ),
    ],
  );
}

Widget buildSmallGlassButton() {
  return GlassContainer(
    width: 70,
    height: 70,
    borderRadius: BorderRadius.circular(16),
    child: const Icon(
      Icons.insert_chart_outlined,
      color: Colors.white70,
      size: 30,
    ),
  );
}

}

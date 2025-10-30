import 'dart:ui';
import 'package:flutter/material.dart';
//import 'package:artos/widgets/aurora.dart';
import 'package:artos/widgets/glass.dart';
import 'package:artos/widgets/bgPurple.dart';
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
      body: BackgroundApp(
        child : SafeArea(
            child: buildMainContent(),
          ),  
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
                buildAksesAplikasi(context),
                const SizedBox(height: 30),
                buildFiturAplikasi(),
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
                child: Image.asset(
                  'assets/images/21.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 15),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nama",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Text(
                        "ID xxxx",
                        style: TextStyle(
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
                    children: const [
                      Text(
                        "Rp. 0000",
                        style: TextStyle(
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
              Navigator.pushNamed(context, '/topup');
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
            colors: [
              Color(0xFFAE00FF),
              Color(0xFF3C00FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Center(
            child: Image.asset(icon, width: 40, height: 40),
          ),
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
        text: "Manajemen Aplikasi", 
        iconPath: 'assets/icons/management.png',
        onTap: (){
          Navigator.pushNamed(context, '/login');
        }),
      
      fiturButton(
        text: "Laporan Keuangan", 
        iconPath: 'assets/icons/management.png')
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
              colors: [
                Color(0xFFAC00FF),
                Color(0xFF3C00FF),
              ],
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

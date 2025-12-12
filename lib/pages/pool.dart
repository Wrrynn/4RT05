import 'package:flutter/material.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';
import 'package:artos/widgets/navbar.dart';

class PoolPage extends StatefulWidget {
  const PoolPage({super.key});

  @override
  State<PoolPage> createState() => _PoolPageState();
}

class _PoolPageState extends State<PoolPage> {
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
          "Pool",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.pinkAccent),
            onPressed: _showBuatGrupSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: BackgroundApp(
        child: SafeArea(
          child: _buildPoolContent(),
        ),
      ),

      // kalau mau navbar kelihatan juga di Pool
      
    );
  }

  // ================== KONTEN POOL ==================

  Widget _buildPoolContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTotalKontribusiCard(),
                const SizedBox(height: 24),

                const Text(
                  "Grup",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Grup 1
                _buildGroupCard(
                  namaGrup: "Bungsu",
                  memberInfo: "7 Member • 5 hari lagi",
                  id: "ID 8989909",
                  pass: "Pass: ******",
                  totalTerkumpul: "Rp. 3,5jt/Rp. 7jt",
                  progress: 0.10,
                  progressText: "10% Terkumpul",
                  kontribusiAnda: "Rp. 100.000",
                ),

                const SizedBox(height: 16),

                // Grup 2
                _buildGroupCard(
                  namaGrup: "Dufan",
                  memberInfo: "7 Member • 5 hari lagi",
                  id: "ID 8989909",
                  pass: "Pass: ******",
                  totalTerkumpul: "Rp. 5jt/Rp. 7jt",
                  progress: 0.80,
                  progressText: "80% Terkumpul",
                  kontribusiAnda: "Rp. 1.000.000",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalKontribusiCard() {
    return GlassContainer(
      width: double.infinity,
      height: 130,
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
            "Total Kontribusi Anda",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Rp. 1000",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Kumpulkan Uang Bersama Secara Pribadi",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard({
    required String namaGrup,
    required String memberInfo,
    required String id,
    required String pass,
    required String totalTerkumpul,
    required double progress,
    required String progressText,
    required String kontribusiAnda,
  }) {
    return GestureDetector(
      onTap: () => _showGroupInfoSheet(namaGrup: namaGrup),
      child: GlassContainer(
        width: double.infinity,
        height: 240,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A0630).withOpacity(0.9),
            const Color(0xFF240743).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Colors.white.withOpacity(0.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // baris atas
            Row(
              children: [
                Expanded(
                  child: Text(
                    namaGrup,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _smallPillButton(
                  label: "Tarik",
                  onTap: () => _showTarikDanaSheet(namaGrup),
                ),
                const SizedBox(width: 8),
                _smallPillButton(
                  label: "Tambah",
                  onTap: () => _showTambahDanaSheet(namaGrup),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              memberInfo,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              id,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
            Text(
              pass,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Terkumpul",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                Text(
                  totalTerkumpul,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0, 1),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF4EC7), Color(0xFF7B3DFF)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            Row(
              children: [
                SizedBox(
                  height: 32,
                  child: Stack(
                    children: [
                      _circleAvatar(0),
                      Positioned(left: 18, child: _circleAvatar(1)),
                      Positioned(left: 36, child: _circleAvatar(2)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _showGroupInfoSheet(namaGrup: namaGrup),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4EC7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Selengkapnya",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  progressText,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Divider(color: Colors.white24, height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.attach_money_rounded,
                        color: Colors.pinkAccent, size: 20),
                    SizedBox(width: 4),
                    Text(
                      "Kontribusi Anda",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  kontribusiAnda,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _smallPillButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4EC7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _circleAvatar(int index) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withOpacity(0.5), width: 2),
        image: const DecorationImage(
          image: AssetImage('assets/images/21.png'), // sesuaikan
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // ================== POPUP / BOTTOM SHEETS ==================

  void _showGroupInfoSheet({required String namaGrup}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _roundedSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Info Grup $namaGrup",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              for (var i = 0; i < 5; i++)
                _memberRow(
                  name: "Member ${i + 1}",
                  id: "ID 10${i}205",
                  amount: "-Rp. 500.000",
                ),

              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Target:",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        "Rp. 7.000.000",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Durasi: 6 bulan lagi",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  _smallPillButton(
                    label: "Pengaturan",
                    onTap: () {
                      Navigator.pop(context);
                      _showPengaturanGrupSheet(namaGrup);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4EC7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Keluar Grup",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPengaturanGrupSheet(String namaGrup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _roundedSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pengaturan Grup",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _glassTextField(label: "Buat Target"),
              const SizedBox(height: 12),
              _glassTextField(label: "Buat Nominal Target"),
              const SizedBox(height: 12),
              _glassTextField(label: "Durasi"),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Simpan"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTambahDanaSheet(String namaGrup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _roundedSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tambah Dana",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _glassTextField(label: "Masukkan Nominal"),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Tambah"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTarikDanaSheet(String namaGrup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _roundedSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tarik Dana",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _glassTextField(label: "Masukkan Nominal"),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Tarik"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBuatGrupSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _roundedSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Buat Grup",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _glassTextField(label: "Nama Grup"),
              const SizedBox(height: 12),
              _glassTextField(label: "Password Grup"),
              const SizedBox(height: 12),
              _glassTextField(label: "Target"),
              const SizedBox(height: 12),
              _glassTextField(label: "Durasi"),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Buat Grup",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =============== Helper Sheet / TextField / Member Row ===============

  Widget _roundedSheet({required Widget child}) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0630),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: child,
      ),
    );
  }

  Widget _glassTextField({required String label}) {
    return GlassContainer(
      width: double.infinity,
      height: 55,
      borderRadius: BorderRadius.circular(14),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.04),
          Colors.white.withOpacity(0.01),
        ],
      ),
      borderColor: Colors.white.withOpacity(0.18),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: label,
            hintStyle: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _memberRow({
    required String name,
    required String id,
    required String amount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _circleAvatar(0),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  id,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.pinkAccent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

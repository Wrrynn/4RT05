import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Wajib: flutter pub add url_launcher
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';
import 'package:artos/controller/topUpCtrl.dart';
import 'package:artos/model/pengguna.dart';
import 'package:artos/model/topup.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});
  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  int step = 1;
  String selectedCategory = ""; // 'bank', 'qris', 'cash'
  String selectedLabel = "";
  bool _isLoading = false;
  
  final TextEditingController _amountController = TextEditingController();
  final TopupController _topupCtrl = TopupController();
  late Pengguna currentUser;
  Topup? pendingTopup;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentUser = ModalRoute.of(context)!.settings.arguments as Pengguna;
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), duration: const Duration(seconds: 2)));
  }

  // Fungsi membuka link Midtrans
  Future<void> _launchMidtrans(String? url) async {
    if (url != null) {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _msg("Tidak bisa membuka link pembayaran");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundApp(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (step == 1) return _stepSelectMethod();
    if (step == 2) return _stepInputAmount();
    return _stepPaymentProcess();
  }

  // --- 1. PILIH METODE (3 Opsi) ---
  Widget _stepSelectMethod() {
    return ListView(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(24),
      children: [
        const Text("Metode Top Up", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        
        _optionCard("Transfer Bank", "Virtual Account (BCA, BNI, dll)", Icons.account_balance, "bank"),
        const SizedBox(height: 12),
        _optionCard("QRIS", "Scan QR Code (Gopay/ShopeePay)", Icons.qr_code_2, "qris"),
        const SizedBox(height: 12),
        _optionCard("Tunai / Cash", "Indomaret / Alfamart", Icons.storefront, "cash"),
      ],
    );
  }

  Widget _optionCard(String title, String subtitle, IconData icon, String category) {
    return GestureDetector(
      onTap: () => setState(() { selectedCategory = category; selectedLabel = title; step = 2; }),
      child: GlassContainer(
        width: double.infinity,
        // height dihapus agar dinamis
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  // --- 2. INPUT NOMINAL ---
  // Daftar nominal cepat yang diminta
  final List<int> _quickAmounts = [25000, 50000, 100000, 200000, 250000, 500000];

  Widget _stepInputAmount() {
    return Padding(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 1. INPUT FIELD (Desain yang sudah disepakati)
          GlassContainer(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Masukkan Jumlah",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      "Rp ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "0",
                          hintStyle: TextStyle(
                            color: Colors.white30,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // 2. OPSI INSTAN (Quick Action Buttons)
          Align(
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 12, // Jarak horizontal antar tombol
            runSpacing: 12, // Jarak vertikal antar baris
            children: _quickAmounts.map((amount) {
              return _buildQuickAmountButton(amount);
            }).toList(),
          ),

          const Spacer(),

          // 3. TOMBOL LANJUT
          _actionButton("Lanjut Pembayaran", () async {
            // Bersihkan format titik/koma sebelum parsing
            String cleanText = _amountController.text.replaceAll('.', '').replaceAll(',', '');
            double amt = double.tryParse(cleanText) ?? 0;
            
            if (amt < 10000) { 
              _msg("Minimal Top Up Rp 10.000"); 
              return; 
            }

            setState(() => _isLoading = true);
            
            var res = await _topupCtrl.createTransaction(
              userId: currentUser.idPengguna.toString(),
              jumlah: amt,
              category: selectedCategory,
              detailName: selectedLabel,
            );

            setState(() => _isLoading = false);

            if (res != null) {
              setState(() { pendingTopup = res; step = 3; });
              _launchMidtrans(res.redirectUrl);
            } else {
              _msg("Gagal membuat transaksi. Cek koneksi / Server Key.");
            }
          }),
        ],
      ),
    );
  }

  // Widget Helper untuk Tombol Nominal Kecil
  Widget _buildQuickAmountButton(int amount) {
    // Format angka sederhana (contoh: 25000 -> 25.000)
    String formatted = amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    return InkWell(
      onTap: () {
        // Saat diklik, isi controller dengan angka yang sudah diformat
        setState(() {
          _amountController.text = formatted; // Input otomatis terisi
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: GlassContainer(
        width: 100, // Lebar tombol fix agar rapi
        padding: const EdgeInsets.symmetric(vertical: 12),
        borderRadius: BorderRadius.circular(12),
        borderColor: Colors.white.withOpacity(0.1),
        child: Center(
          child: Text(
            formatted,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // --- 3. PROSES PEMBAYARAN (Check Status) ---
  Widget _stepPaymentProcess() {
    return Padding(
      key: const ValueKey(3),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_outlined, size: 80, color: Colors.cyanAccent),
          const SizedBox(height: 20),
          const Text("Menunggu Pembayaran", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Silahkan selesaikan pembayaran di halaman Midtrans yang terbuka.", 
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 40),
          
          _actionButton("Buka Halaman Pembayaran Lagi", () {
            _launchMidtrans(pendingTopup?.redirectUrl);
          }, color: Colors.blueAccent),
          
          const SizedBox(height: 16),
          
          _actionButton("Cek Status & Refresh Saldo", () async {
            setState(() => _isLoading = true);
            String status = await _topupCtrl.checkTransactionStatus(
              pendingTopup!.orderId!, 
              currentUser.idPengguna.toString(), 
              pendingTopup!.jumlah
            );
            setState(() => _isLoading = false);

            if (status == "success") {
              _showSuccessDialog();
            } else if (status == "pending") {
              _msg("Pembayaran belum terdeteksi. Silahkan bayar dulu.");
            } else {
              _msg("Status: $status");
            }
          }, color: const Color(0xFFAC00FF)),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text("Berhasil!", style: TextStyle(color: Colors.white)),
        content: Text("Saldo Rp ${pendingTopup?.jumlah} telah masuk.", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup Dialog
              Navigator.pop(context, true); // Kembali ke Home
            },
            child: const Text("OK", style: TextStyle(color: Colors.cyanAccent)),
          )
        ],
      )
    );
  }

  Widget _actionButton(String text, VoidCallback onTap, {Color? color}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? const Color(0xFFAC00FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _isLoading ? null : onTap,
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => step > 1 ? setState(() => step--) : Navigator.pop(context),
          ),
          const Text("Top Up", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
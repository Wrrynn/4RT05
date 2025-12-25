import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';
import 'package:artos/widgets/currency.dart';
import 'package:artos/controller/scanCtrl.dart';
import 'package:artos/model/pengguna.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});
  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  final ScanController _scanCtrl = ScanController();
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return; // Mencegah scan ganda
    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;

    setState(() => _isProcessing = true);
    _scannerController.stop();

    // Identifikasi tipe QR melalui Controller
    final result = _scanCtrl.identifyAndParse(raw);

    if (result['type'] == 'QRIS') {
      _showPaymentSheet(result['data']);
    } 
    else if (result['type'] == 'INTERNAL_TRANSFER') {
      // Navigasi ke halaman kirim uang dengan membawa data rekening
      Navigator.pushReplacementNamed(
        context, 
        '/send', 
        arguments: result['data']['rekening']
      );
    } 
    else {
      _showErrorDialog("Format QR tidak dikenali oleh Artos.");
    }
  }

  // --- UI KONFIRMASI PEMBAYARAN QRIS ---
  void _showPaymentSheet(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A0630),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25))
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Konfirmasi Bayar", 
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _infoItem("Tujuan", data['merchantName']),
            _infoItem("Nominal", data['amount'] != null 
                ? formatCurrency(data['amount']) 
                : "Masukkan Manual di Halaman Berikutnya"),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAC00FF),
                minimumSize: const Size(double.infinity, 50)
              ),
              onPressed: () {
                // 1. Tutup Bottom Sheet terlebih dahulu
                Navigator.pop(context); 
                
                // 2. Navigasi ke halaman detail pembayaran QRIS
                // Pastikan rute '/qrisPayment' sudah didaftarkan di main.dart
                Navigator.pushNamed(
                  context, 
                  '/qrisPayment', 
                  arguments: data // Mengirim data merchantName dan amount dari hasil scan
                );
              },
              child: const Text("Lanjut", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ).then((_) {
      _scannerController.start();
      setState(() => _isProcessing = false);
    });
  }

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Gagal"),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    ).then((_) {
      _scannerController.start();
      setState(() => _isProcessing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundApp(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 280, height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFAC00FF), width: 4)
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: MobileScanner(
                      controller: _scannerController, 
                      onDetect: _onDetect
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text("Arahkan kamera ke QR Code", 
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text("Scan QR", 
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
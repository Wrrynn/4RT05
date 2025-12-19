import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:artos/pages/homePage.dart';
import 'package:artos/model/pengguna.dart';
import 'package:artos/service/db_service.dart';

import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/aurora.dart';
import 'package:artos/widgets/fireflies.dart';
import 'package:artos/widgets/glass.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController _scannerController =
      MobileScannerController();

  bool _hasScanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcode = capture.barcodes.first;
    final raw = barcode.rawValue;

    if (raw == null || raw.isEmpty) return;

    _hasScanned = true;

    debugPrint('QR RAW VALUE: $raw');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR terbaca')),
    );

    // NANTI:
    // - parse QRIS
    // - navigate ke konfirmasi
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxSize = screenWidth * 0.78;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundApp(
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: AnimatedPurpleAuroraBackground()),
              const Positioned.fill(child: FloatingFireflies()),

              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== HEADER =====
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Scan QR Code',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              _scannerController.toggleTorch(),
                          icon: const Icon(
                            Icons.flash_on,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ===== SCAN BOX =====
                    Center(
                      child: Container(
                        width: boxSize,
                        height: boxSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8A2BE2), Color(0xFFDE3AFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.45),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: MobileScanner(
                            controller: _scannerController,
                            onDetect: _onDetect,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== INSTRUCTION =====
                    GlassContainer(
                      width: double.infinity,
                      height: 160,
                      padding: const EdgeInsets.all(16),
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Scan Instruksi',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '1. Posisikan QR code di dalam bingkai',
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '2. Tahan perangkat hingga QR terbaca',
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '3. Lanjutkan ke konfirmasi pembayaran',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
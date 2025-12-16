import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/bgPurple.dart';
import '../widgets/aurora.dart';
import '../widgets/fireflies.dart';
import '../widgets/glass.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _photo;

  Future<void> _openCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );
      if (photo != null) setState(() => _photo = photo);
    } catch (e) {
      // ignore errors for now
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxSize = screenWidth * 0.78; // matches mock: big rounded square

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
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text('Scan QR Code', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w600)),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.flash_on, color: Colors.white),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Scan box
                    Center(
                      child: Container(
                        width: boxSize,
                        height: boxSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(colors: [Color(0xFF8A2BE2), Color(0xFFDE3AFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: Stack(
                          children: [
                            // camera preview or placeholder
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: _photo == null
                                  ? Container(
                                      color: Colors.transparent,
                                      child: const Center(
                                        child: Icon(Icons.camera_alt, color: Colors.white54, size: 48),
                                      ),
                                    )
                                  : Image.file(File(_photo!.path), fit: BoxFit.cover, width: boxSize, height: boxSize),
                            ),

                            // corner markers
                            Positioned(
                              left: 12,
                              top: 12,
                              child: Container(width: 28, height: 28, decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white24, width: 6))),
                            ),
                            Positioned(
                              right: 12,
                              top: 12,
                              child: Container(width: 28, height: 28, decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white24, width: 6))),
                            ),
                            Positioned(
                              left: 12,
                              bottom: 12,
                              child: Container(width: 28, height: 28, decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white24, width: 6))),
                            ),
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: Container(width: 28, height: 28, decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white24, width: 6))),
                            ),

                            // center camera icon (smaller)
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: _openCamera,
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Instructions card
                    GlassContainer(
                      width: double.infinity,
                      height: 160,
                      padding: const EdgeInsets.all(16),
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Scan Instruksi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          SizedBox(height: 12),
                          Text('1. Posisi kan QR code dengan bingkai scan', style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 6),
                          Text('2. Tahan dengan stabil hingga scan selesai', style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 6),
                          Text('3. Lakukan konfirmasi pembayaran', style: TextStyle(color: Colors.white70)),
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
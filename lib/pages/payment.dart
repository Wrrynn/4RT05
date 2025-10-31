import 'package:flutter/material.dart';

import 'dart:math' as math;

import '../widgets/bgPurple.dart';
import '../widgets/aurora.dart';
import '../widgets/fireflies.dart';
import '../widgets/glass.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _vaController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedCategory = 'Kategori';
  final GlobalKey _categoryKey = GlobalKey();

  @override
  void dispose() {
    _vaController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _formatAmount(String text) {
    if (text.isEmpty) return '0.00';
    final cleaned = text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return '0.00';
    try {
      final v = double.parse(cleaned);
      return v.toStringAsFixed(2);
    } catch (_) {
      return '0.00';
    }
  }

  void _showCategoryOverlay() {
    final choices = ['Kategori', 'Tagihan', 'Top Up', 'Pembelian', 'Lainnya'];

    final keyContext = _categoryKey.currentContext;
    if (keyContext == null) return;

    final RenderBox box = keyContext.findRenderObject() as RenderBox;
    final Offset pos = box.localToGlobal(Offset.zero);
    final Size size = box.size;
    final overlay = Overlay.of(context);

    final screenHeight = MediaQuery.of(context).size.height;
    final menuHeight = math.min(choices.length * 56.0, screenHeight * 0.5);
    double top = pos.dy + size.height + 8.0;
    if (top + menuHeight + 20 > screenHeight) {
      // not enough space below, open above
      top = math.max(20.0, pos.dy - menuHeight - 8.0);
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => entry.remove(),
          child: Material(
            color: Colors.black.withOpacity(0.0), // transparent background
            child: Stack(
              children: [
                Positioned(
                  left: pos.dx,
                  top: top,
                  width: size.width,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 220),
                    builder: (context, scale, child) {
                      final opacity = ((scale - 0.8) / (1 - 0.8)).clamp(
                        0.0,
                        1.0,
                      );
                      return Transform.scale(
                        scale: scale,
                        alignment: Alignment.topCenter,
                        child: Opacity(opacity: opacity, child: child),
                      );
                    },
                    child: Container(
                      constraints: BoxConstraints(maxHeight: menuHeight),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(choices.length, (i) {
                            return InkWell(
                              onTap: () {
                                setState(() => _selectedCategory = choices[i]);
                                entry.remove();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  choices[i],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 40;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundApp(
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: AnimatedPurpleAuroraBackground()),
              const Positioned.fill(child: FloatingFireflies()),

              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Pembayaran',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Balance card
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C4DFF), Color(0xFF4A00E0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Dana Saat Ini',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Rp. 00000000',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Text(
                        'Masukkan Nomor VA',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GlassContainer(
                        width: cardWidth,
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        borderRadius: BorderRadius.circular(12),
                        child: TextField(
                          controller: _vaController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration.collapsed(
                            hintText: 'Masukkan Nomor VA',
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GlassContainer(
                        width: cardWidth,
                        height: 120,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Masukkan Jumlah',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Rp',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    decoration: const InputDecoration.collapsed(
                                      hintText: '0.00',
                                      hintStyle: TextStyle(
                                        color: Colors.white24,
                                        fontSize: 28,
                                      ),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        key: _categoryKey,
                        onTap: () => _showCategoryOverlay(),
                        child: GlassContainer(
                          width: cardWidth,
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          borderRadius: BorderRadius.circular(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedCategory,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              Positioned(
                left: 20,
                right: 20,
                bottom: 28,
                child: SizedBox(
                  height: 52,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = _formatAmount(_amountController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Bayar: Rp $amount')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C4DFF), Color(0xFF4A00E0)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'Bayar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

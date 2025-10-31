import 'package:flutter/material.dart';

import '../widgets/bgPurple.dart';
import '../widgets/aurora.dart';
import '../widgets/fireflies.dart';
import '../widgets/glass.dart';

class SendPage extends StatefulWidget {
  const SendPage({Key? key}) : super(key: key);

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _selectedCategory = 'Pilih Kategori';

  @override
  void dispose() {
    _contactController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String _formatAmountForDisplay(String text) {
    if (text.isEmpty) return '0.00';
    final cleaned = text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return '0.00';
    try {
      final value = double.parse(cleaned);
      return value.toStringAsFixed(2);
    } catch (_) {
      return '0.00';
    }
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
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Kirim Uang',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Balance card (gradient)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
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

                    // Quick contact input
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: GlassContainer(
                        width: cardWidth,
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        borderRadius: BorderRadius.circular(12),
                        child: TextField(
                          controller: _contactController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration.collapsed(
                            hintText: 'Masukkan Kontak atau ID',
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Amount glass card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
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

                    const SizedBox(height: 12),

                    // Message (optional)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: GlassContainer(
                        width: cardWidth,
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        borderRadius: BorderRadius.circular(12),
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration.collapsed(
                            hintText: 'Tulis Pesan (opsional)',
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Category dropdown (simple)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: GestureDetector(
                        onTap: () async {
                          final choices = [
                            'Pilih Kategori',
                            'Belanja',
                            'Transport',
                            'Hadiah',
                            'Lainnya',
                          ];
                          final selected = await showModalBottomSheet<String>(
                            context: context,
                            builder: (ctx) {
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: choices.length,
                                itemBuilder: (_, i) => ListTile(
                                  title: Text(choices[i]),
                                  onTap: () =>
                                      Navigator.of(ctx).pop(choices[i]),
                                ),
                              );
                            },
                          );
                          if (selected != null)
                            setState(() => _selectedCategory = selected);
                        },
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

              // Bottom button
              Positioned(
                left: 20,
                right: 20,
                bottom: 28,
                child: SizedBox(
                  height: 52,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = _formatAmountForDisplay(
                          _amountController.text,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Kirim Dana: Rp $amount')),
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
                            'Kirim Dana',
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

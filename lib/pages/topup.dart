import 'package:flutter/material.dart';
import '../widgets/bgPurple.dart';
import '../widgets/aurora.dart';
import '../widgets/fireflies.dart';
import '../widgets/glass.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({Key? key}) : super(key: key);

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  int _selectedSource = 0; // 0 = Kartu Debit, 1 = Eksternal Wallet
  final TextEditingController _amountController = TextEditingController();

  String _formatAmount(String text) {
    if (text.isEmpty) return '0.00';
    // keep only digits and possible decimal separator
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
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 40; // used by GlassContainer

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundApp(
        child: SafeArea(
          child: Stack(
            children: [
              // animated aurora + subtle fireflies
              const Positioned.fill(child: AnimatedPurpleAuroraBackground()),
              const Positioned.fill(child: FloatingFireflies()),

              // main content
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 140),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              'Top Up',
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

                      // Balance gradient card (kept as simple decorated container)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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

                      const SizedBox(height: 28),

                      // Amount card using GlassContainer
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GlassContainer(
                          width: cardWidth,
                          height: 120,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 18,
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
                                  const SizedBox(width: 8),
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
                                      decoration:
                                          const InputDecoration.collapsed(
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

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          'Asal Dana',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Source cards using GlassContainer
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedSource = 0),
                          child: GlassContainer(
                            width: cardWidth,
                            height: 68,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            borderRadius: BorderRadius.circular(12),
                            borderColor: _selectedSource == 0
                                ? Colors.pinkAccent
                                : Colors.white24,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.credit_card,
                                      color: Colors.white70,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Kartu Debit',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _selectedSource == 0
                                          ? Colors.pinkAccent
                                          : Colors.white24,
                                    ),
                                  ),
                                  child: _selectedSource == 0
                                      ? Container(
                                          margin: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.pinkAccent,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedSource = 1),
                          child: GlassContainer(
                            width: cardWidth,
                            height: 68,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            borderRadius: BorderRadius.circular(12),
                            borderColor: _selectedSource == 1
                                ? Colors.pinkAccent
                                : Colors.white24,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.white70,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Eksternal Wallet',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _selectedSource == 1
                                          ? Colors.pinkAccent
                                          : Colors.white24,
                                    ),
                                  ),
                                  child: _selectedSource == 1
                                      ? Container(
                                          margin: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.pinkAccent,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
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
              ),

              // Bottom action button
              Positioned(
                left: 20,
                right: 20,
                bottom: 28,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = _formatAmount(_amountController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Tambah Dana: Rp $amount (via ${_selectedSource == 0 ? 'Kartu Debit' : 'Eksternal Wallet'})',
                            ),
                          ),
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
                            'Tambah Dana',
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

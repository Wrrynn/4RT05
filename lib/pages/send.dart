import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';

class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final List<String> _categories = [
    'Keluarga',
    'Teman',
    'Belanja',
    'Tagihan',
    'Transportasi',
    'Makanan & Minuman',
    'Lainnya',
  ];

  String? _selectedCategory;

  @override
  void dispose() {
    _contactController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: BackgroundApp(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCurrentBalanceCard(),
                        const SizedBox(height: 24),
                        const Text(
                          "Kirim Cepat",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildContactField(),
                        const SizedBox(height: 14),
                        _buildAmountField(),
                        const SizedBox(height: 14),
                        _buildMessageField(),
                        const SizedBox(height: 14),
                        _buildCategoryDropdown(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSubmitButton(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- APPBAR ----------------

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Kirim Uang',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- KARTU SALDO ----------------

  Widget _buildCurrentBalanceCard() {
    return GlassContainer(
      width: double.infinity,
      height: 90,
      borderRadius: BorderRadius.circular(18),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFAC00FF),
          Color(0xFF3C00FF),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "Dana Saat Ini",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Rp. 00000000",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- FIELD KONTAK ----------------

  Widget _buildContactField() {
    return GlassContainer(
      width: double.infinity,
      height: 60,
      borderRadius: BorderRadius.circular(16),
      borderColor: Colors.white.withOpacity(0.18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      gradient: LinearGradient(
        colors: [
          Colors.black.withOpacity(0.25),
          Colors.black.withOpacity(0.10),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: TextField(
        controller: _contactController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: "Masukkan Kontak atau ID",
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ---------------- FIELD JUMLAH ----------------

  Widget _buildAmountField() {
    return GlassContainer(
      width: double.infinity,
      height: 130,
      borderRadius: BorderRadius.circular(18),
      borderColor: Colors.white.withOpacity(0.18),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      gradient: LinearGradient(
        colors: [
          Colors.black.withOpacity(0.25),
          Colors.black.withOpacity(0.10),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Masukkan Jumlah",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Rp",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: "0.00",
                    hintStyle: TextStyle(
                      color: Colors.white38,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- FIELD PESAN ----------------

  Widget _buildMessageField() {
    return GlassContainer(
      width: double.infinity,
      height: 60,
      borderRadius: BorderRadius.circular(16),
      borderColor: Colors.white.withOpacity(0.18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      gradient: LinearGradient(
        colors: [
          Colors.black.withOpacity(0.25),
          Colors.black.withOpacity(0.10),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: TextField(
        controller: _messageController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: "Tulis Pesan (opsional)",
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
        maxLines: 2,
      ),
    );
  }

  // ---------------- DROPDOWN KATEGORI ----------------

  Widget _buildCategoryDropdown() {
    return GlassContainer(
      width: double.infinity,
      height: 60,
      borderRadius: BorderRadius.circular(16),
      borderColor: Colors.white.withOpacity(0.18),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gradient: LinearGradient(
        colors: [
          Colors.black.withOpacity(0.25),
          Colors.black.withOpacity(0.10),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: const Color(0xFF2B0B3A),
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white),
            value: _selectedCategory,
            hint: const Text(
              'Kategori',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            items: _categories
                .map(
                  (kategori) => DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
        ),
      ),
    );
  }

  // ---------------- TOMBOL KIRIM ----------------

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _onSendPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFAC00FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Kirim Dana",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _onSendPressed() {
    // Sementara tampilkan snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mengirim ${_amountController.text.isEmpty ? "0" : _amountController.text} '
          'ke ${_contactController.text.isEmpty ? "penerima" : _contactController.text}'
          '${_selectedCategory != null ? " (Kategori: $_selectedCategory)" : ""}',
        ),
      ),
    );
  }
}

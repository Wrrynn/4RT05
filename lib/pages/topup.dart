import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';
import 'package:artos/controller/topUpCtrl.dart';
import 'package:artos/model/pengguna.dart';

enum TopUpSource { debitCard, externalWallet }

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final TextEditingController _amountController = TextEditingController();
  TopUpSource _selectedSource = TopUpSource.debitCard;

  late Pengguna currentUser;
  final TopupController _topupCtrl = TopupController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentUser = ModalRoute.of(context)!.settings.arguments as Pengguna;
  }

  @override
  void dispose() {
    _amountController.dispose();
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
                        _buildAmountInput(),
                        const SizedBox(height: 24),
                        _buildSourceTitle(),
                        const SizedBox(height: 12),
                        _buildSourceSelector(),
                      ],
                    ),
                  ),
                ),

                // Tombol Tambah Dana di bawah
                const SizedBox(height: 8),
                _buildSubmitButton(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
            title: const Text(
              'Top Up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
    );
  }

  // ================== WIDGET BAGIAN ATAS ==================

  Widget _buildCurrentBalanceCard() {
    return GlassContainer(
      width: double.infinity,
      height: 90,
      borderRadius: BorderRadius.circular(18),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFAC00FF), Color(0xFF3C00FF)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft, // ✅ paksa konten ke kiri
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
            "Rp. 000000000",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      )
      
    );
  }

  Widget _buildAmountInput() {
    return GlassContainer(
      width: double.infinity,
      height: 130,
      borderRadius: BorderRadius.circular(18),
      gradient: LinearGradient(
        colors: [
          Colors.black.withOpacity(0.25),
          Colors.black.withOpacity(0.10),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: Colors.white.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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

  Widget _buildSourceTitle() {
    return const Text(
      "Asal Dana",
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSourceSelector() {
    return Column(
      children: [
        _sourceItem(
          label: "Kartu Debit",
          isSelected: _selectedSource == TopUpSource.debitCard,
          onTap: () {
            setState(() => _selectedSource = TopUpSource.debitCard);
          },
        ),
        const SizedBox(height: 12),
        _sourceItem(
          label: "Eksternal Wallet",
          isSelected: _selectedSource == TopUpSource.externalWallet,
          onTap: () {
            setState(() => _selectedSource = TopUpSource.externalWallet);
          },
        ),
      ],
    );
  }

  Widget _sourceItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        width: double.infinity,
        height: 75,
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  const Color(0xFFAC00FF).withOpacity(0.35),
                  const Color(0xFF3C00FF).withOpacity(0.35),
                ]
              : [
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.10),
                ],
        ),
        borderColor: isSelected
            ? const Color(0xFFF6339A)
            : Colors.white.withOpacity(0.2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFF6339A) : Colors.white54,
                  width: 2,
                ),
              ),
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFFF6339A)
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () async {
          double jumlah = double.tryParse(_amountController.text) ?? 0;
          if (jumlah <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Masukkan jumlah yang valid")),
            );
            return;
          }

          String metode = _selectedSource == TopUpSource.debitCard
              ? "Kartu Debit"
              : "Eksternal Wallet";

          // Panggil TopupController
          String? result = await _topupCtrl.topUp(
            pengguna: currentUser,
            jumlah: jumlah,
            metode: metode,
          );

          if (result != null) {
            // error
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(result)));
          } else {
            // sukses
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Topup berhasil! Saldo: Rp ${currentUser.saldo}"),
              ),
            );
            _amountController.clear();
            setState(() {}); // refresh UI jika ada tampilan saldo
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFAC00FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Tambah Dana",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

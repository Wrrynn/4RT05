import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';
import 'package:artos/controller/pembayaranCtrl.dart';
import 'package:artos/widgets/currency.dart';
import 'package:artos/service/db_service.dart';
import 'package:artos/model/pengguna.dart';
import 'package:artos/model/kategori.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class PaymentResult {
  final bool success;
  final String message;
  final String? transactionId;

  PaymentResult({
    required this.success,
    required this.message,
    this.transactionId,
  });
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _vaController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final PaymentController _paymentCtrl = PaymentController();

  late Pengguna _pengguna;
  double _currentSaldo = 0.0;
  bool _loading = true;
  bool _processing = false;
  VirtualAccount? _parsedVA;
  String _vaErrorMsg = '';

  List<Kategori> _categories = [];
  Kategori? _selectedCategory;

  Future<void> _loadKategori() async {
    try {
      final list = await _paymentCtrl.getKategoriDropdown(_pengguna.idPengguna);

      if (!mounted) return;

      setState(() {
        _categories = list;
      });
    } catch (e) {
      debugPrint('Gagal load kategori: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _vaController.addListener(_onVAChanged);
  }

  @override
  void dispose() {
    _vaController.removeListener(_onVAChanged);
    _vaController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = DBService.client.auth.currentUser?.id ?? '';
      if (userId.isEmpty) {
        setState(() => _loading = false);
        return;
      }

      final res = await DBService.client
          .from('Pengguna')
          .select()
          .eq('id_pengguna', userId)
          .maybeSingle();

      if (res != null) {
        final p = Pengguna.fromJson(res as Map<String, dynamic>);
        setState(() {
          _pengguna = p;
          _currentSaldo = p.saldo;
          _loading = false;
        });

        await _loadKategori();
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _onVAChanged() {
    final vaStr = _vaController.text.trim();
    if (vaStr.isEmpty) {
      setState(() {
        _parsedVA = null;
        _vaErrorMsg = '';
      });
      return;
    }

    final parsed = _paymentCtrl.parseVA(vaStr);
    setState(() {
      _parsedVA = parsed;
      _vaErrorMsg = parsed == null ? 'VA tidak valid' : '';
    });
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
                          "Masukkan Nomor VA",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildVaField(),
                        const SizedBox(height: 12),
                        _buildVAInfoCard(),
                        const SizedBox(height: 18),
                        _buildCategoryDropdown(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildPayButton(),
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
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Pembayaran',
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

  Widget _buildCurrentBalanceCard() {
    if (_loading) {
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
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

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
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Dana Saat Ini",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatCurrency(_currentSaldo),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassContainer(
          width: double.infinity,
          height: 60,
          borderRadius: BorderRadius.circular(16),
          borderColor: _vaErrorMsg.isNotEmpty
              ? Colors.red.withOpacity(0.5)
              : Colors.white.withOpacity(0.18),
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
            controller: _vaController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Masukkan Nomor VA (16 digit)",
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (_vaErrorMsg.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _vaErrorMsg,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildVAInfoCard() {
  if (_parsedVA == null) return const SizedBox.shrink();

  final va = _parsedVA!;
  final bool isExpired = va.isExpired();
  final bool saldoTidakCukup = _currentSaldo < va.totalAmount;

  final bool isError = isExpired || saldoTidakCukup;

  final Color borderColor =
      isError ? Colors.redAccent : const Color(0xFF28D17C);

  final List<Color> gradientColors = isError
      ? [
          Colors.redAccent.withOpacity(0.25),
          Colors.red.withOpacity(0.15),
        ]
      : [
          const Color(0xFF28D17C).withOpacity(0.2),
          const Color(0xFF1DD45E).withOpacity(0.2),
        ];

  return GlassContainer(
    width: double.infinity,
    borderRadius: BorderRadius.circular(18),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors,
    ),
    padding: const EdgeInsets.all(14),
    borderColor: borderColor.withOpacity(0.6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Merchant: ${va.merchantName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Bank: ${va.bankName}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Text(
          'Jumlah: ${formatCurrency(va.totalAmount)}',
          style: TextStyle(
            color: isError ? Colors.redAccent : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isExpired)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              '⚠ Nomor VA sudah kadaluarsa',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (!isExpired && saldoTidakCukup)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              '⚠ Saldo tidak mencukupi',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    ),
  );
}

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pilih Kategori Transaksi",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GlassContainer(
          width: double.infinity,
          height: 60,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Kategori>(
              dropdownColor: const Color(0xFF2B0B3A),
              isExpanded: true,
              value: _selectedCategory,
              hint: const Text(
                'Pilih Kategori',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              items: _categories.map((kategori) {
                return DropdownMenuItem<Kategori>(
                  value: kategori,
                  child: Text(
                    kategori.namaKategori, // Menampilkan nama dari database
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    final isEnabled =
        _parsedVA != null &&
        _selectedCategory != null &&
        !_processing &&
        !_loading;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isEnabled ? _onPayPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? const Color(0xFFAC00FF)
              : const Color(0xFFAC00FF).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _processing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                "Bayar",
                style: TextStyle(
                  color: isEnabled
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFFFFFFFF).withOpacity(0.001),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  void _onPayPressed() async {
    if (_parsedVA == null) {
      _showToast('VA tidak valid');
      return;
    }
    if (_selectedCategory == null) {
      _showToast('Pilih kategori terlebih dahulu');
      return;
    }

    setState(() => _processing = true);

    final result = await _paymentCtrl.processPayment(
      vaNumber: _vaController.text.trim(),
      idPengguna: _pengguna.idPengguna,
      idKategori: _selectedCategory!.idKategori,
      biayaTransfer: 0.0,
      deskripsi: 'Pembayaran VA',
    );

    if (!mounted) return;

    setState(() => _processing = false);

    if (result.success) {
      await _loadUserData();
      _vaController.clear();
      _amountController.clear();
      setState(() => _selectedCategory = null);

      _showToast('${result.message}\nID: ${result.transactionId}');
    } else {
      _showToast(result.message);
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

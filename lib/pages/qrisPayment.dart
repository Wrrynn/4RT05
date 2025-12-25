import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';
import 'package:artos/widgets/currency.dart';
import 'package:artos/controller/scanCtrl.dart';
import 'package:artos/controller/ManajemenCtrl.dart';
import 'package:artos/model/kategori.dart';
import 'package:artos/model/pengguna.dart';
import 'package:artos/service/db_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QrisPaymentPage extends StatefulWidget {
  const QrisPaymentPage({super.key}); // Parameter dihapus agar tidak error di main.dart

  @override
  State<QrisPaymentPage> createState() => _QrisPaymentPageState();
}

class _QrisPaymentPageState extends State<QrisPaymentPage> {
  final ScanController _scanCtrl = ScanController();
  final KategoriController _katCtrl = KategoriController();
  final TextEditingController _amountCtrl = TextEditingController();
  
  List<Kategori> _categories = [];
  String? _selectedCategoryId; // Menggunakan String ID agar Dropdown tidak error
  
  bool _isLoading = true; // Set default true untuk loading awal
  late Map<String, dynamic> _qrisData;
  Pengguna? _user; // Variabel lokal untuk menyimpan data pengguna

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 1. Ambil data QRIS dari arguments
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Map<String, dynamic>) {
      _qrisData = args;
      if (_qrisData['amount'] != null && _amountCtrl.text.isEmpty) {
        _amountCtrl.text = _qrisData['amount'].toString();
      }
    }
    // 2. Load data user dan kategori
    _initData();
  }

  Future<void> _initData() async {
    final uid = DBService.client.auth.currentUser?.id ?? '';
    try {
      // Ambil data saldo terbaru dari database
      final userRes = await DBService.client.from('Pengguna').select().eq('id_pengguna', uid).maybeSingle();
      final cats = await _katCtrl.getKategoriAnggaranDanSync(uid);
      
      if (mounted) {
        setState(() {
          if (userRes != null) _user = Pengguna.fromJson(userRes);
          _categories = cats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handlePayment() async {
    // Perbaikan: Gunakan _selectedCategoryId
    if (_selectedCategoryId == null) {
      _showSnackBar("Pilih kategori terlebih dahulu");
      return;
    }

    final amt = double.tryParse(_amountCtrl.text) ?? 0;
    if (amt <= 0) {
      _showSnackBar("Nominal tidak valid");
      return;
    }

    if (_user == null) return;

    setState(() => _isLoading = true);
    try {
      // Panggil controller dengan data riil
      await _scanCtrl.prosesPembayaran(
        uid: _user!.idPengguna,
        idKategori: _selectedCategoryId!,
        merchantName: _qrisData['merchantName'] ?? "Merchant QRIS",
        amount: amt,
        saldoSaatIni: _user!.saldo,
      );
      
      if (mounted) {
        _showSnackBar("Pembayaran Berhasil!", isError: false);
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      _showSnackBar("Gagal: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundApp(
        child: SafeArea(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
                children: [
                  _buildHeader("Detail Pembayaran"),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMerchantCard(),
                          const SizedBox(height: 24),
                          _buildAmountField(), 
                          const SizedBox(height: 24),
                          _buildCategorySection(),
                        ],
                      ),
                    ),
                  ),
                  _buildSubmitButton(),
                ],
              ),
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 12, bottom: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMerchantCard() {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          const Icon(Icons.storefront_rounded, color: Colors.white70, size: 40),
          const SizedBox(height: 12),
          Text(
            _qrisData['merchantName'] ?? "Merchant Unknown",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return GlassContainer(
      width: double.infinity,
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Masukkan Jumlah", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text("Rp", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: "0.00", hintStyle: TextStyle(color: Colors.white30)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pilih Kategori", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GlassContainer(
          width: double.infinity,
          height: 60,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>( // Harus String agar sinkron
              value: _selectedCategoryId,
              dropdownColor: const Color(0xFF2B0B3A),
              isExpanded: true,
              hint: const Text("Pilih Kategori", style: TextStyle(color: Colors.white54)),
              items: _categories.map((e) => DropdownMenuItem<String>(
                value: e.idKategori, 
                child: Text(e.namaKategori, style: const TextStyle(color: Colors.white))
              )).toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFAC00FF), minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        onPressed: _isLoading ? null : _handlePayment,
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Konfirmasi Bayar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: isError ? Colors.redAccent : Colors.green));
  }
}
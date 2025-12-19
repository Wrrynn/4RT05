import 'dart:ui';
import 'package:artos/widgets/currency.dart';
import 'package:flutter/material.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';
import 'package:artos/service/db_service.dart';
import 'package:artos/controller/sendCtrl.dart';
import 'package:artos/model/kategori.dart';
import 'package:artos/model/pengguna.dart';

class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final SendController _ctrl = SendController(DBService.client);

  List<Kategori> _categories = [];
  String? _selectedCategoryId;
  String? _selectedRecipientRekening;
  String? _currentUserId;
  double _currentSaldo = 0.0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = DBService.client.auth.currentUser?.id;
    if (_currentUserId != null) {
      _loadInitialData();
    } else {
      // no authenticated user — show warning
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User belum login')));
      });
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _loading = true);
    try {
      final cats = await _ctrl.getKategoriDropdown(_currentUserId!);
      final saldo = await _ctrl.getSaldo(_currentUserId!);
      setState(() {
        _categories = cats;
        _currentSaldo = saldo;
      });
      
      if (cats.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada kategori di database. Buat kategori terlebih dahulu.'),
            backgroundColor: Colors.red,
          )
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal load data: $e'))
      );
    } finally {
      setState(() => _loading = false);
    }
  }

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
      ) 
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _contactController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Masukkan Rekening Penerima",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: _openSearchRecipient,
            icon: const Icon(Icons.search, color: Colors.white70),
          ),
        ],
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
    // Jika tidak ada kategori, tampilkan pesan error
    if (_categories.isEmpty) {
      return GlassContainer(
        width: double.infinity,
        height: 60,
        borderRadius: BorderRadius.circular(16),
        borderColor: Colors.red.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.1),
            Colors.red.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: const Center(
          child: Text(
            'Anda belum memiliki kategori. Buat kategori terlebih dahulu.',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

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
            value: _selectedCategoryId,
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
                    value: kategori.idKategori,
                    child: Text(kategori.namaKategori),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
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
        onPressed: _loading ? null : _onSendPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFAC00FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _loading ? const CircularProgressIndicator() : const Text(
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

  Future<void> _openSearchRecipient() async {
    final selected = await showDialog<Pengguna?>(
      context: context,
      builder: (ctx) {
        final TextEditingController qCtrl = TextEditingController();
        List<Pengguna> results = [];
        bool searching = false;
        return StatefulBuilder(builder: (c, setSt) {
          return AlertDialog(
            title: const Text('Cari Penerima'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: qCtrl,
                  decoration: const InputDecoration(hintText: 'Ketik nama'),
                  onChanged: (v) async {
                    if (v.trim().isEmpty) return;
                    setSt(() => searching = true);
                    try {
                      final r = await _ctrl.searchPengguna(v.trim());
                      setSt(() => results = r);
                    } catch (e) {
                      setSt(() => results = []);
                    } finally {
                      setSt(() => searching = false);
                    }
                  },
                ),
                const SizedBox(height: 12),
                if (searching) const CircularProgressIndicator(),
                if (!searching && results.isEmpty) const Text('Tidak ada hasil'),
                if (results.isNotEmpty)
                  SizedBox(
                    height: 200,
                    width: double.maxFinite,
                    child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final p = results[index];
                        return ListTile(
                          title: Text(p.namaLengkap),
                          subtitle: Text(p.rekening ?? 'Tanpa rekening'),
                          onTap: () => Navigator.of(ctx).pop(p),
                        );
                      },
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Batal')),
            ],
          );
        });
      },
    );

    if (selected != null) {
      setState(() {
        _selectedRecipientRekening = selected.rekening;
        _contactController.text = selected.rekening ?? '';
      });
    }
  }

  void _onSendPressed() async {
    final penerimaRekening = _selectedRecipientRekening ?? _contactController.text.trim();
    final nominal = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;

    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User belum login')));
      return;
    }
    if (penerimaRekening.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi rekening penerima')));
      return;
    }
    
    if (nominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nominal tidak valid')));
      return;
    }
    
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kategori')));
      return;
    }

    setState(() => _loading = true);
    try {
      // Validasi rekening penerima ada di database
      final penerima = await _ctrl.getPenggunaByRekening(penerimaRekening);
      if (penerima == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rekening penerima tidak ditemukan.'),
            backgroundColor: Colors.red,
          )
        );
        setState(() => _loading = false);
        return;
      }
      
      await _ctrl.kirimUang(
        pengirimId: _currentUserId!,
        penerimaRekening: penerimaRekening,
        kategoriId: _selectedCategoryId!,
        nominal: nominal,
        metodeTransaksi: 'transfer',
        deskripsi: _messageController.text,
        biayaTransfer: 0,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi berhasil')));
      _amountController.clear();
      _contactController.clear();
      setState(() {
        _selectedCategoryId = null;
        _selectedRecipientRekening = null;
      });
      // refresh balance
      final s = await _ctrl.getSaldo(_currentUserId!);
      setState(() => _currentSaldo = s);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }
}


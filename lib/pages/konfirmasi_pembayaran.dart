import 'package:flutter/material.dart';
import 'package:artos/model/pengguna.dart';
import 'package:artos/model/transaksi.dart';
import 'package:artos/controller/scanCtrl.dart'; 

class KonfirmasiPembayaranPage extends StatefulWidget {
  final Pengguna pengguna;

  final String merchantName;
  final double saldo;
  final double? presetAmount; // null = QRIS static
  final Map<String, String> tlv;

  // ✅ controller existing kamu
  final QrisCtrl qrisCtrl;

  // ✅ inject fungsi DB biar tidak bergantung nama method DBService kamu
  final Future<void> Function(Transaksi trx) insertTransaksi;
  final Future<void> Function(String userId, double deltaSaldo) updateSaldo;

  const KonfirmasiPembayaranPage({
    super.key,
    required this.pengguna,
    required this.merchantName,
    required this.saldo,
    required this.tlv,
    required this.qrisCtrl,
    required this.insertTransaksi,
    required this.updateSaldo,
    this.presetAmount,
  });

  @override
  State<KonfirmasiPembayaranPage> createState() =>
      _KonfirmasiPembayaranPageState();
}

class _KonfirmasiPembayaranPageState extends State<KonfirmasiPembayaranPage> {
  late final TextEditingController _amountCtrl;

  String? _kategoriId;
  bool _loading = false;

  // Dummy kategori (ganti nanti pakai data kategori dari DB kamu)
  final Map<String, String> kategoriMap = const {
    'kat_makan': 'Makan & Minum',
    'kat_transport': 'Transport',
    'kat_belanja': 'Belanja',
    'kat_tagihan': 'Tagihan',
    'kat_lainnya': 'Lainnya',
  };

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.presetAmount != null
          ? widget.presetAmount!.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0614),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 16),
            _saldoCard(),
            const SizedBox(height: 18),
            Expanded(child: _form()),
            _payButton(),
          ],
        ),
      ),
    );
  }

  // ===== UI =====

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text(
            'Konfirmasi Pembayaran',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _saldoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF6D1BFF), Color(0xFF8C2BFF)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dana Saat Ini',
                style: TextStyle(color: Colors.white.withOpacity(0.9))),
            const SizedBox(height: 6),
            Text(
              'Rp ${widget.saldo.toStringAsFixed(0)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _glass(
            Padding(
              padding: const EdgeInsets.all(14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.merchantName,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _glass(
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Masukkan Jumlah',
                      style: TextStyle(color: Colors.white.withOpacity(0.7))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Rp ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      Expanded(
                        child: TextField(
                          controller: _amountCtrl,
                          enabled: widget.presetAmount ==
                              null, // dynamic -> tidak bisa diubah
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.presetAmount != null)
                    Text('Nominal dari QRIS (tidak bisa diubah)',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _glass(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonFormField<String>(
                value: _kategoriId,
                dropdownColor: const Color(0xFF1B0B2E),
                decoration: const InputDecoration(border: InputBorder.none),
                hint: const Text('Kategori',
                    style: TextStyle(color: Colors.white70)),
                iconEnabledColor: Colors.white,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
                items: kategoriMap.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _kategoriId = v),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _payButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B22FF),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _loading ? null : _onPay,
          child: _loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Bayar',
                  style: TextStyle(fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }

  // ===== ACTION =====

  Future<void> _onPay() async {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;

    if (amount <= 0) return _toast('Nominal tidak valid');
    if (_kategoriId == null) return _toast('Pilih kategori');

    setState(() => _loading = true);

    try {
      // ✅ bikin transaksi lewat controller kamu (QrisCtrl)
      final trx = widget.qrisCtrl.buildTransaksiQris(
        idPengguna: widget.pengguna.idPengguna, // sesuaikan kalau field beda
        idKategori: _kategoriId!,
        merchantName: widget.merchantName,
        amount: amount,
      );

      // ✅ proses bayar lewat controller kamu (QrisCtrl)
      await widget.qrisCtrl.bayar(
        saldoSaatIni: widget.saldo,
        transaksi: trx,
        dbInsert: widget.insertTransaksi,
        dbUpdateSaldo: (delta) =>
            widget.updateSaldo(widget.pengguna.idPengguna, delta),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _toast(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _glass(Widget child) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: child,
    );
  }
}

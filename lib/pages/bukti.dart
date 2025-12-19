import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';

class BuktiPembayaranPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const BuktiPembayaranPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final type = (data['type'] ?? '').toString();
    final isTopup = type.toLowerCase() == 'topup';

    final title = (data['title'] ?? (isTopup ? 'Top Up' : '-')).toString();

    // Metode: ambil metode, fallback subtitle. Kalau subtitle ada "• sukses", ambil kiri saja.
    final metodeRaw = (data['metode'] ?? data['subtitle'] ?? '-').toString();
    final metode = metodeRaw.split('•').first.trim();

    // Status selalu berhasil
    const status = 'Berhasil';

    final jumlah = _toNum(data['jumlah'] ?? _extractAmount(data['amount']));
    final biaya = _toNum(data['biaya'] ?? 0);
    final total = _toNum(data['total'] ?? (jumlah + biaya));

    // ===== Ambil ID ASLI lalu pendekkan (TIDAK buang huruf) =====
    final rawId = data['id_transaksi'] ??
        data['id_topup'] ??
        data['order_id'] ??
        data['orderId'] ??
        data['id'];

    final idTrx = _shortId(rawId, take: 8);

    // Dari selalu "Anda"
    const dari = 'Anda';

    // Ke: kalau controller sudah kirim 'ke' pakai itu, kalau tidak fallback ke title
    final ke = (data['ke'] ?? title).toString();

    final dt = _toDateTime(
      data['tanggal'] ?? data['waktu'] ?? data['waktu_dibuat'],
    ).toLocal();

    final tanggalStr =
        '${dt.day.toString().padLeft(2, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.year}';

    final waktuStr =
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';

    final headerTitle = isTopup ? 'TopUp Berhasil' : 'Transaksi Berhasil';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBar(context),
      body: BackgroundApp(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Expanded(
                  child: GlassContainer(
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(24),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          headerTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        const Text(
                          "Pembayaran Berhasil Diselesaikan",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Jumlah",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          _rupiah(jumlah),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24),

                        if (isTopup)
                          _topupBody(
                            metode: metode,
                            tanggal: tanggalStr,
                            waktu: waktuStr,
                            biaya: biaya,
                            total: total,
                            idTrx: idTrx,
                            status: status,
                          )
                        else
                          _transferBody(
                            title: title,
                            tanggal: tanggalStr,
                            waktu: waktuStr,
                            metode: metode,
                            biaya: biaya,
                            total: total,
                            idTrx: idTrx,
                            status: status,
                            dari: dari,
                            ke: ke,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Unduh",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAC00FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Bagikan",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== TOPUP BODY =====
  Widget _topupBody({
    required String metode,
    required String tanggal,
    required String waktu,
    required num biaya,
    required num total,
    required String idTrx,
    required String status,
  }) {
    return Column(
      children: [
        _row("Metode Transaksi", metode),
        _row("Tanggal", tanggal),
        _row("Waktu", waktu),
        _row("Biaya Transfer", _rupiah(biaya)),
        _row("Total Jumlah", _rupiah(total)),
        _row("ID Transaksi", idTrx),
        _row("Status", status),
      ],
    );
  }

  // ===== TRANSFER BODY =====
  Widget _transferBody({
    required String title,
    required String tanggal,
    required String waktu,
    required String metode,
    required num biaya,
    required num total,
    required String idTrx,
    required String status,
    required String dari,
    required String ke,
  }) {
    return Column(
      children: [
        _row("Transaksi", title),
        _row("Tanggal", tanggal),
        _row("Waktu", waktu),
        _row("Metode", metode),
        _row("Biaya Transfer", _rupiah(biaya)),
        _row("Total Jumlah", _rupiah(total)),
        _row("ID Transaksi", idTrx),
        _row("Status", status),
        const Divider(color: Colors.white24),
        _row("Dari", dari),
        _row("Ke", ke),
      ],
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Bukti Pembayaran",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ ROW FIX: kiri nempel kiri, kanan nempel kanan (seperti UI contoh)
  Widget _row(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              left,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              right,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Helpers =====
  static num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  static DateTime _toDateTime(dynamic v) {
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  static num _extractAmount(dynamic amountStr) {
    if (amountStr == null) return 0;
    final raw = amountStr.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return num.tryParse(raw) ?? 0;
  }

  static String _rupiah(num value) {
    final s = value.toStringAsFixed(0);
    final formatted = s.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp. $formatted';
  }

  // ===== ID helper (TIDAK menghapus huruf) =====
  static String _shortId(dynamic raw, {int take = 8}) {
    if (raw == null) return '#-';

    final s = raw.toString().trim();
    if (s.isEmpty || s == '-') return '#-';

    final core = s.length > take ? s.substring(s.length - take) : s;
    return '#$core';
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';
import 'package:artos/model/transaksi.dart';
import 'package:artos/model/topup.dart';

class BuktiPembayaranPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const BuktiPembayaranPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Ambil model dari item history
    final dynamic model = data['model'];

    final bool isTopup = model is Topup;
    final bool isTransfer = model is Transaksi;

    // fallback aman kalau ternyata model tidak ada
    if (!isTopup && !isTransfer) {
      return _errorPage(
        context,
        "Data receipt tidak valid (model tidak ditemukan).",
      );
    }

    // ====== Ambil data dari model ======
    final String title = (data['title'] ?? (isTopup ? 'Top Up' : 'Transfer'))
        .toString();

    // Metode & status dari model (bukan map)
    final String metode = isTopup
        ? (model as Topup).detailMetode
        : (model as Transaksi).metodeTransaksi;

    final String status = isTopup
        ? (model as Topup).status
        : (model as Transaksi).status;

    // Jumlah / biaya / total
    final num jumlah = isTopup
        ? (model as Topup).jumlah
        : (model as Transaksi).totalTransaksi;
    final num biaya = isTopup ? 0 : (model as Transaksi).biayaTransfer;
    final num total = isTopup ? jumlah : (jumlah + biaya);

    // Waktu
    final DateTime dt =
        (isTopup
                ? (model as Topup).waktuTopup
                : (model as Transaksi).waktuDibuat)
            .toLocal();

    final String tanggalStr =
        '${dt.day.toString().padLeft(2, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.year}';

    final String waktuStr =
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';

    // ID asli dari model, lalu dipendekin TANPA buang huruf (ambil tail saja)
    final String rawId = isTopup
        ? ((model as Topup).idTopUp ?? (model as Topup).orderId ?? '-')
        : ((model as Transaksi).idTransaksi ?? '-');

    final String idTrx = _shortId(rawId, take: 8);

    // Dari / Ke / Deskripsi (hanya untuk transfer)
    String dari = data['dari']?.toString() ?? '-';
    String ke = data['ke']?.toString() ?? '-';
    String deskripsi = data['deskripsi']?.toString() ?? '-';

    // Header judul
    final String headerTitle = isTopup ? 'TopUp' : 'Transaksi';

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
                          child: const Center(
                            child: Icon(
                              Icons.check_rounded,
                              size: 42,
                              color: Color(0xFF2ECC71), // hijau
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          "$headerTitle",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // kalau mau “selalu berhasil” di UI, ganti status tampilan jadi "Berhasil"
                        // tapi tetap simpan status asli di baris Status
                        const Text(
                          "Bukti Pembayaran",
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
                            deskripsi: deskripsi,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
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
        _row("Metode Transaksi", metode.isEmpty ? '-' : metode),
        _row("Tanggal", tanggal),
        _row("Waktu", waktu),
        _row("Biaya Transfer", _rupiah(biaya)),
        _row("Total Jumlah", _rupiah(total)),
        _row("ID Transaksi", idTrx),
        _row("Status", status.isEmpty ? '-' : status),
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
    required String deskripsi,
  }) {
    return Column(
      children: [
        _row("Transaksi", title.isEmpty ? '-' : title),
        _row("Tanggal", tanggal),
        _row("Waktu", waktu),
        _row("Metode", metode.isEmpty ? '-' : metode),
        _row("Biaya Transfer", _rupiah(biaya)),
        _row("Total Jumlah", _rupiah(total)),
        _row("ID Transaksi", idTrx),
        _row("Status", status.isEmpty ? '-' : status),
        const Divider(color: Colors.white24),
        _row("Dari", dari),
        _row("Ke", ke.isEmpty ? '-' : ke),
        _row("Deskripsi", deskripsi.isEmpty ? '-' : deskripsi),
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
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Bukti Pembayaran",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // kiri nempel kiri, kanan nempel kanan
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
  static String _rupiah(num value) {
    final s = value.toStringAsFixed(0);
    final formatted = s.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp. $formatted';
  }

  // ambil tail N char, tidak menghapus huruf, hanya memendekkan tampilan
  static String _shortId(dynamic raw, {int take = 8}) {
    final s = (raw ?? '').toString().trim();
    if (s.isEmpty || s == '-') return '#-';
    final core = s.length > take ? s.substring(s.length - take) : s;
    return '#$core';
  }

  Widget _errorPage(BuildContext context, String msg) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBar(context),
      body: BackgroundApp(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(msg, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

import 'package:artos/model/transaksi.dart';

class QrisCtrl {
  bool _handling = false;
  bool get isHandling => _handling;

  /// Parse + validasi QRIS, return data siap dipakai UI konfirmasi.
  Map<String, dynamic> parse(String raw) {
    if (_handling) throw Exception('Sedang memproses QR');
    _handling = true;

    if (!raw.startsWith('000201')) {
      _handling = false;
      throw Exception('QR bukan QRIS');
    }

    final Map<String, String> tlv = {};
    int i = 0;

    while (i + 4 <= raw.length) {
      final tag = raw.substring(i, i + 2);
      final len = int.tryParse(raw.substring(i + 2, i + 4));
      if (len == null) break;

      final start = i + 4;
      final end = start + len;
      if (end > raw.length) break;

      tlv[tag] = raw.substring(start, end);
      i = end;
    }

    final merchant = tlv['59'];
    if (merchant == null || merchant.isEmpty) {
      _handling = false;
      throw Exception('Merchant tidak ditemukan');
    }

    final amountStr = tlv['54']; // dynamic QRIS
    final amount = amountStr != null ? double.tryParse(amountStr) : null;

    // Controller hanya mengembalikan data; UI yang nampilinnya
    return {
      'raw': raw,
      'tlv': tlv,
      'merchantName': merchant,
      'presetAmount': amount,     // null kalau static
      'isDynamic': amount != null,
    };
  }

  /// Bangun model Transaksi dari data QRIS + input user (kategori, amount).
  Transaksi buildTransaksiQris({
    required String idPengguna,
    required String idKategori,
    required String merchantName,
    required double amount,
    double biayaTransfer = 0.0,
    String status = 'SUCCESS',
  }) {
    if (amount <= 0) throw Exception('Nominal tidak valid');
    if (idKategori.isEmpty) throw Exception('Kategori wajib dipilih');

    return Transaksi(
      idPengguna: idPengguna,
      idKategori: idKategori,
      targetPengguna: '',
      targetMerchant: merchantName,
      totalTransaksi: amount,
      deskripsi: 'Pembayaran QRIS - $merchantName',
      metodeTransaksi: 'QRIS',
      status: status,
      biayaTransfer: biayaTransfer,
      waktuDibuat: DateTime.now(),
    );
  }

  /// Proses bayar QRIS: validasi saldo + insert transaksi + update saldo.
  /// dbInsert/dbUpdateSaldo kamu kirim dari db_service biar ctrl tidak coupling.
  Future<void> bayar({
    required double saldoSaatIni,
    required Transaksi transaksi,
    required Future<void> Function(Transaksi trx) dbInsert,
    required Future<void> Function(double deltaSaldo) dbUpdateSaldo,
  }) async {
    if (transaksi.totalTransaksi <= 0) throw Exception('Nominal tidak valid');
    if (transaksi.totalTransaksi > saldoSaatIni) throw Exception('Saldo tidak cukup');

    await dbInsert(transaksi);
    await dbUpdateSaldo(-transaksi.totalTransaksi);
  }

  /// Dipanggil setelah selesai (sukses/gagal) agar bisa scan lagi.
  void release() {
    _handling = false;
  }
}

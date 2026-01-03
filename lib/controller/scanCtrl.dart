import 'package:artos/service/db_service.dart';
import 'package:artos/model/transaksi.dart';
import 'package:artos/model/pengguna.dart';

class ScanController {
  final supabase = DBService.client;

  /// Tahap 1: Identifikasi Jenis QR
  Map<String, dynamic> identifyAndParse(String raw) {
    if (raw.startsWith('000201')) {
      return {
        'type': 'QRIS',
        'data': _parseQRIS(raw),
      };
    } else if (raw.startsWith('artos:')) {
      final rekening = raw.replaceAll('artos:', '');
      return {
        'type': 'INTERNAL_TRANSFER',
        'data': {'rekening': rekening},
      };
    }
    return {'type': 'UNKNOWN', 'data': raw};
  }

  /// Tahap 2: Membedah data TLV QRIS
  Map<String, dynamic> _parseQRIS(String raw) {
    final Map<String, String> tlv = {};
    int i = 0;
    while (i + 4 <= raw.length) {
      final tag = raw.substring(i, i + 2);
      final len = int.tryParse(raw.substring(i + 2, i + 4)) ?? 0;
      final start = i + 4;
      final end = start + len;
      if (end > raw.length) break;
      tlv[tag] = raw.substring(start, end);
      i = end;
    }

    return {
      'merchantName': tlv['59'] ?? 'Merchant Unknown',
      'amount': tlv['54'] != null ? double.tryParse(tlv['54']!) : null,
      'isDynamic': tlv['54'] != null,
    };
  }

  /// Proses Pembayaran
  Future<void> prosesPembayaran({
    required String uid,
    required String idKategori,
    required String merchantName,
    required double amount,
  }) async {
    final saldo = await Pengguna.getSaldo(uid) ?? 0;
    if (amount > saldo) throw Exception('Saldo tidak cukup');

    // Simpan transaksi via Model
    final transaksi = Transaksi(
      idPengguna: uid,
      idKategori: idKategori,
      targetMerchant: merchantName,
      totalTransaksi: amount,
      deskripsi: 'Pembayaran QRIS ke $merchantName',
      metodeTransaksi: 'QRIS',
      status: 'SUCCESS',
      biayaTransfer: 0,
      waktuDibuat: DateTime.now(),
    );

    await Transaksi.insert(transaksi);

    // Update saldo user via Model
    await Pengguna.decreaseSaldoSafe(uid, amount);
  }
}

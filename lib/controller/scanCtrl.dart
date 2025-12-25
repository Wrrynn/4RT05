import 'package:artos/service/db_service.dart';

class ScanController {
  final supabase = DBService.client;

  /// Tahap 1: Identifikasi Jenis QR
  Map<String, dynamic> identifyAndParse(String raw) {
    // Cek jika format QRIS (Standar Indonesia)
    if (raw.startsWith('000201')) {
      return {
        'type': 'QRIS',
        'data': _parseQRIS(raw),
      };
    } 
    
    // Cek jika format Internal Artos (Contoh: artos:rekening)
    else if (raw.startsWith('artos:')) {
      final rekening = raw.replaceAll('artos:', '');
      return {
        'type': 'INTERNAL_TRANSFER',
        'data': {'rekening': rekening},
      };
    } 
    
    // Format tidak dikenali
    return {'type': 'UNKNOWN', 'data': raw};
  }

  /// Tahap 2: Membedah data TLV pada QRIS
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

  Future<void> prosesPembayaran({
    required String uid,
    required String idKategori,
    required String merchantName,
    required double amount,
    required double saldoSaatIni,
  }) async {
    // Validasi saldo
    if (amount > saldoSaatIni) throw Exception('Saldo tidak cukup');

    // 1. Simpan Transaksi ke Database
    await supabase.from('Transaksi').insert({
      'id_pengguna': uid,
      'id_kategori': idKategori,
      'target_merchant': merchantName,
      'total_transaksi': amount,
      'metode_transaksi': 'QRIS',
      'status': 'SUCCESS',
      'waktu_dibuat': DateTime.now().toIso8601String(),
    });

    // 2. Update Saldo Pengguna
    await supabase.from('Pengguna')
        .update({'saldo': saldoSaatIni - amount})
        .eq('id_pengguna', uid);
  }
}
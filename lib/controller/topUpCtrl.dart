import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:artos/service/db_service.dart';
import 'package:artos/model/topup.dart';
import 'package:artos/model/pengguna.dart';

class TopupController {
  final supabase = DBService.client;

  /// Proses topup
  Future<String?> topUp({
    required Pengguna pengguna,
    required double jumlah,
    required String metode,
  }) async {
    try {
      // 1️⃣ Insert ke tabel Topup
      final insertResponse = await supabase.from('Top Up').insert({
        'id_pengguna_topup': pengguna.idPengguna,
        'jumlah': jumlah,
        'metode': metode,
        'status': 'pending',
      }).select();

      if (insertResponse.isEmpty) {
        return "Gagal membuat transaksi Topup.";
      }

      final topupData = insertResponse.first;
      Topup topup = Topup.fromMap(topupData);

      // Update saldo pengguna
      double newSaldo = pengguna.saldo + jumlah;

      final updateResponse = await supabase
          .from('Pengguna')
          .update({'saldo': newSaldo})
          .eq('id_pengguna', pengguna.idPengguna)
          .select();

      if (updateResponse.isEmpty) {
        return "Gagal menambahkan saldo pengguna.";
      }

      // Update juga di model lokal
      pengguna.saldo = newSaldo;

      return null; // sukses
    } on PostgrestException catch (e) {
      return "Database error: ${e.message}";
    } catch (e) {
      return "Kesalahan tak terduga: $e";
    }
  }
}

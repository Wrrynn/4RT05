import 'package:artos/service/db_service.dart';
import 'package:artos/model/laporan_keuangan.dart';

class LaporanKeuanganController {
  final _db = DBService.client;

  Future<Map<String, dynamic>> getMonthlyReportData(
    String userId,
    DateTime month,
  ) async {
    try {
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      double totalIncome = 0;
      double totalExpense = 0;

      final Map<String, double> incomeCategory = {};
      final Map<String, double> expenseCategory = {};

      /* ================== TOP UP (PEMASUKAN) ================== */
      final topups = await _db
          .from('Top Up')
          .select('jumlah')
          .eq('id_pengguna_topup', userId)
          .gte('waktu_dibuat', start.toIso8601String())
          .lte('waktu_dibuat', end.toIso8601String());

      for (final t in topups) {
        final amount = (t['jumlah'] as num).toDouble();
        totalIncome += amount;
        incomeCategory['Top Up'] = (incomeCategory['Top Up'] ?? 0) + amount;
      }

      /* ================== TRANSAKSI ================== */
      final transactions = await _db
          .from('Transaksi')
          .select(
            'id_pengguna, target_pengguna, total_transaksi, metode_transaksi, id_kategori, Kategori(nama_kategori)',
          )
          .or('id_pengguna.eq.$userId,target_pengguna.eq.$userId')
          .gte('waktu_dibuat', start.toIso8601String())
          .lte('waktu_dibuat', end.toIso8601String());

      for (final trx in transactions) {
        final amount = (trx['total_transaksi'] as num).toDouble();
        final kategori = trx['Kategori']?['nama_kategori']?.toString() ?? 'Lainnya';

        // Pengeluaran (user sebagai pengirim)
        if (trx['id_pengguna'] == userId) {
          totalExpense += amount;
          expenseCategory[kategori] = (expenseCategory[kategori] ?? 0) + amount;
        }

        // Pemasukan (transfer masuk)
        if (trx['target_pengguna'] == userId) {
          totalIncome += amount;
          incomeCategory['Transfer'] =
              (incomeCategory['Transfer'] ?? 0) + amount;
        }
      }

      /* ================== MODEL LAPORAN ================== */
      final laporan = ModelLaporan(
        idPengguna: userId,
        totalPemasukan: totalIncome,
        totalPengeluaran: totalExpense,
        totalKontribusi: totalIncome - totalExpense,
        totalKategori: 0,
      );

      /* ================== SIMPAN LAPORAN ================== */
      await _db.from('Laporan Keuangan').insert(laporan.toInsertJson());

      /* ================== RETURN KE UI ================== */
      return {
        'laporan': laporan,
        'pemasukan': totalIncome,
        'pengeluaran': totalExpense,
        'income_categories': incomeCategory,
        'expense_categories': expenseCategory,
      };
    } catch (e) {
      throw Exception('Gagal memuat laporan keuangan: $e');
    }
  }
}
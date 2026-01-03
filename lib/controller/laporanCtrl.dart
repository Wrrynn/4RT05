import 'package:artos/model/laporan_keuangan.dart';
import 'package:artos/model/topup.dart';
import 'package:artos/model/transaksi.dart';  
class LaporanKeuanganController {
  Future<Map<String, dynamic>> getMonthlyReportData(
    String userId,
    DateTime month,
  ) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    double totalIncome = 0;
    double totalExpense = 0;

    final Map<String, double> incomeCategory = {};
    final Map<String, double> expenseCategory = {};

    /* ========== PEMASUKAN (TOP UP) ========== */
    final topupIncome =
        await Topup.findMonthlyTotalIncome(userId, start, end);

    totalIncome += topupIncome;
    if (topupIncome > 0) {
      incomeCategory['Top Up'] = topupIncome;
    }

    /* ========== TRANSAKSI ========== */
    final transaksiList =
        await Transaksi.findMonthlyTransaksiWithKategori(
      userId,
      start,
      end,
    );

    for (final trx in transaksiList) {
      final amount = (trx['total_transaksi'] as num).toDouble();
      final kategori =
          trx['Kategori']?['nama_kategori']?.toString() ?? 'Lainnya';

      // Pengeluaran
      if (trx['id_pengguna'] == userId) {
        totalExpense += amount;
        expenseCategory[kategori] =
            (expenseCategory[kategori] ?? 0) + amount;
      }

      // Transfer masuk
      if (trx['target_pengguna'] == userId) {
        totalIncome += amount;
        incomeCategory['Transfer'] =
            (incomeCategory['Transfer'] ?? 0) + amount;
      }
    }

    /* ========== MODEL LAPORAN ========== */
    final laporan = ModelLaporan(
      idPengguna: userId,
      totalPemasukan: totalIncome,
      totalPengeluaran: totalExpense,
      totalKontribusi: totalIncome - totalExpense,
      totalKategori: 0,
    );

    await ModelLaporan.insert(laporan);

    return {
      'laporan': laporan,
      'pemasukan': totalIncome,
      'pengeluaran': totalExpense,
      'income_categories': incomeCategory,
      'expense_categories': expenseCategory,
    };
  }
}

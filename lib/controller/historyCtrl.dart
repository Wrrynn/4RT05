import 'package:artos/model/transaksi.dart';
import 'package:artos/model/pengguna.dart';
import 'package:artos/model/topup.dart';

class HistoryController {
  Future<List<Map<String, dynamic>>> getHistory(String uid) async {
    final List<Map<String, dynamic>> items = [];
    final Map<String, String> nameCache = {};

    final transaksiList = await Transaksi.findHistoryByUser(uid);
    final topupList = await Topup.findHistoryByUser(uid);

    for (final t in transaksiList) {
      final bool isReceiver = t.targetPengguna == uid;
      final dt = t.waktuDibuat;

      nameCache[t.idPengguna] ??= await Pengguna.resolveName(t.idPengguna);

      if (t.targetPengguna != null) {
        nameCache[t.targetPengguna!] ??= await Pengguna.resolveName(
          t.targetPengguna!,
        );
      }

      final sender = nameCache[t.idPengguna]!;
      final receiver = t.targetPengguna != null
          ? nameCache[t.targetPengguna!]!
          : '-';

      items.add({
        'type': 'transfer',
        'title': isReceiver
            ? 'Terima dari $sender'
            : t.targetMerchant ?? 'Kirim ke $receiver',
        'amount': isReceiver
            ? '+Rp ${t.totalTransaksi}'
            : '-Rp ${t.totalTransaksi}',
        'tanggal': dt,
        'model': t,
      });
    }

    for (final tp in topupList) {
      items.add({
        'type': 'topup',
        'title': 'Top Up',
        'amount': '+Rp ${tp.jumlah}',
        'tanggal': tp.waktuTopup,
        'model': tp,
      });
    }

    items.sort(
      (a, b) => (b['tanggal'] as DateTime).compareTo(a['tanggal'] as DateTime),
    );

    return items;
  }

  Future<Map<String, dynamic>> getMonthlyReportData(
    String uid,
    DateTime month,
  ) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    double totalOut = 0;

    final expenseRaw = await Transaksi.findMonthlyExpenseByCategory(
      uid,
      start,
      end,
    );

    // TOTAL PEMASUKAN
    final double totalIn = await Topup.findMonthlyTotalIncome(uid, start, end);

    final Map<String, double> expenseCat = {};
    final Map<String, double> incomeCat = {};

    // ===== PENGELUARAN =====
    for (final e in expenseRaw) {
      final val = (e['total_transaksi'] as num).toDouble();
      totalOut += val;

      final cat = e['Kategori']?['nama_kategori']?.toString() ?? 'Lainnya';

      expenseCat[cat] = (expenseCat[cat] ?? 0) + val;
    }

    // ===== PEMASUKAN =====
    // karena hanya total, kategorinya bisa satu default
    incomeCat['Top Up'] = totalIn;

    return {
      'pemasukan': totalIn,
      'pengeluaran': totalOut,
      'expense_categories': expenseCat,
      'income_categories': incomeCat,
    };
  }
}

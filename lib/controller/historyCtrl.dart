import 'package:artos/service/db_service.dart';
import 'package:artos/model/transaksi.dart';
import 'package:artos/model/topup.dart';

class HistoryController {
  final supabase = DBService.client;

  static const String tableTransaksi = 'Transaksi';
  static const String tableTopup = 'Top Up';
  static const String tablePengguna = 'Pengguna';

  // status topup yang dianggap "masuk riwayat"
  static const List<String> _topupSuccessStatuses = [
    'settlement',
    'success',
    'sukses',
    'sukSses',
  ];

  Future<List<Map<String, dynamic>>> getHistory(String uid) async {
    final List<Map<String, dynamic>> items = [];
    final Map<String, String> namaCache = {};

    // ========= 1) TRANSAKSI (KIRIM + TERIMA) =========
    try {
      final trxRes = await supabase
          .from(tableTransaksi)
          .select()
          .or('id_pengguna.eq.$uid,target_pengguna.eq.$uid')
          .order('waktu_dibuat', ascending: false);

      final transaksiList = (trxRes as List)
          .map((e) => Transaksi.fromMap(e as Map<String, dynamic>))
          .toList();

      for (final t in transaksiList) {
        final bool isReceiver = t.targetPengguna == uid;
        final DateTime dt = _safeDt(t.waktuDibuat);

        final senderName = await _resolveUserName(t.idPengguna, namaCache);
        final receiverName = t.targetPengguna != null
            ? await _resolveUserName(t.targetPengguna!, namaCache)
            : 'Penerima';

        String title;
        String keField;

        if (isReceiver) {
          // ===== TRANSAKSI MASUK =====
          title = 'Terima dari $senderName';
          keField = 'Anda';
        } else {
          // ===== TRANSAKSI KELUAR =====
          if ((t.targetMerchant ?? '').trim().isNotEmpty) {
            // MERCHANT
            title = t.targetMerchant!;
            keField = t.targetMerchant!;
          } else {
            // TRANSFER USER
            title = 'Kirim ke $receiverName';
            keField = receiverName;
          }
        }

        items.add({
          'type': 'transfer',
          'model': t,

          // ===== list =====
          'title': title,
          'subtitle': t.metodeTransaksi,
          'amount': isReceiver
              ? '+Rp. ${_formatRupiah(t.totalTransaksi)}'
              : '-Rp. ${_formatRupiah(t.totalTransaksi)}',
          'isIncome': isReceiver,

          // ===== receipt =====
          'metode': t.metodeTransaksi,
          'status': t.status,
          'id_transaksi': t.idTransaksi ?? '-',
          'tanggal': dt,
          'jumlah': t.totalTransaksi,
          'biaya': t.biayaTransfer,
          'total': t.totalTransaksi + t.biayaTransfer,
          'dari': isReceiver ? senderName : 'Anda',
          'ke': keField,
          'deskripsi': t.deskripsi ?? '-',

          '_ts': dt,
        });
      }
    } catch (e) {
      print('History transaksi error: $e');
    }

    // ========= 2) TOP UP =========
    try {
      final topRes = await supabase
          .from(tableTopup)
          .select()
          .eq('id_pengguna_topup', uid)
          .inFilter('status', _topupSuccessStatuses)
          .order('waktu_dibuat', ascending: false);

      final topupList = (topRes as List)
          .map((e) => Topup.fromMap(e as Map<String, dynamic>))
          .toList();

      for (final tp in topupList) {
        final st = tp.status.toLowerCase().trim();
        if (!_topupSuccessStatuses.contains(st)) continue;

        final dt = _safeDt(tp.waktuTopup);

        items.add({
          'type': 'topup',
          'model': tp,

          'title': 'Top Up',
          'subtitle': tp.detailMetode,
          'amount': '+Rp. ${_formatRupiah(tp.jumlah)}',
          'isIncome': true,

          'metode': tp.detailMetode,
          'status': tp.status,
          'id_transaksi': tp.idTopUp ?? (tp.orderId ?? '-'),
          'tanggal': dt,
          'jumlah': tp.jumlah,
          'biaya': 0.0,
          'total': tp.jumlah,
          'dari': 'Anda',
          'ke': 'Saldo',

          '_ts': dt,
        });
      }
    } catch (e) {
      print('History topup error: $e');
    }

    // ========= 3) SORT =========
    items.sort((a, b) {
      final ta = a['_ts'] as DateTime? ?? DateTime(1970);
      final tb = b['_ts'] as DateTime? ?? DateTime(1970);
      return tb.compareTo(ta);
    });

    for (final it in items) {
      it.remove('_ts');
    }

    return items;
  }

  Future<String> _resolveTransaksiTitle(
    Transaksi t,
    Map<String, String> namaCache,
  ) async {
    final merchant = (t.targetMerchant ?? '').trim();
    if (merchant.isNotEmpty) return merchant;

    final targetUid = (t.targetPengguna ?? '').trim();
    if (targetUid.isEmpty) return 'Transfer';

    if (namaCache.containsKey(targetUid)) return namaCache[targetUid]!;

    try {
      final res = await supabase
          .from(tablePengguna)
          .select('nama_lengkap')
          .eq('id_pengguna', targetUid)
          .maybeSingle();

      if (res == null) return 'Transfer';

      final nama = (res['nama_lengkap'] ?? '').toString().trim();
      if (nama.isEmpty) return 'Transfer';

      namaCache[targetUid] = nama;
      return nama;
    } catch (e) {
      print('Resolve nama error: $e');
      return 'Transfer';
    }
  }

  DateTime _safeDt(DateTime? dt) {
    if (dt == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (dt.year < 1971) return DateTime.fromMillisecondsSinceEpoch(0);
    return dt;
  }

  String _formatRupiah(double value) {
    final s = value.toStringAsFixed(0);
    return s.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Future<String> _resolveUserName(String uid, Map<String, String> cache) async {
    if (cache.containsKey(uid)) return cache[uid]!;

    final res = await supabase
        .from(tablePengguna)
        .select('nama_lengkap')
        .eq('id_pengguna', uid)
        .maybeSingle();

    final name = res?['nama_lengkap']?.toString() ?? 'Pengguna';
    cache[uid] = name;
    return name;
  }

  Future<Map<String, dynamic>> getMonthlyReportData(
    String uid,
    DateTime month,
  ) async {
    double totalIn = 0;
    double totalOut = 0;
    Map<String, double> expenseCatData = {};
    Map<String, double> incomeCatData = {};

    try {
      final start = DateTime(month.year, month.month, 1).toIso8601String();
      final end = DateTime(
        month.year,
        month.month + 1,
        0,
        23,
        59,
        59,
      ).toIso8601String();

      final trxRes = await supabase
          .from(tableTransaksi)
          .select('total_transaksi, Kategori(nama_kategori)')
          .eq('id_pengguna', uid)
          .gte('waktu_dibuat', start)
          .lte('waktu_dibuat', end);

      for (var t in (trxRes as List)) {
        double val = (t['total_transaksi'] is num)
            ? (t['total_transaksi'] as num).toDouble()
            : 0.0;
        totalOut += val;
        final catName =
            t['Kategori']?['nama_kategori']?.toString() ?? 'Lainnya';
        expenseCatData[catName] = (expenseCatData[catName] ?? 0) + val;
      }

      // pemasukan hanya sukses
      final topRes = await supabase
          .from(tableTopup)
          .select()
          .eq('id_pengguna_topup', uid)
          .inFilter('status', _topupSuccessStatuses)
          .gte('waktu_dibuat', start)
          .lte('waktu_dibuat', end);

      for (var tp in (topRes as List)) {
        final topupItem = Topup.fromMap(tp as Map<String, dynamic>);
        totalIn += topupItem.jumlah;
        final method = topupItem.detailMetode.isEmpty
            ? "Lainnya"
            : topupItem.detailMetode;
        incomeCatData[method] = (incomeCatData[method] ?? 0) + topupItem.jumlah;
      }
    } catch (e) {
      print('Error report: $e');
    }

    return {
      'pemasukan': totalIn,
      'pengeluaran': totalOut,
      'expense_categories': expenseCatData,
      'income_categories': incomeCatData,
    };
  }
}

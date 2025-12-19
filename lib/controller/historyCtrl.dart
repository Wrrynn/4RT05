import 'package:artos/service/db_service.dart';
import 'package:artos/model/transaksi.dart';
import 'package:artos/model/topup.dart';

class HistoryController {
  final supabase = DBService.client;

  static const String tableTransaksi = 'Transaksi';
  static const String tableTopup = 'Top Up';

  /// Return list item siap pakai di HistoryPage
  /// item keys:
  /// - type: 'transfer' | 'topup'
  /// - title
  /// - subtitle
  /// - amount
  /// - isIncome
  Future<List<Map<String, dynamic>>> getHistory(String uid) async {
    try {
      // 1) ambil transaksi
      final trxRes = await supabase
          .from(tableTransaksi)
          .select()
          .eq('id_pengguna', uid);

      final transaksiList = (trxRes as List)
          .map((e) => Transaksi.fromMap(e as Map<String, dynamic>))
          .toList();

      // 2) ambil top up
      final topRes = await supabase
          .from(tableTopup)
          .select()
          .eq('id_pengguna_topup', uid);

      final topupList = (topRes as List)
          .map((e) => Topup.fromMap(e as Map<String, dynamic>))
          .toList();

      // 3) gabungkan ke 1 list
      final List<Map<String, dynamic>> items = [];

      // ---- transaksi (transfer) ----
      for (final t in transaksiList) {
        final title =
            (t.deskripsi.trim().isEmpty) ? 'Transfer' : t.deskripsi.trim();

        items.add({
          'type': 'transfer',
          'title': title,
          'subtitle': '${t.metodeTransaksi} • ${t.status}',
          'amount': '-Rp. ${_formatRupiah(t.totalTransaksi)}',
          'isIncome': false,
          '_ts': t.waktuDibuat, // dipakai buat sorting
        });
      }

      // ---- top up ----
      for (final tp in topupList) {
        // waktu topup = ambil dari angka timestamp dalam order_id
        final DateTime ts = _parseTopupTime(tp.orderId);

        items.add({
          'type': 'topup',
          'title': 'Top Up',
          'subtitle': '${tp.detailMetode} • ${tp.status}',
          'amount': '+Rp. ${_formatRupiah(tp.jumlah)}',
          'isIncome': true,
          '_ts': ts, // dipakai buat sorting
        });
      }

      // 4) sort gabungan (TERBARU DI ATAS)
      items.sort((a, b) {
        final ta = a['_ts'] as DateTime;
        final tb = b['_ts'] as DateTime;
        return tb.compareTo(ta);
      });

      // 5) buang field internal
      for (final it in items) {
        it.remove('_ts');
      }

      return items;
    } catch (e) {
      return [];
    }
  }

  // ================= helpers =================

  /// Parser aman untuk order_id yang mengandung angka timestamp
  /// contoh normal: ARTOS-1734567890123
  DateTime _parseTopupTime(String? orderId) {
    if (orderId == null || orderId.trim().isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    // cari semua angka yang ada di string, ambil yang paling panjang
    final matches = RegExp(r'\d+')
        .allMatches(orderId)
        .map((m) => m.group(0)!)
        .toList();

    if (matches.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);

    matches.sort((a, b) => b.length.compareTo(a.length));
    final raw = matches.first;

    final n = int.tryParse(raw);
    if (n == null) return DateTime.fromMillisecondsSinceEpoch(0);

    // kalau ternyata detik (10 digit), ubah ke ms
    if (n < 1000000000000) {
      return DateTime.fromMillisecondsSinceEpoch(n * 1000);
    }

    return DateTime.fromMillisecondsSinceEpoch(n);
  }

  String _formatRupiah(double value) {
    // format sederhana tanpa dependency intl
    final s = value.toStringAsFixed(0);
    return s.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.');
  }
}

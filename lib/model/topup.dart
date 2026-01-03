import 'package:artos/service/db_service.dart';

class Topup {
  final String? idTopUp;
  final String idPenggunaTopup;
  final double jumlah;
  final String metode;
  final String detailMetode;
  final String? orderId;
  final String? redirectUrl;
  final DateTime waktuTopup;
  String status;

  Topup({
    this.idTopUp,
    required this.idPenggunaTopup,
    required this.jumlah,
    required this.metode,
    required this.detailMetode,
    this.orderId,
    this.redirectUrl,
    required this.status,
    DateTime? waktuTopup,
  }) : waktuTopup = waktuTopup ?? DateTime.now();

  factory Topup.fromMap(Map<String, dynamic> map) {
    return Topup(
      idTopUp: map['id_topup']?.toString(),
      idPenggunaTopup: map['id_pengguna_topup'],
      jumlah: (map['jumlah'] as num).toDouble(),
      metode: map['metode'],
      detailMetode: map['detail_metode'],
      orderId: map['order_id'],
      redirectUrl: map['payment_code'],
      status: map['status'],
      waktuTopup:
          DateTime.tryParse(map['waktu_dibuat'] ?? '') ?? DateTime.now(),
    );
  }

  /* =======================
     DATABASE (MODEL ONLY)
     ======================= */

  static final _supabase = DBService.client;

  static Future<Topup> insert(Topup topup) async {
    final res = await _supabase
        .from('Top Up')
        .insert({
          'id_pengguna_topup': topup.idPenggunaTopup,
          'jumlah': topup.jumlah,
          'metode': topup.metode,
          'detail_metode': topup.detailMetode,
          'order_id': topup.orderId,
          'status': topup.status,
          'payment_code': topup.redirectUrl,
        })
        .select()
        .single();

    return Topup.fromMap(res);
  }

  static Future<Topup?> findByOrderId(String orderId) async {
    final res = await _supabase
        .from('Top Up')
        .select()
        .eq('order_id', orderId)
        .maybeSingle();

    return res == null ? null : Topup.fromMap(res);
  }

  static Future<void> updateStatus(String orderId, String status) async {
    await _supabase
        .from('Top Up')
        .update({'status': status})
        .eq('order_id', orderId);
  }

  static Future<void> updateDetailMetode(String orderId, String detail) async {
    await _supabase
        .from('Top Up')
        .update({'detail_metode': detail})
        .eq('order_id', orderId);
  }

  static const List<String> successStatuses = [
    'settlement',
    'success',
    'sukses',
    'sukSses',
  ];

  static Future<List<Topup>> findHistoryByUser(String uid) async {
    final res = await _supabase
        .from('Top Up')
        .select()
        .eq('id_pengguna_topup', uid)
        .inFilter('status', successStatuses)
        .order('waktu_dibuat', ascending: false);

    return (res as List).map((e) => Topup.fromMap(e)).toList();
  }

  static Future<double> findMonthlyTotalIncome(
  String userId,
  DateTime start,
  DateTime end,
) async {
  final res = await _supabase
      .from('Top Up')
      .select('jumlah')
      .eq('id_pengguna_topup', userId)
      .inFilter('status', successStatuses)
      .gte('waktu_dibuat', start.toIso8601String())
      .lte('waktu_dibuat', end.toIso8601String());

  double total = 0;
  for (final r in res) {
    total += (r['jumlah'] as num).toDouble();
  }
  return total;
}
}

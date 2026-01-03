import 'package:artos/service/db_service.dart';

class Transaksi {
  final String? idTransaksi;
  final String idPengguna;
  final String idKategori;
  final String? targetPengguna;
  final String? targetMerchant;
  double totalTransaksi;
  String deskripsi;
  String metodeTransaksi;
  String status;
  double biayaTransfer;
  DateTime waktuDibuat;

  Transaksi({
    this.idTransaksi,
    required this.idPengguna,
    required this.idKategori,
    this.targetPengguna,
    this.targetMerchant,
    required this.totalTransaksi,
    required this.deskripsi,
    required this.metodeTransaksi,
    required this.status,
    required this.biayaTransfer,
    DateTime? waktuDibuat,
}) : waktuDibuat = waktuDibuat ?? DateTime.now();

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      idTransaksi: map['id_transaksi']?.toString(),
      idPengguna: map['id_pengguna'],
      idKategori: map['id_kategori'],
      targetPengguna: map['target_pengguna'],
      targetMerchant: map['target_merchant'],
      totalTransaksi: (map['total_transaksi'] as num).toDouble(),
      deskripsi: map['deskripsi'],
      metodeTransaksi: map['metode_transaksi'],
      status: map['status'],
      biayaTransfer: (map['biaya_transfer'] as num).toDouble(),
      waktuDibuat: DateTime.parse(map['waktu_dibuat']),
    );
  }

  static final _supabase = DBService.client;

  // ================= SELECT =================
  static Future<List<Transaksi>> findBulananByPengguna(
    String idPengguna,
    DateTime start,
    DateTime end,
  ) async {
    final res = await _supabase
        .from('Transaksi')
        .select('id_kategori, total_transaksi')
        .eq('id_pengguna', idPengguna)
        .gte('waktu_dibuat', start.toIso8601String())
        .lt('waktu_dibuat', end.toIso8601String());

    return (res as List).map((e) => Transaksi.fromMap(e)).toList();
  }

  // ================= INSERT =================
  static Future<void> insert(Transaksi transaksi) async {
    await _supabase.from('Transaksi').insert(transaksi.toMap());
  }

  Map<String, dynamic> toMap() => {
    'id_pengguna': idPengguna,
    'id_kategori': idKategori,
    'target_pengguna': targetPengguna,
    'target_merchant': targetMerchant,
    'total_transaksi': totalTransaksi,
    'deskripsi': deskripsi,
    'metode_transaksi': metodeTransaksi,
    'status': status,
    'biaya_transfer': biayaTransfer,
    'waktu_dibuat': waktuDibuat.toIso8601String(),
  };

  static Future<String?> insertAndReturnId(Transaksi transaksi) async {
    final res = await _supabase
        .from('Transaksi')
        .insert(transaksi.toMap())
        .select('id_transaksi')
        .maybeSingle();

    return res?['id_transaksi'];
  }

  static Future<List<Transaksi>> findHistoryByUser(String uid) async {
    final res = await _supabase
        .from('Transaksi')
        .select()
        .or('id_pengguna.eq.$uid,target_pengguna.eq.$uid')
        .order('waktu_dibuat', ascending: false);

    return (res as List).map((e) => Transaksi.fromMap(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> findMonthlyExpenseByCategory(
    String uid,
    DateTime start,
    DateTime end,
  ) async {
    final res = await _supabase
        .from('Transaksi')
        .select('total_transaksi, Kategori(nama_kategori)')
        .eq('id_pengguna', uid)
        .gte('waktu_dibuat', start.toIso8601String())
        .lte('waktu_dibuat', end.toIso8601String());

    return (res as List).cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> findMonthlyReportRaw(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final res = await _supabase
        .from('Transaksi')
        .select(
          'id_pengguna, target_pengguna, total_transaksi, Kategori(nama_kategori)',
        )
        .or('id_pengguna.eq.$userId,target_pengguna.eq.$userId')
        .gte('waktu_dibuat', start.toIso8601String())
        .lte('waktu_dibuat', end.toIso8601String());

    return (res as List).cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> findMonthlyTransaksiWithKategori(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final res = await _supabase
        .from('Transaksi')
        .select(
          'id_pengguna, target_pengguna, total_transaksi, Kategori(nama_kategori)',
        )
        .or('id_pengguna.eq.$userId,target_pengguna.eq.$userId')
        .gte('waktu_dibuat', start.toIso8601String())
        .lte('waktu_dibuat', end.toIso8601String());

    return (res as List).cast<Map<String, dynamic>>();
  }
}

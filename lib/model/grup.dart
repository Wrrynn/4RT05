import 'package:artos/service/db_service.dart';

class Grup {
  final String idGrup;
  String namaGrup;
  double target;
  String durasi;
  double totalSaldo;
  final DateTime dibuatPada;
  final String dibuatOleh;

  Grup({
    required this.idGrup,
    required this.namaGrup,
    required this.target,
    required this.durasi,
    this.totalSaldo = 0,
    DateTime? dibuatPada,
    required this.dibuatOleh,
  }) : dibuatPada = dibuatPada ?? DateTime.now();

  // ==========================================
  // DATABASE METHODS (Static)
  // ==========================================
  static final _db = DBService.client;

  // Insert Grup Baru
  static Future<Grup> insert(Grup grup) async {
    final res = await _db
        .from('Grup')
        .insert({
          'nama_grup': grup.namaGrup,
          'target': grup.target,
          'durasi': grup.durasi,
          'total_saldo': grup.totalSaldo,
          'dibuat_oleh': grup.dibuatOleh,
        })
        .select()
        .single();
    return Grup.fromJson(res);
  }

  // Find Grup by ID
  static Future<Grup?> findById(String id) async {
    final res = await _db
        .from('Grup')
        .select()
        .eq('id_grup', id)
        .maybeSingle();
    return res != null ? Grup.fromJson(res) : null;
  }

  // Update Settings
  static Future<void> updateSettings(String id, Map<String, dynamic> data) async {
    await _db.from('Grup').update(data).eq('id_grup', id);
  }

  // Update Saldo Grup (Tambah/Kurang)
  static Future<void> updateSaldo(String id, double amount) async {
    // Note: Supabase tidak punya atomic increment simple via Dart SDK tanpa RPC,
    // jadi kita fetch dulu atau asumsikan logic di handle controller/model wrapper.
    // Untuk MVC murni sisi client, kita ambil current, lalu update.
    final current = await findById(id);
    if (current == null) throw Exception("Grup tidak ditemukan");
    
    await _db.from('Grup').update({
      'total_saldo': current.totalSaldo + amount
    }).eq('id_grup', id);
  }

  // Delete Grup
  static Future<void> delete(String id) async {
    await _db.from('Grup').delete().eq('id_grup', id);
  }

  // ==========================================
  // JSON CONVERTERS
  // ==========================================
  factory Grup.fromJson(Map<String, dynamic> json) {
    return Grup(
      idGrup: json['id_grup'] as String,
      namaGrup: json['nama_grup'] as String,
      target: (json['target'] as num).toDouble(),
      durasi: (json['durasi'] ?? '') as String,
      totalSaldo: (json['total_saldo'] as num?)?.toDouble() ?? 0.0,
      dibuatPada: json['dibuat_pada'] != null
          ? DateTime.parse(json['dibuat_pada'])
          : DateTime.now(),
      dibuatOleh: (json['dibuat_oleh'] ?? '') as String,
    );
  }
}
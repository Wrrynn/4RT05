import 'package:artos/service/db_service.dart';

class Kategori {
  final String idKategori;
  final String idPengguna;
  String namaKategori;
  String tipeKategori;
  double batasPengeluaran;
  double totalPengeluaran;

  Kategori({
    required this.idKategori,
    required this.idPengguna,
    required this.namaKategori,
    required this.tipeKategori,
    required this.batasPengeluaran,
    this.totalPengeluaran = 0,
  });

  factory Kategori.fromMap(Map<String, dynamic> map) {
    return Kategori(
      idKategori: map['id_kategori'],
      idPengguna: map['id_pengguna'],
      namaKategori: map['nama_kategori'],
      tipeKategori: map['tipe_kategori'],
      batasPengeluaran: (map['batas_pengeluaran'] as num).toDouble(),
      totalPengeluaran: (map['total_pengeluaran'] as num).toDouble(),
    );
  }

  static final _supabase = DBService.client;

  // ================= SELECT =================
  static Future<List<Kategori>> findByPengguna(String idPengguna) async {
    final res = await _supabase
        .from('Kategori')
        .select()
        .eq('id_pengguna', idPengguna);

    return (res as List)
        .map((e) => Kategori.fromMap(e))
        .toList();
  }

  // ================= UPDATE =================
  static Future<void> updateTotalPengeluaran(
    String idKategori,
    double total,
  ) async {
    await _supabase
        .from('Kategori')
        .update({'total_pengeluaran': total})
        .eq('id_kategori', idKategori);
  }

  static Future<void> updateTarget(
    String idKategori,
    double target,
  ) async {
    await _supabase
        .from('Kategori')
        .update({'batas_pengeluaran': target})
        .eq('id_kategori', idKategori);
  }

  // ================= CREATE =================
  static Future<Kategori> create({
    required String idPengguna,
    required String namaKategori,
    required String tipeKategori,
    double batasPengeluaran = 0,
  }) async {
    final res = await _supabase.from('Kategori').insert({
      'id_pengguna': idPengguna,
      'nama_kategori': namaKategori,
      'tipe_kategori': tipeKategori,
      'batas_pengeluaran': batasPengeluaran,
      'total_pengeluaran': 0,
    }).select().single();

    return Kategori.fromMap(res);
  }

  // ================= DELETE =================
  static Future<void> delete(String idKategori) async {
    await _supabase.from('Kategori').delete().eq(
          'id_kategori',
          idKategori,
        );
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/kategori.dart';
import '../model/transaksi.dart';

class KategoriController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ===================== MAIN =====================
  Future<List<Kategori>> getKategoriAnggaranDanSync(
    String userId,
  ) async {
    // 1. Ambil kategori
    final kategoriRes = await _supabase
        .from('Kategori')
        .select()
        .eq('id_pengguna', userId);

    // 2. Ambil transaksi untuk bulan berjalan (agar total_pengeluaran reset tiap bulan)
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfNextMonth = DateTime(now.year, now.month + 1, 1);

    final transaksiRes = await _supabase
      .from('Transaksi')
      .select('id_kategori, total_transaksi, waktu_dibuat')
      .eq('id_pengguna', userId)
      .gte('waktu_dibuat', startOfMonth.toIso8601String())
      .lt('waktu_dibuat', startOfNextMonth.toIso8601String());

    final List kategoriListMap = kategoriRes as List;
    final List transaksiListMap = transaksiRes as List;

    // Map ke model
    final List<Kategori> kategoriList = kategoriListMap
        .map((m) => Kategori.fromMap(m as Map<String, dynamic>))
        .toList();

    final List<Transaksi> transaksiList = transaksiListMap
        .map((m) => Transaksi.fromMap(m as Map<String, dynamic>))
        .toList();

    // 3. Hitung total per kategori
    final Map<String, double> totalMap = {};

    for (final t in transaksiList) {
      final idKat = t.idKategori;
      if (idKat.isEmpty) continue;

      totalMap[idKat] = (totalMap[idKat] ?? 0) + t.totalTransaksi;
    }

    // 4. Update DB (OVERWRITE, bukan tambah) - gunakan nama tabel konsisten 'Kategori'
    for (final k in kategoriList) {
      final total = totalMap[k.idKategori] ?? 0;

      await _supabase
          .from('Kategori')
          .update({'total_pengeluaran': total})
          .eq('id_kategori', k.idKategori);

      // update object lokal agar nilai yang dikembalikan sinkron
      k.totalPengeluaran = total;
    }

    // 5. Return untuk UI
    return kategoriList;
  }

  // ===================== UPDATE TARGET =====================
  Future<void> updateTargetKategori({
    required String idKategori,
    required int targetBaru,
  }) async {
    await _supabase
        .from('Kategori')
        .update({'batas_pengeluaran': targetBaru})
        .eq('id_kategori', idKategori);
  }

  // ===================== CREATE =====================
  Future<Kategori> tambahKategori({
    required String idPengguna,
    required String namaKategori,
    required String tipeKategori,
    double batasPengeluaran = 0,
  }) async {
    final data = {
      'id_pengguna': idPengguna,
      'nama_kategori': namaKategori,
      'tipe_kategori': tipeKategori,
      'batas_pengeluaran': batasPengeluaran,
      'total_pengeluaran': 0,
    };

    final res = await _supabase.from('Kategori').insert(data).select().single();

    return Kategori.fromMap(res);
  }

  // ===================== EDIT =====================
  Future<void> editKategori(Kategori kategori) async {
    await _supabase
        .from('Kategori')
        .update({
          'nama_kategori': kategori.namaKategori,
          'batas_pengeluaran': kategori.batasPengeluaran,
        })
        .eq('id_kategori', kategori.idKategori);
  }

  // ===================== DELETE =====================
  Future<void> hapusKategori(Kategori kategori) async {
    if (kategori.namaKategori == 'Lainnya') {
      throw Exception('Kategori "Lainnya" tidak dapat dihapus');
    }

    await _supabase.from('Kategori').delete().eq('id_kategori', kategori.idKategori);
  }
}

import '../model/kategori.dart';
import '../model/transaksi.dart';

class KategoriController {
  /// Logic bisnis sinkronisasi kategori + transaksi
  Future<List<Kategori>> syncKategoriBulanan(String userId) async {
    final kategoriList = await Kategori.findByPengguna(userId);

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);

    final transaksiList =
        await Transaksi.findBulananByPengguna(userId, start, end);

    final Map<String, double> totalMap = {};

    for (final t in transaksiList) {
      totalMap[t.idKategori] =
          (totalMap[t.idKategori] ?? 0) + t.totalTransaksi;
    }

    for (final k in kategoriList) {
      final total = totalMap[k.idKategori] ?? 0;
      await Kategori.updateTotalPengeluaran(k.idKategori, total);
      k.totalPengeluaran = total;
    }

    return kategoriList;
  }

  Future<void> updateTargetKategori(
    String idKategori,
    double targetBaru,
  ) {
    return Kategori.updateTarget(idKategori, targetBaru);
  }

  Future<Kategori> tambahKategori({
    required String idPengguna,
    required String namaKategori,
    required String tipeKategori,
    double batasPengeluaran = 0,
  }) {
    return Kategori.create(
      idPengguna: idPengguna,
      namaKategori: namaKategori,
      tipeKategori: tipeKategori,
      batasPengeluaran: batasPengeluaran,
    );
  }

  Future<void> hapusKategori(Kategori kategori) {
    if (kategori.namaKategori == 'Lainnya') {
      throw Exception('Kategori "Lainnya" tidak dapat dihapus');
    }
    return Kategori.delete(kategori.idKategori);
  }
}

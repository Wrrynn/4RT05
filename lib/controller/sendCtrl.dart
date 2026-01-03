import 'package:artos/model/pengguna.dart';
import 'package:artos/model/kategori.dart';
import 'package:artos/model/transaksi.dart';

class SendController {
  /// Dropdown kategori
  Future<List<Kategori>> getKategoriDropdown(String idPengguna) async {
    return await Kategori.findByPengguna(idPengguna);
  }

  /// Cari pengguna
  Future<List<Pengguna>> searchPengguna(String query) async {
    return await Pengguna.search(query);
  }

  /// Kirim uang
  Future<void> kirimUang({
    required String pengirimId,
    required String penerimaRekening,
    required String kategoriId,
    required double nominal,
    required String metodeTransaksi,
    required String deskripsi,
    double biayaTransfer = 0,
  }) async {
    if (nominal <= 0) {
      throw Exception('Nominal harus lebih besar dari 0');
    }

    final penerima = await Pengguna.findByRekening(penerimaRekening);
    if (penerima == null) {
      throw Exception('Rekening penerima tidak valid');
    }

    if (penerima.idPengguna == pengirimId) {
      throw Exception('Tidak bisa transfer ke diri sendiri');
    }

    final pengirim = await Pengguna.findById(pengirimId);
    if (pengirim == null) {
      throw Exception('Pengirim tidak valid');
    }

    final totalPotong = nominal + biayaTransfer;
    if (pengirim.saldo < totalPotong) {
      throw Exception('Saldo tidak cukup');
    }

    final transaksi = Transaksi(
      idPengguna: pengirimId,
      idKategori: kategoriId,
      targetPengguna: penerima.idPengguna,
      targetMerchant: null,
      totalTransaksi: nominal,
      deskripsi: deskripsi,
      metodeTransaksi: metodeTransaksi,
      status: 'sukses',
      biayaTransfer: biayaTransfer,
      waktuDibuat: DateTime.now(),
    );

    await Transaksi.insert(transaksi);
    await Pengguna.decreaseSaldo(pengirimId, totalPotong);
    await Pengguna.increaseSaldo(penerima.idPengguna, nominal);
  }
}

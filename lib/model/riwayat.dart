import 'transaksi.dart'; // pastikan file Transaksi.dart sudah ada di folder yang sama

class Riwayat {
  // Atribut privat (UUIDs as strings)
  final String _idRiwayat;
  final String _idPengguna;
  final String _idTransaksi;
  String _idTopUp;

  // Constructor
  Riwayat({
    required String idRiwayat,
    required String idPengguna,
    required String idTransaksi,
    required String idTopUp,
  })  : _idRiwayat = idRiwayat,
        _idPengguna = idPengguna,
        _idTransaksi = idTransaksi,
        _idTopUp = idTopUp;

  // Getter dan Setter
  String get idRiwayat => _idRiwayat;

  String get idPengguna => _idPengguna;

  String get idTransaksi => _idTransaksi;

  String get idTopUp => _idTopUp;
  set idTopUp(String value) => _idTopUp = value;
}
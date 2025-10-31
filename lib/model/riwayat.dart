import 'transaksi.dart'; // pastikan file Transaksi.dart sudah ada di folder yang sama

class Riwayat {
  // Atribut privat
  final int _idRiwayat;
  final int _idPengguna;
  final int _idTransaksi;
  int _idTopUp;

  // Constructor
  Riwayat({
    required int idRiwayat,
    required int idPengguna,
    required int idTransaksi,
    required int idTopUp,
  })  : _idRiwayat = idRiwayat,
        _idPengguna = idPengguna,
        _idTransaksi = idTransaksi,
        _idTopUp = idTopUp;

  // Getter dan Setter
  int get idRiwayat => _idRiwayat;

  int get idPengguna => _idPengguna;

  int get idTransaksi => _idTransaksi;

  int get idTopUp => _idTopUp;
  set idTopUp(int value) => _idTopUp = value;

  // Method
  List<Transaksi> tampilkanRiwayat() {
    // Contoh dummy data, bisa diganti dengan data dari database atau API
    List<Transaksi> riwayatTransaksi = [
      Transaksi(
        idTransaksi: 1,
        idPengguna: _idPengguna,
        idKategori: 2,
        totalTransaksi: 250000,
        deskripsi: "Pembayaran listrik",
        waktuDibuat: DateTime.now().subtract(Duration(days: 3)),
        metodeTransaksi: "Transfer Bank",
        status: "Selesai",
        biayaTransfer: 2500,
        targetTransaksi: "PLN",
      ),
      Transaksi(
        idTransaksi: 2,
        idPengguna: _idPengguna,
        idKategori: 3,
        totalTransaksi: 100000,
        deskripsi: "Top Up E-Wallet",
        waktuDibuat: DateTime.now().subtract(Duration(days: 1)),
        metodeTransaksi: "E-Wallet",
        status: "Selesai",
        biayaTransfer: 0,
        targetTransaksi: "GoPay",
      ),
    ];

    print(" Menampilkan riwayat transaksi untuk pengguna ID $_idPengguna...");
    return riwayatTransaksi;
  }
}

import 'laporan_keuangan.dart';

class RekomendasiPenghematan {
  final int _idPengguna;
  String _saran;
  LaporanKeuangan _laporan;

  // Constructor
  RekomendasiPenghematan({
    required int idPengguna,
    required LaporanKeuangan laporan,
  })  : _idPengguna = idPengguna,
        _laporan = laporan,
        _saran = "";

  // Getter dan Setter
  int get idPengguna => _idPengguna;

  String get saran => _saran;
  set saran(String value) => _saran = value;

  LaporanKeuangan get laporan => _laporan;
  set laporan(LaporanKeuangan value) => _laporan = value;

  // Method analisis (contoh sederhana)
  void analisisLaporan() {
    // Misalnya, jika pengeluaran lebih besar dari pemasukan
    if (_laporan.totalPengeluaran > _laporan.totalPemasukan) {
      _saran = "Pengeluaran melebihi pemasukan. Kurangi biaya tidak penting.";
    } else {
      _saran = "Keuangan stabil. Pertahankan pola pengeluaran saat ini.";
    }
  }

  String generateSaran() {
    if (_saran.isEmpty) {
      return "Belum ada analisis dilakukan.";
    }
    return "Saran Penghematan untuk ID $_idPengguna:\n$_saran";
  }
}
import 'laporan_keuangan.dart';

class RekomendasiPenghematan {
  final int _idPengguna;
  String _saran;
  LaporanKeuangan _laporan; // ✅ atribut laporan sesuai UML

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
  set saran(String value) => _saran = saran;

  LaporanKeuangan get laporan => _laporan;

  set saran(String value) => _saran = value;
  set laporan(LaporanKeuangan value) => _laporan = value;

  // Method
  void analisisLaporan(LaporanKeuangan laporan) {}

  String generateSaran() {
    if (_saran.isEmpty) {
      return "Belum ada analisis dilakukan.";
    }
    return "Saran Penghematan untuk ID $_idPengguna:\n$_saran";
  }
}
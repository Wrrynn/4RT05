class LaporanKeuangan {
  //private atributes
  final int _idLaporan;
  final int _idPengguna;
  double _totalPemasukan;
  double _totalPengeluaran;
  double _totalKontribusi;
  int _totalKategori;
  DateTime _tanggalMulai;
  DateTime _tanggalSelesai;

  //Constructor
  LaporanKeuangan({
    required int idLaporan,
    required int idPengguna,
    required double totalPemasukan,
    required double totalPengeluaran,
    required double totalKontribusi,
    required int totalKategori,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
  })  : _idLaporan = idLaporan,
        _idPengguna = idPengguna,
        _totalPemasukan = totalPemasukan,
        _totalPengeluaran = totalPengeluaran,
        _totalKontribusi = totalKontribusi,
        _totalKategori = totalKategori,
        _tanggalMulai = tanggalMulai,
        _tanggalSelesai = tanggalSelesai;

  // Getter Setter
  int get idLaporan => _idLaporan;

  int get idPengguna => _idPengguna;

  double get totalPemasukan => _totalPemasukan;
  set totalPemasukan(double value) => _totalPemasukan = value;

  double get totalPengeluaran => _totalPengeluaran;
  set totalPengeluaran(double value) => _totalPengeluaran = value;

  double get totalKontribusi => _totalKontribusi;
  set totalKontribusi(double value) => _totalKontribusi = value;

  int get totalKategori => _totalKategori;
  set totalKategori(int value) => _totalKategori = value;

  DateTime get tanggalMulai => _tanggalMulai;
  set tanggalMulai(DateTime value) => _tanggalMulai = value;

  DateTime get tanggalSelesai => _tanggalSelesai;
  set tanggalSelesai(DateTime value) => _tanggalSelesai = value;

  // method
  double hitungTotalPemasukan() {
    return _totalPemasukan + _totalKontribusi;
  }

  double hitungTotalPengeluaran() {
    return _totalPengeluaran;
  }

  void tampilkanGrafik() {}

  String tampilkanRingkasan() {
    double saldo = hitungTotalPemasukan() - hitungTotalPengeluaran();

    return '''
===== Laporan Keuangan =====
ID Laporan     : $_idLaporan
ID Pengguna    : $_idPengguna
Periode        : ${_tanggalMulai.toLocal()} - ${_tanggalSelesai.toLocal()}
----------------------------------------
Total Pemasukan     : Rp${_totalPemasukan.toStringAsFixed(2)}
Total Pengeluaran   : Rp${_totalPengeluaran.toStringAsFixed(2)}
Total Kontribusi    : Rp${_totalKontribusi.toStringAsFixed(2)}
Jumlah Kategori     : $_totalKategori
----------------------------------------
Saldo Akhir         : Rp${saldo.toStringAsFixed(2)}
========================================
''';
  }
}
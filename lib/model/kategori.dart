class Kategori {
  //private atributes
  final int _idKategori;
  final int _idPengguna;
  String _namaKategori;
  String _tipeKategori;
  double _batasPengeluaran;
  double _totalPengerluaran;

  // COnstructor
  Kategori ({
    required int idKategori,
    required int idPengguna,
    required String namaKategori,
    required String tipeKategori,
    required double batasPengeluaran,
    required double totalPengerluaran,
  }) : 
  _idKategori = idKategori,
  _idPengguna = idPengguna,
  _namaKategori = namaKategori,
  _tipeKategori = tipeKategori,
  _batasPengeluaran = batasPengeluaran,
  _totalPengerluaran = totalPengerluaran;

  // Getter Setter
  int get idKategori => _idKategori;

  int get idPengguna => _idPengguna;

  String get namaKategori => _namaKategori;
  set namaKategori(String value) => _namaKategori = value;

  String get tipeKategori => _tipeKategori;
  set tipeKategori(String value) => _tipeKategori = value;

  double get batasPengeluaran => _batasPengeluaran;
  set batasPengeluaran(double value) => _batasPengeluaran = value;

  double get totalPengeluaran => _totalPengerluaran;
  set totalPengeluaran(double value) => _totalPengerluaran = value;

  //method
  bool tambahKategori(String nama, String tipe, double batas) {
    return true;
  }

  double hitungTotalKategori() {
    return 0;
  }

}
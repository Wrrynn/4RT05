class Topup {
  //private atributes
  final int _idTopUp;
  final int _idPengguna;
  double _jumlah;
  String _metode;
  String _status;

  Topup ({
    required int idTopUp,
    required int idPengguna,
    required double jumlah,
    required String metode,
    required String status,
  }) : 
  _idTopUp = idTopUp,
  _idPengguna = idPengguna,
  _jumlah = jumlah,
  _metode = metode,
  _status = status;

  // Getter & Setter
  int get idTopUp => _idTopUp;

  int get idPengguna => _idPengguna;

  double get jumlah => _jumlah;
  set jumlah(double value) => _jumlah = value;

  String get metode => _metode;
  set metode(String value) => _metode = value;

  String get status => _status;
  set status(String value) => _status = value;

  bool prosesTopUp() {
    return true;
  }
  void konfirmasiTopUP() {}
}
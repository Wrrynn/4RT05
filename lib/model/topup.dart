class Topup {
  final int _idTopUp;
  final String _idPenggunaTopup;
  double _jumlah;
  String _metode;
  String _status;

  Topup({
    required int idTopUp,
    required String idPenggunaTopup,
    required double jumlah,
    required String metode,
    required String status,
  })  : _idTopUp = idTopUp,
        _idPenggunaTopup = idPenggunaTopup,
        _jumlah = jumlah,
        _metode = metode,
        _status = status;

  // getter & setter
  int get idTopUp => _idTopUp;
  String get idPenggunaTopup => _idPenggunaTopup;

  double get jumlah => _jumlah;
  set jumlah(double value) => _jumlah = value;

  String get metode => _metode;
  set metode(String value) => _metode = value;

  String get status => _status;
  set status(String value) => _status = value;

  factory Topup.fromMap(Map<String, dynamic> map) {
    return Topup(
      idTopUp: map['id_topup'] ?? 0,
      idPenggunaTopup: map['id_pengguna_topup'] ?? '',
      jumlah: map['jumlah']?.toDouble() ?? 0.0,
      metode: map['metode'] ?? '',
      status: map['status'] ?? '',
    );
  }
}

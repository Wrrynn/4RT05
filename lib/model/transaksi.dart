class Transaksi {
  //private atributes
  final int _idTransaksi;
  final int _idPengguna;
  final int _idKategori;
  double _totalTransaksi;
  String _deskripsi;
  DateTime _waktuDibuat;
  String _metodeTransaksi;
  String _status;
  double _biayaTransfer;
  String _targetTransaksi;

  //Constructor
  Transaksi({
    required int idTransaksi,
    required int idPengguna,
    required int idKategori,
    required double totalTransaksi,
    required String deskripsi,
    required DateTime waktuDibuat,
    required String metodeTransaksi,
    required String status,
    required double biayaTransfer,
    required String targetTransaksi,
  }) : _idTransaksi = idTransaksi,
       _idPengguna = idPengguna,
       _idKategori = idKategori,
       _totalTransaksi = totalTransaksi,
       _deskripsi = deskripsi,
       _waktuDibuat = waktuDibuat,
       _metodeTransaksi = metodeTransaksi,
       _status = status,
       _biayaTransfer = biayaTransfer,
       _targetTransaksi = targetTransaksi;

  // Getter & Setter
  int get idTransaksi => _idTransaksi;

  int get idPengguna => _idPengguna;

  int get idKategori => _idKategori;

  double get totalTransaksi => _totalTransaksi;
  set totalTransaksi(double value) => _totalTransaksi = value;

  String get deskripsi => _deskripsi;
  set deskripsi(String value) => _deskripsi = value;

  DateTime get waktuDibuat => _waktuDibuat;
  set waktuDibuat(DateTime value) => _waktuDibuat = value;

  String get metodeTransaksi => _metodeTransaksi;
  set metodeTransaksi(String value) => _metodeTransaksi = value;

  String get status => _status;
  set status(String value) => _status = value;

  double get biayaTransfer => _biayaTransfer;
  set biayaTransfer(double value) => _biayaTransfer = value;

  String get targetTransaksi => _targetTransaksi;
  set targetTransaksi(String value) => _targetTransaksi = value;

  // method
  bool buatTransaksi() {
    return true;
  }

  String getBuktiTransaksi() {
    return '''
==== Bukti Transaksi ====
ID Transaksi   : $_idTransaksi
ID Pengguna    : $_idPengguna
Kategori       : $_idKategori
Metode         : $_metodeTransaksi
Status         : $_status
Total          : Rp${_totalTransaksi.toStringAsFixed(2)}
Biaya Transfer : Rp${_biayaTransfer.toStringAsFixed(2)}
Target         : $_targetTransaksi
Deskripsi      : $_deskripsi
Waktu Dibuat   : $_waktuDibuat
=========================
''';
  }

  double getTotalTransaksi() {
    return _totalTransaksi + _biayaTransfer;
  }
}

class Grup {
  // Atribut privat
  final int _idGrup;
  String _namaGrup;
  String _passwordGrup;
  double _target;
  String _durasi;
  final double _totalSaldo;
  final DateTime _dibuatPada;

  // Constructor
  Grup({
    required int idGrup,
    required String namaGrup,
    required String passwordGrup,
    required double target,
    required String durasi,
    required double totalSaldo,
    required DateTime dibuatPada,
  })  : _idGrup = idGrup,
        _namaGrup = namaGrup,
        _passwordGrup = passwordGrup,
        _target = target,
        _durasi = durasi,
        _totalSaldo = totalSaldo,
        _dibuatPada = dibuatPada;

  // Getter dan Setter
  int get idGrup => _idGrup;

  String get namaGrup => _namaGrup;
  set namaGrup(String nama) => _namaGrup = nama;

  String get passwordGrup => _passwordGrup;
  set passwordGrup(String pass) => _passwordGrup = pass;
  
  double get target => _target;
  set target(double targetBaru) => _target = targetBaru;
  
  String get durasi => _durasi;
  set durasi(String durasiBaru) => _durasi = durasiBaru;

  double get totalSaldo => _totalSaldo;
  DateTime get dibuatPada => _dibuatPada;

  
  // Method
  bool buatGrup(String nama, String pass, double target, String durasi) {
    return true;
  }
  void tambahTarget(double jumlah) {}

  String getInformasiGrup() {
    return '''
🧾 Informasi Grup:
- ID Grup: $_idGrup
- Nama Grup: $_namaGrup
- Target: Rp${_target.toStringAsFixed(2)}
- Durasi: $_durasi
- Total Saldo: Rp${_totalSaldo.toStringAsFixed(2)}
- Dibuat Pada: ${_dibuatPada.toLocal()}
''';
  }
}

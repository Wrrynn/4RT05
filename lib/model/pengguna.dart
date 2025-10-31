class Pengguna {
  // Private attributes
  final int _idPengguna;
  String _namaLengkap;
  String _namaPanggilan;
  final String _email;
  final String _password;
  String _telepon;
  double _saldo;

  // Constructor
  Pengguna({
    required int idPengguna,
    required String namaLengkap,
    required String namaPanggilan,
    required String email,
    required String password,
    required String telepon,
    double saldo = 0.0,
  })  : _idPengguna = idPengguna,
        _namaLengkap = namaLengkap,
        _namaPanggilan = namaPanggilan,
        _email = email,
        _password = password,
        _telepon = telepon,
        _saldo = saldo;

  // Getter & Setter
  int get idPengguna => _idPengguna;

  String get namaLengkap => _namaLengkap;
  set namaLengkap(String value) => _namaLengkap = value;

  String get namaPanggilan => _namaPanggilan;
  set namaPanggilan(String value) => _namaPanggilan = value;

  String get email => _email;

  String get password => _password;

  String get telepon => _telepon;
  set telepon(String value) => _telepon = value;

  double get saldo => _saldo;
  set saldo(double value) => _saldo = value;

  // Method 
  bool login() {
    return true;
  }
  bool register() {
    return true;
  }
}

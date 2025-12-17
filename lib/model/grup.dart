class Grup {
  final String _idGrup;
  String _namaGrup;
  String _passwordGrup;
  double _target;
  String _durasi;
  double _totalSaldo;
  final DateTime _dibuatPada;
  final String _dibuatOleh;

  Grup({
    required String idGrup,
    required String namaGrup,
    required String passwordGrup,
    required double target,
    required String durasi,
    double totalSaldo = 0,
    DateTime? dibuatPada,
    required String dibuatOleh,
  })  : _idGrup = idGrup,
        _namaGrup = namaGrup,
        _passwordGrup = passwordGrup,
        _target = target,
        _durasi = durasi,
        _totalSaldo = totalSaldo,
        _dibuatPada = dibuatPada ?? DateTime.now(),
        _dibuatOleh = dibuatOleh;

  Map<String, dynamic> toJson() {
    return {
      'id_grup': _idGrup,
      'nama_grup': _namaGrup,
      'password_grup': _passwordGrup,
      'target': _target,
      'durasi': _durasi,
      'total_saldo': _totalSaldo,
      'dibuat_pada': _dibuatPada.toIso8601String(),
      'dibuat_oleh': _dibuatOleh,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'nama_grup': _namaGrup,
      'password_grup': _passwordGrup,
      'target': _target,
      'durasi': _durasi,
      'total_saldo': _totalSaldo,
      'dibuat_oleh': _dibuatOleh,
    };
  }

  factory Grup.fromJson(Map<String, dynamic> json) {
    return Grup(
      idGrup: json['id_grup'] as String,
      namaGrup: json['nama_grup'] as String,
      passwordGrup: (json['password_grup'] ?? '') as String,
      target: (json['target'] as num).toDouble(),
      durasi: (json['durasi'] ?? '') as String,
      totalSaldo: (json['total_saldo'] as num?)?.toDouble() ?? 0.0,
      dibuatPada: json['dibuat_pada'] != null
          ? DateTime.parse(json['dibuat_pada'])
          : DateTime.now(),
      dibuatOleh: (json['dibuat_oleh'] ?? '') as String,
    );
  }

  // Getter dan Setter
  String get idGrup => _idGrup;

  String get namaGrup => _namaGrup;
  set namaGrup(String nama) => _namaGrup = nama;

  String get passwordGrup => _passwordGrup;
  set passwordGrup(String pass) => _passwordGrup = pass;

  double get target => _target;
  set target(double targetBaru) => _target = targetBaru;

  String get durasi => _durasi;
  set durasi(String durasiBaru) => _durasi = durasiBaru;

  double get totalSaldo => _totalSaldo;
  set totalSaldo(double value) => _totalSaldo = value;

  DateTime get dibuatPada => _dibuatPada;

  String get dibuatOleh => _dibuatOleh;

  String getInformasiGrup() {
    return '''
🧾 Informasi Grup:
- ID Grup: $_idGrup
- Nama Grup: $_namaGrup
- Target: Rp${_target.toStringAsFixed(0)}
- Durasi: $_durasi
- Total Saldo: Rp${_totalSaldo.toStringAsFixed(0)}
- Dibuat Oleh: $_dibuatOleh
- Dibuat Pada: ${_dibuatPada.toLocal()}
''';
  }
}

class Grup {
  final String _idGrup;
  String _namaGrup;
  double _target;
  String _durasi;
  double _totalSaldo;
  final DateTime _dibuatPada;
  final String _dibuatOleh;

  Grup({
    required String idGrup,
    required String namaGrup,
    required double target,
    required String durasi,
    double totalSaldo = 0,
    DateTime? dibuatPada,
    required String dibuatOleh,
  })  : _idGrup = idGrup,
        _namaGrup = namaGrup,
        _target = target,
        _durasi = durasi,
        _totalSaldo = totalSaldo,
        _dibuatPada = dibuatPada ?? DateTime.now(),
        _dibuatOleh = dibuatOleh;

  Map<String, dynamic> toJson() {
    return {
      'id_grup': _idGrup,
      'nama_grup': _namaGrup,
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
      target: (json['target'] as num).toDouble(),
      durasi: (json['durasi'] ?? '') as String,
      totalSaldo: (json['total_saldo'] as num?)?.toDouble() ?? 0.0,
      dibuatPada: json['dibuat_pada'] != null
          ? DateTime.parse(json['dibuat_pada'])
          : DateTime.now(),
      dibuatOleh: (json['dibuat_oleh'] ?? '') as String,
    );
  }

  String get idGrup => _idGrup;

  String get namaGrup => _namaGrup;
  set namaGrup(String nama) => _namaGrup = nama;

  double get target => _target;
  set target(double targetBaru) => _target = targetBaru;

  String get durasi => _durasi;
  set durasi(String durasiBaru) => _durasi = durasiBaru;

  double get totalSaldo => _totalSaldo;
  set totalSaldo(double value) => _totalSaldo = value;

  DateTime get dibuatPada => _dibuatPada;
  String get dibuatOleh => _dibuatOleh;
}

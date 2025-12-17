class GrupMember {
  final String _idMember;
  final String _idGrup;
  final String _idPengguna;
  int _jumlahKontribusi;
  String _role;
  final DateTime _joinedAt;

  GrupMember({
    required String idMember,
    required String idGrup,
    required String idPengguna,
    int jumlahKontribusi = 0,
    String role = 'member',
    DateTime? joinedAt,
  })  : _idMember = idMember,
        _idGrup = idGrup,
        _idPengguna = idPengguna,
        _jumlahKontribusi = jumlahKontribusi,
        _role = role,
        _joinedAt = joinedAt ?? DateTime.now();

  factory GrupMember.fromJson(Map<String, dynamic> json) {
    return GrupMember(
      idMember: json['id_member'] as String,
      idGrup: json['id_grup'] as String,
      idPengguna: json['id_pengguna'] as String,
      jumlahKontribusi:
          (json['jumlah_kontribusi'] as num?)?.toInt() ?? 0,
      role: (json['role'] ?? 'member') as String,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_member': idMember,
      'id_grup': idGrup,
      'id_pengguna': idPengguna,
      'jumlah_kontribusi': jumlahKontribusi,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'id_grup': idGrup,
      'id_pengguna': idPengguna,
      'jumlah_kontribusi': jumlahKontribusi,
      'role': role,
    };
  }

  Map<String, dynamic> toUpdateKontribusiJson() {
    return {
      'jumlah_kontribusi': jumlahKontribusi,
    };
  }

  String get idMember => _idMember;
  String get idGrup => _idGrup;
  String get idPengguna => _idPengguna;

  int get jumlahKontribusi => _jumlahKontribusi;
  set jumlahKontribusi(int value) {
    if (value >= 0) _jumlahKontribusi = value;
  }

  String get role => _role;
  set role(String value) => _role = value;

  DateTime get joinedAt => _joinedAt;

  void tambahKontribusi(int jumlah) {
    if (jumlah <= 0) {
      throw Exception("Jumlah kontribusi harus lebih dari 0");
    }
    _jumlahKontribusi += jumlah;
  }

  String getInformasiMember() {
    return '''
👤 Informasi Grup Member:
- ID Member: $_idMember
- ID Grup: $_idGrup
- ID Pengguna: $_idPengguna
- Role: $_role
- Total Kontribusi: Rp$_jumlahKontribusi
''';
  }
}

class Kantong {
  final String idKantong;
  final String idGrup;
  final String idMember;
  double saldo;

  Kantong({
    required this.idKantong,
    required this.idGrup,
    required this.idMember,
    required this.saldo,
  });

  factory Kantong.fromJson(Map<String, dynamic> json) {
    return Kantong(
      idKantong: json['id_kantong'] as String,
      idGrup: json['id_grup'] as String,
      idMember: json['id_member'] as String,
      saldo: (json['saldo'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kantong': idKantong,
      'id_grup': idGrup,
      'id_member': idMember,
      'saldo': saldo,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'id_grup': idGrup,
      'id_member': idMember,
      'saldo': saldo,
    };
  }

}

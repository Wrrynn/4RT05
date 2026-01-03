import 'package:artos/service/db_service.dart';

class Pengguna {
  final String idPengguna;
  String namaLengkap;
  final String email;
  final String password;
  String? rekening;
  String telepon;
  double saldo;

  Pengguna({
    required this.idPengguna,
    required this.namaLengkap,
    required this.email,
    required this.password,
    required this.telepon,
    this.rekening,
    this.saldo = 0,
  });

  // Convert model → JSON
  Map<String, dynamic> toJson() {
    return {
      'id_pengguna': idPengguna,
      'nama_lengkap': namaLengkap,
      'email': email,
      'password': password,
      'telepon': telepon,
      'saldo': saldo,
    };
  }

  // Convert JSON → model
  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
      idPengguna: json['id_pengguna'],
      namaLengkap: json['nama_lengkap'],
      email: json['email'],
      password: json['password'],
      telepon: json['telepon'],
      rekening: json['rekening'],
      saldo: (json['saldo'] as num).toDouble(),
    );
  }

  /* =======================
     DATABASE (MODEL LAYER)
     ======================= */

  static Future<Pengguna?> findById(String idPengguna) async {
    final supabase = DBService.client;

    final data = await supabase
        .from('Pengguna')
        .select()
        .eq('id_pengguna', idPengguna)
        .maybeSingle();

    if (data == null) return null;
    return Pengguna.fromJson(data);
  }
}
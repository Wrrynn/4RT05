class Pengguna {
  final String idPengguna;      
  String namaLengkap;
  final String email;
  final String password;
  String telepon;
  double saldo;

  Pengguna({
    required this.idPengguna,
    required this.namaLengkap,
    required this.email,
    required this.password,
    required this.telepon,
    this.saldo = 0.0,
  });

  // Convert model → JSON (untuk insert Supabase)
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

  // Convert JSON → model (untuk fetch)
  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
      idPengguna: json['id_pengguna'],
      namaLengkap: json['nama_lengkap'],
      email: json['email'],
      password: json['password'],
      telepon: json['telepon'],
      saldo: (json['saldo'] as num).toDouble(),
    );
  }
}

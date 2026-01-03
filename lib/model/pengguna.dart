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

  /* ==========================================
     DATABASE METHODS (MVC Logic Here)
     ========================================== */

  static final _supabase = DBService.client;

  static Future<Pengguna?> findById(String id) async {
    final data = await _supabase
        .from('Pengguna')
        .select()
        .eq('id_pengguna', id)
        .maybeSingle();

    return data == null ? null : Pengguna.fromJson(data);
  }

  static Future<bool> emailExists(String email) async {
    final data = await _supabase
        .from('Pengguna')
        .select('email')
        .eq('email', email)
        .maybeSingle();

    return data != null;
  }

  static Future<bool> phoneExists(String telepon) async {
    final data = await _supabase
        .from('Pengguna')
        .select('telepon')
        .eq('telepon', telepon)
        .maybeSingle();

    return data != null;
  }

  static Future<void> insert(Pengguna pengguna) async {
    await _supabase.from('Pengguna').insert(pengguna.toJson());
  }

  // --- NEW: Method untuk Forgot Password (Cari by Email & Telepon) ---
  static Future<Pengguna?> findByEmailAndPhone(String email, String telepon) async {
    final data = await _supabase
        .from('Pengguna')
        .select()
        .eq('email', email)
        .eq('telepon', telepon)
        .maybeSingle();

    return data == null ? null : Pengguna.fromJson(data);
  }

  // --- NEW: Method untuk Update Password ---
  static Future<void> updatePassword(String userId, String newPassword) async {
    await _supabase
        .from('Pengguna')
        .update({'password': newPassword})
        .eq('id_pengguna', userId);
  }

  // --- Saldo Logic ---

  static Future<void> addSaldo(String userId, double amount) async {
    final user = await _supabase
        .from('Pengguna')
        .select('saldo')
        .eq('id_pengguna', userId)
        .single();

    final double oldSaldo = (user['saldo'] ?? 0).toDouble();

    await _supabase
        .from('Pengguna')
        .update({'saldo': oldSaldo + amount})
        .eq('id_pengguna', userId);
  }

  static Future<Pengguna?> findByRekening(String rekening) async {
    final res = await _supabase
        .from('Pengguna')
        .select()
        .eq('rekening', rekening)
        .maybeSingle();

    return res == null ? null : Pengguna.fromJson(res);
  }

  static Future<List<Pengguna>> search(String query) async {
    final res = await _supabase
        .from('Pengguna')
        .select()
        .or('nama_lengkap.ilike.%$query%,rekening.ilike.%$query%')
        .limit(20);

    return (res as List).map((e) => Pengguna.fromJson(e)).toList();
  }

  static Future<void> decreaseSaldo(String userId, double amount) async {
    final user = await findById(userId);
    if (user == null) throw Exception("Pengguna tidak ditemukan");

    await _supabase
        .from('Pengguna')
        .update({'saldo': user.saldo - amount})
        .eq('id_pengguna', userId);
  }

  static Future<void> increaseSaldo(String userId, double amount) async {
    final user = await findById(userId);
    if (user == null) throw Exception("Pengguna tidak ditemukan");

    await _supabase
        .from('Pengguna')
        .update({'saldo': user.saldo + amount})
        .eq('id_pengguna', userId);
  }

  // ================= PAYMENT SUPPORT =================

  static Future<double?> getSaldo(String userId) async {
    final res = await _supabase
        .from('Pengguna')
        .select('saldo')
        .eq('id_pengguna', userId)
        .maybeSingle();

    return res == null ? null : (res['saldo'] as num).toDouble();
  }

  static Future<void> decreaseSaldoSafe(
    String userId,
    double amount,
  ) async {
    final saldo = await getSaldo(userId);
    if (saldo == null) throw Exception('Pengguna tidak ditemukan');
    if (saldo < amount) throw Exception('Saldo tidak cukup');

    await _supabase
        .from('Pengguna')
        .update({'saldo': saldo - amount})
        .eq('id_pengguna', userId);
  }

  static Future<String> resolveName(String uid) async {
  final res = await _supabase
      .from('Pengguna')
      .select('nama_lengkap')
      .eq('id_pengguna', uid)
      .maybeSingle();

  return res?['nama_lengkap']?.toString() ?? 'Pengguna';
}
}
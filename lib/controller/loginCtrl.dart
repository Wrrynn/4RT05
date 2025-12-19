import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:artos/service/db_service.dart';
import 'package:artos/model/pengguna.dart';

class LoginController {
  final supabase = DBService.client;

  /// Login user dan cek status verifikasi
  /// Mengembalikan Pengguna jika sukses, atau melempar Exception jika gagal
  Future<Pengguna> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = response.user;

      if (user == null) {
        throw Exception("Email atau password salah.");
      }

      if (user.emailConfirmedAt == null) {
        throw Exception("Akun belum diverifikasi. Silakan cek email Anda.");
      }

      final data = await supabase
          .from('Pengguna')
          .select()
          .eq('id_pengguna', user.id)
          .maybeSingle();

      if (data == null) {
        throw Exception("Akun belum terdaftar. Silakan registrasi.");
      }

      return Pengguna.fromJson(data);
    } on AuthException catch (e) {
      // Supabase sengaja menyamarkan error
      if (e.message.toLowerCase().contains('invalid login')) {
        throw Exception(
          "Email atau password salah. Atau akun belum diverifikasi.",
        );
      }
      throw Exception(e.message);
    }
  }
}

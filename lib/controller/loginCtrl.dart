import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:artos/model/pengguna.dart';
import 'package:artos/service/db_service.dart';

class LoginController {
  final supabase = DBService.client;

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

      // Controller hanya panggil Model
      final pengguna = await Pengguna.findById(user.id);

      if (pengguna == null) {
        throw Exception("Akun belum terdaftar. Silakan registrasi.");
      }

      return pengguna;
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('invalid login')) {
        throw Exception(
          "Email atau password salah atau akun belum diverifikasi.",
        );
      }
      throw Exception(e.message);
    }
  }
}
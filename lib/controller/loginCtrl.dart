import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:artos/service/db_service.dart';
import 'package:artos/model/pengguna.dart';

class LoginController {
  final supabase = DBService.client;

  Future<Pengguna?> login(String email, String password) async {
    try {
      // 1️⃣ Login via Supabase Auth
      final response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = response.user;

      if (user == null) {
        return null; // Gagal login
      }

      // 2️⃣ Ambil data pengguna dari tabel berdasarkan UID
      final data = await supabase
          .from('Pengguna')
          .select()
          .eq('id_pengguna', user.id)
          .maybeSingle();

      if (data == null) {
        return null; // Data pengguna tidak ditemukan
      }

      // 3️⃣ Convert JSON → Model Pengguna
      final pengguna = Pengguna.fromJson(data);

      return pengguna; // sukses

    } on AuthException catch (_) {
      return null; // Email atau password salah
    } catch (_) {
      return null; // Error lain
    }
  }
}

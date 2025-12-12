import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:artos/service/db_service.dart';

class LoginController {
  final supabase = DBService.client;

  Future<String?> login(String email, String password) async {
    try {
      // 1️⃣ Login via Supabase Auth
      final response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = response.user;

      if (user == null) {
        return "Login gagal, user tidak ditemukan.";
      }

      // 2️⃣ Ambil data pengguna dari tabel Pengguna berdasarkan UID
      final data = await supabase
          .from('Pengguna')
          .select()
          .eq('id_pengguna', user.id)
          .maybeSingle();

      if (data == null) {
        return "Data pengguna tidak ditemukan di database.";
      }

      // 3️⃣ Jika sukses
      return null; // sukses

    } on AuthException catch (e) {
      return e.message; // Email salah, password salah, atau tidak terdaftar
    } catch (e) {
      return "Terjadi kesalahan, coba lagi.";
    }
  }
}

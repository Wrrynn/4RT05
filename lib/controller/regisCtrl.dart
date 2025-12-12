import 'package:artos/service/db_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisController {
  final supabase = DBService.client;

  Future<String?> registerUser({
    required String fullName,
    required String email,
    required String password,
    required String telepon,
  }) async {

    // VALIDASI PASSWORD MINIMAL 6
    if (password.length < 6) {
      return "Password harus minimal 6 karakter!";
    }

    try {
      //Sign Up Supabase Auth
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = authResponse.user;

      if (user == null) {
        return "Gagal membuat akun auth.";
      }

      // UID auth user
      final uid = user.id;

      // Masukkan ke tabel Pengguna (wajib punya kolom 'id')
      final insertResponse = await supabase.from('Pengguna').insert({
        'id_pengguna': uid,              
        'nama_lengkap': fullName,
        'email': email,
        'password':password,
        'telepon': telepon,
        'saldo': 0,
      }).select();

      if (insertResponse.isEmpty) {
        return "Gagal memasukkan data pengguna.";
      }

      return null; // sukses

    } on AuthException catch (e) {
      return "Auth error: ${e.message}";
    } on PostgrestException catch (e) {
      return "Database error: ${e.message}";
    } catch (e) {
      return "Kesalahan tak terduga: $e";
    }
  }
}

import 'package:artos/model/pengguna.dart';
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
    if (password.length < 6) {
      return "Password harus minimal 6 karakter!";
    }

    try {
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) {
        return "Gagal membuat akun auth.";
      }

      final uid = user.id;

      final pengguna = Pengguna(
        idPengguna: uid,
        namaLengkap: fullName,
        email: email,
        password: password,
        telepon: telepon,
      );

      final response = await supabase
          .from('Pengguna')
          .insert(pengguna.toJson())
          .select();

      if (response.isEmpty) {
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

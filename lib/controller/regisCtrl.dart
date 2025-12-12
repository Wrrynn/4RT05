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
    try {
      // Cek email apakah sudah ada
      final existingUser = await supabase
          .from('Pengguna')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        return "Email sudah terdaftar!";
      }

      // 🔥 2. Insert user baru
      final insertResponse = await supabase.from('Pengguna').insert({
        'nama_lengkap': fullName,
        'email': email,
        'password': password, // sebaiknya di-hash nanti
        'telepon': telepon,
        'saldo': 0,
      }).select(); // penting agar Supabase v2 tidak error

      // Jika berhasil
      if (insertResponse.isNotEmpty) {
        return null;
      } else {
        return "Gagal menambahkan pengguna.";
      }

    } on PostgrestException catch (e) {
      // Error berasal dari Supabase
      return "Database error: ${e.message}";
    } catch (e) {
      // Error umum (koneksi, null, dll)
      return "Kesalahan tak terduga: $e";
    }
  }
}

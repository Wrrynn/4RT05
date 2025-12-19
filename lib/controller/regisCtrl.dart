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
    // Validasi nama
    if (fullName.trim().isEmpty || fullName.length > 14) {
      return "Nama harus diisi dan maksimal 14 karakter.";
    }

    // Validasi email
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(email)) {
      return "Email tidak valid.";
    }

    // Validasi nomor telepon
    final phoneRegex = RegExp(r"^08\d{8,12}$");
    if (!phoneRegex.hasMatch(telepon)) {
      return "Nomor telepon harus dimulai dengan '08' dan panjang 10-14 digit.";
    }

    // Validasi password
    if (password.length < 6) {
      return "Password harus minimal 6 karakter.";
    }
    final passwordRegex = RegExp(r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$");
    if (!passwordRegex.hasMatch(password)) {
      return "Password harus mengandung kombinasi huruf dan angka.";
    }

    try {
      // Cek apakah email sudah digunakan
      final existingEmail = await supabase
          .from('Pengguna')
          .select()
          .eq('email', email)
          .maybeSingle();
      if (existingEmail != null) {
        return "Email sudah digunakan.";
      }

      // Cek apakah nomor telepon sudah digunakan
      final existingPhone = await supabase
          .from('Pengguna')
          .select()
          .eq('telepon', telepon)
          .maybeSingle();
      if (existingPhone != null) {
        return "Nomor telepon sudah digunakan.";
      }

      // Register auth
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) {
        return "Gagal membuat akun autentikasi.";
      }

      final uid = user.id;

      // Buat objek pengguna
      final pengguna = Pengguna(
        idPengguna: uid,
        namaLengkap: fullName,
        email: email,
        password: password,
        telepon: telepon,
      );

      // Insert ke database
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

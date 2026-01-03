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
    // ================= VALIDASI =================
    if (fullName.trim().isEmpty || fullName.length > 14) {
      return "Nama harus diisi dan maksimal 14 karakter.";
    }

    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(email)) {
      return "Email tidak valid.";
    }

    final phoneRegex = RegExp(r"^08\d{8,12}$");
    if (!phoneRegex.hasMatch(telepon)) {
      return "Nomor telepon tidak valid.";
    }

    final passwordRegex =
        RegExp(r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$");
    if (!passwordRegex.hasMatch(password)) {
      return "Password harus kombinasi huruf dan angka (min 6).";
    }

    try {
      // ================= CEK DUPLIKASI =================
      if (await Pengguna.emailExists(email)) {
        return "Email sudah digunakan.";
      }

      if (await Pengguna.phoneExists(telepon)) {
        return "Nomor telepon sudah digunakan.";
      }

      // ================= AUTH =================
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) {
        return "Gagal membuat akun.";
      }

      // ================= INSERT DB =================
      final pengguna = Pengguna(
        idPengguna: user.id,
        namaLengkap: fullName,
        email: email,
        password: password,
        telepon: telepon,
      );

      await Pengguna.insert(pengguna);

      return null; //  sukses
    } on AuthException catch (e) {
      return "Auth error: ${e.message}";
    } catch (e) {
      return "Kesalahan sistem: $e";
    }
  }
}

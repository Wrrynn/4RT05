import 'package:flutter/material.dart';
import '../model/pengguna.dart';

class ForgotPasswordController {
  // HAPUS: final SupabaseClient _supabase ... (Tidak boleh ada di Controller MVC Murni)

  /// validasi password:
  /// minimal 6 karakter + kombinasi huruf & angka
  bool _isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');
    return regex.hasMatch(password);
  }

  /// HANDLE LOGIC RESET PASSWORD (dipanggil dari UI)
  Future<void> handleUbah({
    required BuildContext context,
    required String email,
    required String telepon,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // 1. Validasi field kosong
    if (email.isEmpty ||
        telepon.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnack(context, "Lengkapi semua field dulu ya.");
      return;
    }

    // 2. Validasi format password
    if (!_isPasswordValid(newPassword)) {
      _showSnack(
        context,
        "Password minimal 6 karakter dan harus kombinasi huruf & angka",
      );
      return;
    }

    // 3. Konfirmasi password
    if (newPassword != confirmPassword) {
      _showSnack(context, "Confirm password tidak sama.");
      return;
    }

    try {
      // 4. Cari pengguna (Panggil Model)
      // Controller tidak tahu soal "select * from ...", dia hanya minta data ke Model.
      final pengguna = await Pengguna.findByEmailAndPhone(email, telepon);

      if (pengguna == null) {
        _showSnack(context, "Email atau nomor telepon tidak ditemukan");
        return;
      }

      // 5. Update password (Panggil Model)
      await Pengguna.updatePassword(pengguna.idPengguna, newPassword);

      _showSnack(context, "Password ${pengguna.namaLengkap} berhasil diubah");

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnack(context, "Terjadi kesalahan: $e");
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
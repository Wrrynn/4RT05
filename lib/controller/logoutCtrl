import 'package:flutter/material.dart';
import 'package:artos/service/db_service.dart';

class LogoutController {
  /// Fungsi untuk mengeluarkan pengguna dari sesi Supabase
  Future<void> logout(BuildContext context) async {
    try {
      // Keluar dari sesi Supabase
      await DBService.client.auth.signOut();
      
      // Hapus semua tumpukan navigasi dan kembali ke halaman login
      // Pastikan rute '/login' sudah terdaftar di main.dart
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal Logout: $e")),
        );
      }
    }
  }
}
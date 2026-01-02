import 'package:flutter/material.dart';
import 'package:artos/model/pengguna.dart';
import 'package:artos/controller/laporanCtrl.dart';
import 'package:artos/controller/logoutCtrl.dart';
import 'package:artos/service/db_service.dart';

class HomeController {
  final LaporanKeuanganController _laporanCtrl =
      LaporanKeuanganController();
  final LogoutController _logoutCtrl = LogoutController();

  // ===== STATE =====
  late Pengguna pengguna;
  bool isBalanceVisible = true;

  double pemasukanBulanIni = 0;
  double pengeluaranBulanIni = 0;

  /// Inisialisasi awal
  void init(Pengguna p) {
    pengguna = p;
  }

  /// Toggle visibilitas saldo
  void toggleVisibility() {
    isBalanceVisible = !isBalanceVisible;
  }

  /// Ambil data dashboard (LAPORAN BULANAN)
  Future<void> loadDashboardData() async {
    try {
      final now = DateTime.now();

      final data = await _laporanCtrl.getMonthlyReportData(
        pengguna.idPengguna,
        now,
      );

      pemasukanBulanIni = (data['pemasukan'] ?? 0).toDouble();
      pengeluaranBulanIni = (data['pengeluaran'] ?? 0).toDouble();
    } catch (e) {
      debugPrint("Gagal load dashboard data: $e");
      pemasukanBulanIni = 0;
      pengeluaranBulanIni = 0;
    }
  }

  /// Refresh saldo + laporan
  Future<Pengguna?> refreshData(String uid) async {
    try {
      final res = await DBService.client
          .from('Pengguna')
          .select()
          .eq('id_pengguna', uid)
          .maybeSingle();

      await loadDashboardData();

      if (res != null) {
        pengguna = Pengguna.fromJson(res);
        return pengguna;
      }
    } catch (e) {
      debugPrint("Refresh failed: $e");
    }
    return null;
  }

  /// Logout
  void logout(BuildContext context) {
    _logoutCtrl.logout(context);
  }
}
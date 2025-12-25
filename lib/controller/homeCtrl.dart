import 'package:flutter/material.dart';
import 'package:artos/model/pengguna.dart';
import 'package:artos/controller/historyCtrl.dart';
import 'package:artos/controller/logoutCtrl.dart';
import 'package:artos/service/db_service.dart';

class HomeController {
  final HistoryController _historyCtrl = HistoryController();
  final LogoutController _logoutCtrl = LogoutController();

  // State yang dipindah dari UI
  late Pengguna pengguna;
  int pageIndex = 0;
  bool isRefreshing = false;
  bool isBalanceVisible = true;
  double pemasukanBulanIni = 0;
  double pengeluaranBulanIni = 0;

  /// Inisialisasi data awal
  void init(Pengguna p) {
    pengguna = p;
  }

  /// Toggle visibilitas saldo
  void toggleVisibility() => isBalanceVisible = !isBalanceVisible;

  /// Mengambil data laporan bulanan
  Future<void> loadDashboardData() async {
    try {
      final data = await _historyCtrl.getMonthlyReportData(
        pengguna.idPengguna, 
        DateTime.now()
      );
      pemasukanBulanIni = data['pemasukan'];
      pengeluaranBulanIni = data['pengeluaran'];
    } catch (e) {
      debugPrint("Gagal load dashboard data: $e");
    }
  }

  /// Logika Refresh
  Future<Pengguna?> refreshData(String uid) async {
    try {
      final res = await DBService.client
          .from('Pengguna')
          .select()
          .eq('id_pengguna', uid)
          .maybeSingle();
      
      await loadDashboardData();

      if (res != null) {
        return Pengguna.fromJson(res);
      }
    } catch (e) {
      debugPrint("Refresh failed: $e");
    }
    return null;
  }

  /// Logika Logout
  void logout(BuildContext context) => _logoutCtrl.logout(context);
}
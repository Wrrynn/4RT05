import 'package:artos/model/transaksi.dart';
import 'package:artos/model/kategori.dart';
import 'package:artos/service/db_service.dart';
import 'package:artos/widgets/currency.dart';

// ===== VA MODEL =====
class VirtualAccount {
  static const Map<String, String> bankCodes = {
    '008': 'Mandiri',
    '014': 'BCA',
    '009': 'BNI',
    '002': 'BRI',
  };

  static const Map<String, String> merchantCodes = {
    '123': 'Toko Buah',
    '456': 'Burger Mountain',
    '789': 'Pomodoro',
  };

  final String vaCode; // 999
  final String bankCode; // 008, 014, 009, 002
  final String merchantCode; // 123, 456, 789
  final int amount; // 2 digits → multiply by 1000 (10 = 10000)
  final int expireYear; // 2 digits (30 = 2030)

  String get merchantName => merchantCodes[merchantCode] ?? 'Unknown';
  String get bankName => bankCodes[bankCode] ?? 'Unknown';
  int get totalAmount => amount * 1000;

  VirtualAccount({
    required this.vaCode,
    required this.bankCode,
    required this.merchantCode,
    required this.amount,
    required this.expireYear,
  });
}

class PaymentController {
  // ===== BANK CODES =====
  static const Map<String, String> bankCodes = {
    '008': 'Mandiri',
    '014': 'BCA',
    '009': 'BNI',
    '002': 'BRI',
  };

  // ===== MERCHANT CODES =====
  static const Map<String, String> merchantCodes = {
    '123': 'Toko Buah',
    '456': 'Burger Mountain',
    '789': 'Pomodoro',
  };

  // ===== PARSE VA FROM STRING =====
  /// Parse 16-digit VA string to VirtualAccount object
  /// Format: 999 (3) + 014 (3) + 123 (3) + 10 (2) + 30 (2) = 13 digit
  VirtualAccount? parseVA(String vaString) {
    final cleaned = vaString.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.length != 13) return null;

    try {
      final vaCode = cleaned.substring(0, 3);
      final bankCode = cleaned.substring(3, 6);
      final merchantCode = cleaned.substring(6, 9);
      final amount = int.parse(cleaned.substring(9, 11));
      final expireYear = int.parse(cleaned.substring(11, 13));

      if (!bankCodes.containsKey(bankCode)) return null;
      if (!merchantCodes.containsKey(merchantCode)) return null;

      return VirtualAccount(
        vaCode: vaCode,
        bankCode: bankCode,
        merchantCode: merchantCode,
        amount: amount,
        expireYear: expireYear,
      );
    } catch (_) {
      return null;
    }
  }

  // ===== VALIDATE VA =====
  bool isValidVA(String vaString) {
    return parseVA(vaString) != null;
  }

  // ===== PROCESS PAYMENT =====
  /// Memproses pembayaran VA
  /// Mengurangi saldo pengguna dan membuat transaksi baru
  Future<String?> processPayment({
    required String vaNumber,
    required String idPengguna,
    required String idKategori,
    required double biayaTransfer,
    required String deskripsi,
  }) async {
    try {
      // Parse VA
      final va = parseVA(vaNumber);
      if (va == null) {
        return 'VA tidak valid';
      }

      // Fetch user saldo
      final userRes = await DBService.client
          .from('Pengguna')
          .select('saldo')
          .eq('id_pengguna', idPengguna)
          .maybeSingle();

      if (userRes == null) {
        return 'Pengguna tidak ditemukan';
      }

      final currentSaldo = (userRes['saldo'] as num).toDouble();
      final totalAmount = va.totalAmount + biayaTransfer;

      // Cek saldo cukup
      if (currentSaldo < totalAmount) {
        return 'Saldo tidak cukup. Dibutuhkan Rp ${formatCurrency(totalAmount)} tetapi Anda memiliki Rp ${formatCurrency(currentSaldo)}';
      }

      // Create transaksi object
      final transaksi = Transaksi(
        idPengguna: idPengguna,
        idKategori: idKategori,
        targetMerchant: va.merchantName, // simpan merchant code sebagai target
        targetPengguna: null,
        totalTransaksi: va.totalAmount.toDouble(),
        deskripsi: deskripsi.isEmpty
            ? 'Pembayaran VA ke ${va.merchantName} via ${va.bankName}'
            : deskripsi,
        metodeTransaksi: 'VA_${va.bankName}',
        status: 'sukses',
        biayaTransfer: biayaTransfer,
        waktuDibuat: DateTime.now(),
      );

      // Insert transaksi ke DB
      final insertRes = await DBService.client
          .from('Transaksi')
          .insert(transaksi.toMap())
          .select();

      if (insertRes.isEmpty) {
        return 'Gagal membuat transaksi';
      }

      final idTransaksi = insertRes[0]['id_transaksi'];

      // Update saldo pengguna
      final newSaldo = currentSaldo - totalAmount;
      await DBService.client
          .from('Pengguna')
          .update({'saldo': newSaldo})
          .eq('id_pengguna', idPengguna);

      // Return success dengan id transaksi
      return idTransaksi;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // ===== GET MERCHANT INFO =====
  /// Dapatkan info merchant dari merchant code
  String getMerchantInfo(String merchantCode) {
    return merchantCodes[merchantCode] ?? 'Unknown Merchant';
  }

  // ===== GET BANK INFO =====
  /// Dapatkan info bank dari bank code
  String getBankInfo(String bankCode) {
    return bankCodes[bankCode] ?? 'Unknown Bank';
  }

  // ===== GENERATE VA DUMMY =====
  /// Generate VA dummy untuk testing
  String generateDummyVA({
    required String bankCode,
    required String merchantCode,
    required String userId,
    required int amountDigits, // 2 digits (10 = 10000)
    required int expireYear, // 2 digits (30 = 2030)
  }) {
    const vaCode = '999';
    final bank = bankCode.padLeft(3, '0');
    final merchant = merchantCode.padLeft(3, '0');
    final user = userId.padLeft(3, '0');
    final amount = amountDigits.toString().padLeft(2, '0');
    final expire = expireYear.toString().padLeft(2, '0');

    return '$vaCode$bank$merchant$user$amount$expire';
  }

  // ===== GET KATEGORI DROPDOWN =====
  /// Ambil kategori pengeluaran milik user
  Future<List<Kategori>> getKategoriDropdown(String idPengguna) async {
    try {
      final res = await DBService.client
          .from('Kategori') // ⚠️ pastikan lowercase
          .select()
          .eq('id_pengguna', idPengguna)
          .eq('tipe_kategori', 'pengeluaran')
          .order('nama_kategori');

      if (res is List) {
        return res
            .map((e) => Kategori.fromMap(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Gagal load kategori: $e');
    }
  }
}

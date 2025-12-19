import 'package:artos/model/transaksi.dart';
import 'package:artos/model/kategori.dart';
import 'package:artos/service/db_service.dart';

class VirtualAccount {
  static const Map<String, String> bankCodes = {
    '008': 'Mandiri',
    '014': 'BCA',
    '009': 'BNI',
    '002': 'BRI',
  };

  static const Map<String, String> merchantCodes = {
    '01': 'Toko Buah',
    '02': 'Burger Mountain',
    '03': 'Pomodoro',
  };

  final String vaCode;       // 2 digit (99)
  final String bankCode;     // 3 digit (014)
  final String merchantCode; // 2 digit (01)
  final int totalAmount;     // 4 digit (Langsung nominal, misal 5000)
  final int expiryMonth;     // 2 digit (MM)
  final int expiryYear;      // 2 digit (YY)

  String get merchantName => merchantCodes[merchantCode] ?? 'Unknown';
  String get bankName => bankCodes[bankCode] ?? 'Unknown';

  VirtualAccount({
    required this.vaCode,
    required this.bankCode,
    required this.merchantCode,
    required this.totalAmount,
    required this.expiryMonth,
    required this.expiryYear,
  });

  // Logika Cek Expired
  bool isExpired() {
    final now = DateTime.now();
    // Expiry MM/YY dianggap valid sampai akhir bulan tersebut
    // Misal 12/25 berarti valid sampai 31 Desember 2025 jam 23:59
    final expiryDate = DateTime(2000 + expiryYear, expiryMonth + 1, 0, 23, 59);
    return now.isAfter(expiryDate);
  }
}

class PaymentResult {
  final bool success;
  final String message;
  final String? transactionId;

  PaymentResult({
    required this.success,
    required this.message,
    this.transactionId,
  });
}

class PaymentController {
  // Parsing 15 Digit: 2 + 3 + 2 + 4 + 4 = 15
  VirtualAccount? parseVA(String vaString) {
    final cleaned = vaString.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length != 15) return null;

    try {
      final vaCode = cleaned.substring(0, 2);
      final bankCode = cleaned.substring(2, 5);
      final merchantCode = cleaned.substring(5, 7);
      final amount = int.parse(cleaned.substring(7, 11));
      final month = int.parse(cleaned.substring(11, 13));
      final year = int.parse(cleaned.substring(13, 15));

      if (!VirtualAccount.bankCodes.containsKey(bankCode)) return null;
      if (!VirtualAccount.merchantCodes.containsKey(merchantCode)) return null;
      if (month < 1 || month > 12) return null;

      return VirtualAccount(
        vaCode: vaCode,
        bankCode: bankCode,
        merchantCode: merchantCode,
        totalAmount: amount*1000,
        expiryMonth: month,
        expiryYear: year,
      );
    } catch (_) {
      return null;
    }
  }

  Future<PaymentResult> processPayment({
    required String vaNumber,
    required String idPengguna,
    required String idKategori,
    required double biayaTransfer,
    required String deskripsi,
  }) async {
    try {
      final va = parseVA(vaNumber);
      if (va == null) {
        return PaymentResult(
          success: false,
          message: 'VA tidak valid',
        );
      }

      // 🔴 VALIDASI EXPIRED
      if (va.isExpired()) {
        return PaymentResult(
          success: false,
          message: 'Nomor VA sudah kadaluarsa (Expired)',
        );
      }

      final userRes = await DBService.client
          .from('Pengguna')
          .select('saldo')
          .eq('id_pengguna', idPengguna)
          .maybeSingle();

      if (userRes == null) {
        return PaymentResult(
          success: false,
          message: 'Pengguna tidak ditemukan',
        );
      }

      final currentSaldo = (userRes['saldo'] as num).toDouble();
      final totalAmount = va.totalAmount + biayaTransfer;

      if (currentSaldo < totalAmount) {
        return PaymentResult(
          success: false,
          message: 'Saldo tidak cukup',
        );
      }

      final transaksi = Transaksi(
        idPengguna: idPengguna,
        idKategori: idKategori,
        targetMerchant: va.merchantName,
        targetPengguna: null,
        totalTransaksi: va.totalAmount.toDouble(),
        deskripsi: deskripsi.isEmpty
            ? 'Bayar ${va.merchantName}'
            : deskripsi,
        metodeTransaksi: 'VA_${va.bankName}',
        status: 'sukses',
        biayaTransfer: biayaTransfer,
        waktuDibuat: DateTime.now(),
      );

      final insertRes = await DBService.client
          .from('Transaksi')
          .insert(transaksi.toMap())
          .select();

      if (insertRes.isEmpty) {
        return PaymentResult(
          success: false,
          message: 'Gagal membuat transaksi',
        );
      }

      await DBService.client
          .from('Pengguna')
          .update({'saldo': currentSaldo - totalAmount})
          .eq('id_pengguna', idPengguna);

      return PaymentResult(
        success: true,
        message: 'Pembayaran berhasil',
        transactionId: insertRes[0]['id_transaksi'],
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  Future<List<Kategori>> getKategoriDropdown(String idPengguna) async {
    final res = await DBService.client
        .from('Kategori')
        .select()
        .eq('id_pengguna', idPengguna)
        .order('nama_kategori');

    return (res as List).map((e) => Kategori.fromMap(e)).toList();
  }
}
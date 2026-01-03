import 'package:artos/model/transaksi.dart';
import 'package:artos/model/pengguna.dart';
import 'package:artos/model/kategori.dart';
import 'package:artos/model/virtual_account.dart';
import 'package:artos/model/payment_result.dart';

class PaymentController {
  // ================= VA PARSER =================
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
        totalAmount: amount * 1000,
        expiryMonth: month,
        expiryYear: year,
      );
    } catch (_) {
      return null;
    }
  }

  // ================= PAYMENT PROCESS =================
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

      if (va.isExpired()) {
        return PaymentResult(
          success: false,
          message: 'Nomor VA sudah kadaluarsa',
        );
      }

      final totalBayar = va.totalAmount + biayaTransfer;

      // 🔹 Validasi & potong saldo (MODEL)
      await Pengguna.decreaseSaldoSafe(idPengguna, totalBayar.toDouble());

      // 🔹 Buat transaksi (MODEL)
      final transaksi = Transaksi(
        idPengguna: idPengguna,
        idKategori: idKategori,
        targetMerchant: va.merchantName,
        targetPengguna: null,
        totalTransaksi: va.totalAmount.toDouble(),
        deskripsi:
            deskripsi.isEmpty ? 'Bayar ${va.merchantName}' : deskripsi,
        metodeTransaksi: 'VA_${va.bankName}',
        status: 'sukses',
        biayaTransfer: biayaTransfer,
        waktuDibuat: DateTime.now(),
      );

      final transaksiId =
          await Transaksi.insertAndReturnId(transaksi);

      if (transaksiId == null) {
        return PaymentResult(
          success: false,
          message: 'Gagal membuat transaksi',
        );
      }

      return PaymentResult(
        success: true,
        message: 'Pembayaran berhasil',
        transactionId: transaksiId,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        message: e.toString(),
      );
    }
  }

  // ================= UI SUPPORT =================
  Future<List<Kategori>> getKategoriDropdown(String idPengguna) {
    return Kategori.findByPengguna(idPengguna);
  }
}

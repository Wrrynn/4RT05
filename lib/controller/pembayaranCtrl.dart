import 'package:artos/model/transaksi.dart';
import 'package:artos/model/kategori.dart';
import 'package:artos/service/db_service.dart';
import 'package:artos/widgets/currency.dart';

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

  Future<String?> processPayment({
    required String vaNumber,
    required String idPengguna,
    required String idKategori,
    required double biayaTransfer,
    required String deskripsi,
  }) async {
    try {
      final va = parseVA(vaNumber);
      if (va == null) return 'VA tidak valid';

      // VALIDASI EXPIRED
      if (va.isExpired()) {
        return 'Transaksi Gagal: Nomor VA sudah kadaluarsa (Expired)';
      }

      final userRes = await DBService.client.from('Pengguna').select('saldo').eq('id_pengguna', idPengguna).maybeSingle();
      if (userRes == null) return 'Pengguna tidak ditemukan';

      final currentSaldo = (userRes['saldo'] as num).toDouble();
      final totalAmount = va.totalAmount + biayaTransfer;

      if (currentSaldo < totalAmount) return 'Saldo tidak cukup';

      final transaksi = Transaksi(
        idPengguna: idPengguna,
        idKategori: idKategori,
        targetMerchant: va.merchantName, // Simpan Nama Merchant ke Database
        targetPengguna: null,
        totalTransaksi: va.totalAmount.toDouble(),
        deskripsi: deskripsi.isEmpty ? 'Bayar ${va.merchantName}' : deskripsi,
        metodeTransaksi: 'VA_${va.bankName}',
        status: 'sukses',
        biayaTransfer: biayaTransfer,
        waktuDibuat: DateTime.now(),
      );

      final insertRes = await DBService.client.from('Transaksi').insert(transaksi.toMap()).select();
      if (insertRes.isEmpty) return 'Gagal membuat transaksi';

      await DBService.client.from('Pengguna').update({'saldo': currentSaldo - totalAmount}).eq('id_pengguna', idPengguna);

      return insertRes[0]['id_transaksi'];
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<List<Kategori>> getKategoriDropdown(String idPengguna) async {
    final res = await DBService.client.from('Kategori').select().eq('id_pengguna', idPengguna).order('nama_kategori');
    return (res as List).map((e) => Kategori.fromMap(e)).toList();
  }

  // Generate VA 15 digit untuk testing
  String generateDummyVA(String bank, String merchant, String amount, String mm, String yy) {
    return "99${bank.padLeft(3, '0')}${merchant.padLeft(2, '0')}${amount.padLeft(4, '0')}${mm.padLeft(2, '0')}${yy.padLeft(2, '0')}";
  }
}
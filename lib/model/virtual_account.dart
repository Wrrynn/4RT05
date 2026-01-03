class VirtualAccount {
  // ================= DOMAIN CONSTANT =================
  static const Map<String, String> bankCodes = {
    '008': 'Mandiri',
    '014': 'BCA',
    '009': 'BNI',
    '002': 'BRI',
  };

  static const Map<String, String> merchantCodes = {
    '01': 'Toko Buah',
    '02': 'Burger Mountain',
    '03': 'Podomoro',
    '04': 'Warung Nasi Bu Yuyun',
    '05': 'Paylater Parhan Nunggak 3 Bulan',
    '06': 'Warung Erpan',
  };

  final String vaCode;
  final String bankCode;
  final String merchantCode;
  final int totalAmount;
  final int expiryMonth;
  final int expiryYear;

  String get bankName => bankCodes[bankCode] ?? 'Unknown';
  String get merchantName => merchantCodes[merchantCode] ?? 'Unknown';

  VirtualAccount({
    required this.vaCode,
    required this.bankCode,
    required this.merchantCode,
    required this.totalAmount,
    required this.expiryMonth,
    required this.expiryYear,
  });

  bool isExpired() {
    final now = DateTime.now();
    final expiryDate =
        DateTime(2000 + expiryYear, expiryMonth + 1, 0, 23, 59);
    return now.isAfter(expiryDate);
  }

  static bool isValidBank(String code) =>
      bankCodes.containsKey(code);

  static bool isValidMerchant(String code) =>
      merchantCodes.containsKey(code);
}

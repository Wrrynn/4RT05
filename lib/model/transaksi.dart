class Transaksi {
  // ====== ATTRIBUTES ======
  final String? idTransaksi;        // id_transaksi (PK - UUID)
  final String idPengguna;         // id_pengguna (FK - pengirim, UUID)
  final String idKategori;         // id_kategori (FK, UUID)

  // untuk penerima/merchant, nullable karena tidak selalu ada
  final String? targetPengguna;     // target_pengguna (FK - penerima, UUID)
  final String? targetMerchant;     // target_merchant (untuk transaksi ke merchant, nullable)

  double totalTransaksi;
  String deskripsi;
  String metodeTransaksi;
  String status;
  double biayaTransfer;
  DateTime waktuDibuat;

  Transaksi({
    this.idTransaksi,
    required this.idPengguna,
    required this.idKategori,
    this.targetPengguna,
    this.targetMerchant,
    required this.totalTransaksi,
    required this.deskripsi,
    required this.metodeTransaksi,
    required this.status,
    required this.biayaTransfer,
    required this.waktuDibuat,
  });

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      idTransaksi: map['id_transaksi']?.toString(),
      idPengguna: map['id_pengguna']?.toString() ?? '',
      idKategori: map['id_kategori']?.toString() ?? '',
      targetPengguna: map['target_pengguna']?.toString(),
      targetMerchant: map['target_merchant']?.toString(), // Ambil dari DB
      totalTransaksi: (map['total_transaksi'] is num)
          ? (map['total_transaksi'] as num).toDouble()
          : (double.tryParse(map['total_transaksi']?.toString() ?? '') ?? 0.0),
      deskripsi: map['deskripsi']?.toString() ?? '',
      metodeTransaksi: map['metode_transaksi']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      biayaTransfer: (map['biaya_transfer'] is num)
          ? (map['biaya_transfer'] as num).toDouble()
          : double.tryParse(map['biaya_transfer']?.toString() ?? '') ?? 0.0,
      waktuDibuat: map['waktu_dibuat'] is String
          ? (DateTime.tryParse(map['waktu_dibuat']) ?? DateTime.now())
          : (map['waktu_dibuat'] is DateTime
              ? map['waktu_dibuat']
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id_pengguna': idPengguna,
      'id_kategori': idKategori,
      'target_pengguna': targetPengguna,
      'target_merchant': targetMerchant, // PASTIKAN INI ADA agar tersimpan di DB
      'total_transaksi': totalTransaksi,
      'deskripsi': deskripsi,
      'metode_transaksi': metodeTransaksi,
      'status': status,
      'biaya_transfer': biayaTransfer,
      'waktu_dibuat': waktuDibuat.toIso8601String(),
    };

    if (idTransaksi != null && idTransaksi!.isNotEmpty) {
      map['id_transaksi'] = idTransaksi;
    }
    return map;
  }

  bool get isIncome {
    final s = status.toLowerCase();
    // Treat both 'success' and 'sukses' as income-like statuses
    if (s == 'success' || s == 'sukses') return true;
    return false;
  }
}


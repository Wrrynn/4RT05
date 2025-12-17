class Transaksi {
  // ====== ATTRIBUTES ======
  final String? idTransaksi;        // id_transaksi (PK - UUID)
  final String idPengguna;         // id_pengguna (FK - pengirim, UUID)
  final String idKategori;         // id_kategori (FK, UUID)
  final String targetPengguna;     // target_pengguna (FK - penerima, UUID)

  double totalTransaksi;        // total_transaksi
  String deskripsi;             // deskripsi
  String metodeTransaksi;       // metode_transaksi
  String status;                // status
  double biayaTransfer;         // biaya_transfer
  DateTime waktuDibuat;         // waktu_dibuat

  // ====== CONSTRUCTOR ======
  Transaksi({
    this.idTransaksi,
    required this.idPengguna,
    required this.idKategori,
    required this.targetPengguna,
    required this.totalTransaksi,
    required this.deskripsi,
    required this.metodeTransaksi,
    required this.status,
    required this.biayaTransfer,
    required this.waktuDibuat,
  });

  // ====== FROM DATABASE ======
  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      idTransaksi: map['id_transaksi']?.toString(),
      idPengguna: map['id_pengguna']?.toString() ?? '',
      idKategori: map['id_kategori']?.toString() ?? '',
      targetPengguna: map['target_pengguna']?.toString() ?? '',
      totalTransaksi: (map['total_transaksi'] is num)
          ? (map['total_transaksi'] as num).toDouble()
          : double.tryParse(map['total_transaksi']?.toString() ?? '') ?? 0.0,
      deskripsi: map['deskripsi']?.toString() ?? '',
      metodeTransaksi: map['metode_transaksi']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      biayaTransfer: (map['biaya_transfer'] is num)
          ? (map['biaya_transfer'] as num).toDouble()
          : double.tryParse(map['biaya_transfer']?.toString() ?? '') ?? 0.0,
      waktuDibuat: map['waktu_dibuat'] is String
          ? DateTime.parse(map['waktu_dibuat'])
          : (map['waktu_dibuat'] is DateTime ? map['waktu_dibuat'] : DateTime.now()),
    );
  }

  // ====== TO DATABASE ======
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id_pengguna': idPengguna,
      'id_kategori': idKategori,
      'target_pengguna': targetPengguna,
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
}

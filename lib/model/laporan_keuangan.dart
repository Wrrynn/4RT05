class ModelLaporan {
  final String? idLaporan; // nullable
  final String idPengguna;
  final String? idKategori;
  final double totalPemasukan;
  final double totalPengeluaran;
  final double totalKontribusi;
  final double totalKategori;
  final String? idTransaksi;
  final String? idTopup;

  ModelLaporan({
    this.idLaporan,
    required this.idPengguna,
    this.idKategori,
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.totalKontribusi,
    required this.totalKategori,
    this.idTransaksi,
    this.idTopup,
  });

  /// UNTUK INSERT
  Map<String, dynamic> toInsertJson() {
    return {
      'id_pengguna': idPengguna,
      'id_kategori': idKategori,
      'total_pemasukan': totalPemasukan,
      'total_pengeluaran': totalPengeluaran,
      'total_kontribusi': totalKontribusi,
      'total_kategori': totalKategori,
      'id_transaksi': idTransaksi,
      'id_topup': idTopup,
    };
  }

  /// DARI DATABASE
  factory ModelLaporan.fromJson(Map<String, dynamic> json) {
    return ModelLaporan(
      idLaporan: json['id_laporan'],
      idPengguna: json['id_pengguna'],
      idKategori: json['id_kategori'],
      totalPemasukan: (json['total_pemasukan'] ?? 0).toDouble(),
      totalPengeluaran: (json['total_pengeluaran'] ?? 0).toDouble(),
      totalKontribusi: (json['total_kontribusi'] ?? 0).toDouble(),
      totalKategori: (json['total_kategori'] ?? 0).toDouble(),
      idTransaksi: json['id_transaksi'],
      idTopup: json['id_topup'],
    );
  }
}
class Riwayat {
  final String idPengguna;
  final String? idTransaksi; 
  final String? idTopUp;     

  Riwayat({
    required this.idPengguna,
    this.idTransaksi,
    this.idTopUp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_pengguna': idPengguna,
      'id_transaksi': idTransaksi,
      'id_topup': idTopUp,
    };
  }

  factory Riwayat.fromJson(Map<String, dynamic> json) {
    return Riwayat(
      idPengguna: json['id_pengguna'] as String,
      idTransaksi: json['id_transaksi'] as String?,
      idTopUp: json['id_topup'] as String?,
    );
  }

  bool get isTransaksi => idTransaksi != null;
  bool get isTopUp => idTopUp != null;
}

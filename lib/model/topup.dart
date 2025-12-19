class Topup {
  final String? idTopUp;
  final String idPenggunaTopup;
  final double jumlah;
  final String metode;
  final String detailMetode;
  final String? orderId;
  final String? redirectUrl;
  final DateTime waktuTopup;
  String status;

  Topup({
    this.idTopUp,
    required this.idPenggunaTopup,
    required this.jumlah,
    required this.metode,
    required this.detailMetode,
    this.orderId,
    this.redirectUrl,
    required this.status,
    DateTime? waktuTopup,
  }) : waktuTopup = waktuTopup ?? DateTime.fromMillisecondsSinceEpoch(0);

  factory Topup.fromMap(Map<String, dynamic> map) {
    DateTime parseTime(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is DateTime) return v;
      if (v is String) {
        return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
      }
      if (v is num) {
        final n = v.toInt();
        return DateTime.fromMillisecondsSinceEpoch(
          n < 1000000000000 ? n * 1000 : n,
        );
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return Topup(
      idTopUp: map['id_topup']?.toString(),
      idPenggunaTopup: map['id_pengguna_topup'].toString(),
      jumlah: (map['jumlah'] is int)
          ? (map['jumlah'] as int).toDouble()
          : double.tryParse(map['jumlah'].toString()) ?? 0.0,
      metode: map['metode']?.toString() ?? '',
      detailMetode: map['detail_metode']?.toString() ?? '',
      orderId: map['order_id']?.toString(),
      redirectUrl: map['payment_code']?.toString(),
      status: map['status']?.toString() ?? 'pending',
      waktuTopup: parseTime(map['waktu_dibuat']), 
    );
  }
}

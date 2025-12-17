class Topup {
  // Kita gunakan String agar aman dari error Supabase BigInt
  final String? idTopUp; 
  
  final String idPenggunaTopup;
  final double jumlah;
  final String metode;
  final String detailMetode;
  final String? orderId;    
  final String? redirectUrl;
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
  });

  factory Topup.fromMap(Map<String, dynamic> map) {
    return Topup(
      // ✅ KUNCI PERBAIKAN: 
      // Apapun tipe data aslinya (int/string), kita paksa jadi String.
      idTopUp: map['id_topup']?.toString(), 
      
      idPenggunaTopup: map['id_pengguna_topup'].toString(),
      
      // Safety untuk jumlah (mengatasi int vs double)
      jumlah: (map['jumlah'] is int) 
          ? (map['jumlah'] as int).toDouble() 
          : double.tryParse(map['jumlah'].toString()) ?? 0.0,
          
      metode: map['metode']?.toString() ?? '',
      detailMetode: map['detail_metode']?.toString() ?? '',
      orderId: map['order_id']?.toString(),
      redirectUrl: map['payment_code']?.toString(),
      status: map['status']?.toString() ?? 'pending',
    );
  }
}
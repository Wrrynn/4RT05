class Kategori {
  // ====== ATTRIBUTES ======
  final String idKategori;        // id_kategori (PK - UUID)
  final String idPengguna;        // id_pengguna (FK - UUID)

  String namaKategori;         // nama_kategori
  String tipeKategori;         // tipe_kategori (pemasukan / pengeluaran)
  double batasPengeluaran;     // batas_pengeluaran
  double totalPengeluaran;     // total_pengeluaran

  // ====== CONSTRUCTOR ======
  Kategori({
    required this.idKategori,
    required this.idPengguna,
    required this.namaKategori,
    required this.tipeKategori,
    required this.batasPengeluaran,
    this.totalPengeluaran = 0,
  });

  // ====== FROM DATABASE (Supabase / SQL) ======
  factory Kategori.fromMap(Map<String, dynamic> map) {
    return Kategori(
      idKategori: map['id_kategori']?.toString() ?? '',
      idPengguna: map['id_pengguna']?.toString() ?? '',
      namaKategori: map['nama_kategori']?.toString() ?? '',
      tipeKategori: map['tipe_kategori']?.toString() ?? '',
      batasPengeluaran: (map['batas_pengeluaran'] is num)
          ? (map['batas_pengeluaran'] as num).toDouble()
          : double.tryParse(map['batas_pengeluaran']?.toString() ?? '') ?? 0.0,
      totalPengeluaran: (map['total_pengeluaran'] is num)
          ? (map['total_pengeluaran'] as num).toDouble()
          : double.tryParse(map['total_pengeluaran']?.toString() ?? '') ?? 0.0,
    );
  }

  // ====== TO DATABASE ======
  Map<String, dynamic> toMap() {
    return {
      'id_kategori': idKategori,
      'id_pengguna': idPengguna,
      'nama_kategori': namaKategori,
      'tipe_kategori': tipeKategori,
      'batas_pengeluaran': batasPengeluaran,
      'total_pengeluaran': totalPengeluaran,
    };
  }

  // ====== BUSINESS LOGIC ======

  /// Tambah pengeluaran ke kategori
  void tambahPengeluaran(double nominal) {
    totalPengeluaran += nominal;
  }

  /// Cek apakah pengeluaran melebihi batas
  bool melebihiBatas() {
    return totalPengeluaran > batasPengeluaran;
  }

  /// Sisa batas pengeluaran
  double sisaBatas() {
    return batasPengeluaran - totalPengeluaran;
  }
}

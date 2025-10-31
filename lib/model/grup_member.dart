class GrupMember {
  // private attribute
  final int _idMember;
  final int _idGrup;
  final int _idPengguna;
  double _jumlahKontribusi;

  // Constructor
  GrupMember({
    required int idMember,
    required int idGrup,
    required int idPengguna,
    double jumlahKontribusi = 0,
  })  : _idMember = idMember,
        _idGrup = idGrup,
        _idPengguna = idPengguna,
        _jumlahKontribusi = jumlahKontribusi;

  //  Getter dan Setter
  int get idMember => _idMember;

  int get idGrup => _idGrup;

  int get idPengguna => _idPengguna;

  double get jumlahKontribusi => _jumlahKontribusi;
  set jumlahKontribusi(double value) => _jumlahKontribusi = value;

  // Method 
  void tambahKontribusi(double jumlah) {
    if (jumlah > 0) {
      _jumlahKontribusi += jumlah;
      print("Kontribusi sebesar Rp${jumlah.toStringAsFixed(2)} berhasil ditambahkan.");
    } else {
      print("Jumlah kontribusi harus lebih dari 0!");
    }
  }

  void keluarGrup() {
    print("Member dengan ID $_idMember telah keluar dari grup $_idGrup.");
    // Logika tambahan bisa ditambahkan di sini, misalnya:
    // - Menghapus data member dari database
    // - Memperbarui total saldo grup
  }

  // 🧾 Opsional: Tampilkan info member
  String getInformasiMember() {
    return '''
👤 Informasi Grup Member:
- ID Member: $_idMember
- ID Grup: $_idGrup
- ID Pengguna: $_idPengguna
- Total Kontribusi: Rp${_jumlahKontribusi.toStringAsFixed(2)}
''';
  }
}

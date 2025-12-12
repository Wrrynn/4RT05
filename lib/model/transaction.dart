class Transaksi {
  final String judul;
  final String kategori;
  final String tanggalLabel; // contoh: "Kemarin" / "28 Okt 2005"
  final String jam;          // "14.30"
  final int nominal;         // 500000
  final bool isIncome;

  // detail receipt
  final String metode;       // "Qris"
  final int biaya;           // 0
  final String idTransaksi;  // "#123456789"
  final String dariNama;     // "User123"
  final String dariId;       // "ID 001212"
  final String keNama;       // "Warung Naspad123";

  const Transaksi({
    required this.judul,
    required this.kategori,
    required this.tanggalLabel,
    required this.jam,
    required this.nominal,
    required this.isIncome,
    required this.metode,
    required this.biaya,
    required this.idTransaksi,
    required this.dariNama,
    required this.dariId,
    required this.keNama,
  });
}

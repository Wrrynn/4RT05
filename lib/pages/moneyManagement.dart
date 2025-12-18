import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';

class ManajemenKeuanganPage extends StatefulWidget {
  const ManajemenKeuanganPage({super.key});

  @override
  State<ManajemenKeuanganPage> createState() => _ManajemenKeuanganPageState();
}

class _ManajemenKeuanganPageState extends State<ManajemenKeuanganPage> {
  // ===== Dummy state kategori (nanti bisa diganti dari DB) =====
  final List<_KategoriItem> _items = [
    _KategoriItem(nama: "Makan dan Minuman", batas: 100000, terpakai: 50000),
    _KategoriItem(nama: "Belanja", batas: 100000, terpakai: 20000),
  ];

  // controllers untuk popup
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _batasCtrl = TextEditingController();

  @override
  void dispose() {
    _namaCtrl.dispose();
    _batasCtrl.dispose();
    super.dispose();
  }

  // ---------------- APPBAR ----------------
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: const Text(
              "Manajemen Keuangan",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- UI MAIN ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: BackgroundApp(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTotalDanaCard(),
                        const SizedBox(height: 24),
                        const Text(
                          "Akun",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAccountCard(name: "Akun Utama", amount: "Rp. 000000"),
                        const SizedBox(height: 10),
                        _buildAccountCard(name: "Bank", amount: "Rp. 000000"),
                        const SizedBox(height: 24),

                        _buildAnggaranHeader(),
                        const SizedBox(height: 12),

                        // ===== list kategori =====
                        if (_items.isEmpty)
                          GlassContainer(
                            width: double.infinity,
                            height: 90,
                            borderRadius: BorderRadius.circular(18),
                            padding: const EdgeInsets.all(16),
                            child: const Center(
                              child: Text(
                                "Belum ada kategori.\nTekan tombol + untuk menambah.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          )
                        else
                          ..._items.map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildBudgetCard(item: e),
                              )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildBottomButtons(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- TOTAL DANA ----------------
  Widget _buildTotalDanaCard() {
    return GlassContainer(
      width: double.infinity,
      height: 140,
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF4B2CCB),
          Color(0xFF9C22CF),
        ],
      ),
      borderColor: Colors.white.withOpacity(0.18),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Dana",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Rp. 000000",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "+ 10.5% dari bulan terakhir",
            style: TextStyle(
              color: Color(0xFF28D17C),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- AKUN CARD ----------------
  Widget _buildAccountCard({required String name, required String amount}) {
    return GlassContainer(
      width: double.infinity,
      height: 80,
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF4B146D).withOpacity(0.55),
          const Color(0xFF120526).withOpacity(0.85),
        ],
      ),
      borderColor: Colors.white.withOpacity(0.15),
      child: Row(
        children: [
          GlassContainer(
            width: 42,
            height: 42,
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.02),
              ],
            ),
            borderColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- ANGGRAN HEADER (+) ----------------
  Widget _buildAnggaranHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Anggaran Perkategori",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GestureDetector(
          onTap: _showTambahKategoriSheet,
          child: GlassContainer(
            width: 34,
            height: 34,
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF6339A),
                Color(0xFFAC00FF),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- BUDGET CARD ----------------
  Widget _buildBudgetCard({required _KategoriItem item}) {
    final progress = item.batas <= 0 ? 0.0 : (item.terpakai / item.batas).clamp(0.0, 1.0);

    return GlassContainer(
      width: double.infinity,
      height: 110,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF4B146D).withOpacity(0.7),
          const Color(0xFF1E062D).withOpacity(0.9),
        ],
      ),
      borderColor: Colors.white.withOpacity(0.15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Rp. ${item.terpakai} dari Rp. ${item.batas}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(0.12),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF6339A), Color(0xFFAC00FF)],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // buttons edit/delete
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _showEditKategoriSheet(item),
                child: GlassContainer(
                  width: 32,
                  height: 32,
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withOpacity(0.15),
                      Colors.orange.withOpacity(0.05),
                    ],
                  ),
                  borderColor: Colors.orange.withOpacity(0.2),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.orangeAccent,
                    size: 16,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showHapusKategoriDialog(item),
                child: GlassContainer(
                  width: 32,
                  height: 32,
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.15),
                      Colors.red.withOpacity(0.05),
                    ],
                  ),
                  borderColor: Colors.red.withOpacity(0.2),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- BOTTOM BUTTONS ----------------
  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/moneyReport'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAC00FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Lihat Laporan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // ======================= POPUPS ==========================
  // =========================================================

  void _showTambahKategoriSheet() {
    _namaCtrl.clear();
    _batasCtrl.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _roundedSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _backCircle(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 10),
                  const Text(
                    "Tambah Kategori",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _glassInput(label: "Nama Kategori", controller: _namaCtrl, hint: "Masukkan nama Kategori"),
              const SizedBox(height: 14),
              _glassInput(
                label: "Batas Pengeluaran",
                controller: _batasCtrl,
                hint: "Masukkan Batas Pengeluaran",
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: _pillButton(
                  text: "Tambah",
                  onTap: () {
                    final nama = _namaCtrl.text.trim();
                    final batas = int.tryParse(_batasCtrl.text.trim()) ?? 0;

                    if (nama.isEmpty || batas <= 0) {
                      _toast("Nama dan batas harus diisi.");
                      return;
                    }

                    setState(() {
                      _items.add(_KategoriItem(nama: nama, batas: batas, terpakai: 0));
                    });

                    Navigator.pop(context);
                    _toast("Kategori ditambah");
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditKategoriSheet(_KategoriItem item) {
    _namaCtrl.text = item.nama;
    _batasCtrl.text = item.batas.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _roundedSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _backCircle(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 10),
                  const Text(
                    "Edit Kategori",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _glassInput(label: "Nama Kategori", controller: _namaCtrl, hint: "nama Kategori"),
              const SizedBox(height: 14),
              _glassInput(
                label: "Batas Pengeluaran",
                controller: _batasCtrl,
                hint: "Batas Pengeluaran",
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: _pillButton(
                  text: "Ubah",
                  onTap: () {
                    final nama = _namaCtrl.text.trim();
                    final batas = int.tryParse(_batasCtrl.text.trim()) ?? 0;

                    if (nama.isEmpty || batas <= 0) {
                      _toast("Nama dan batas harus diisi.");
                      return;
                    }

                    setState(() {
                      item.nama = nama;
                      item.batas = batas;
                      if (item.terpakai > item.batas) item.terpakai = item.batas; // biar aman
                    });

                    Navigator.pop(context);
                    _toast("Kategori diubah");
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHapusKategoriDialog(_KategoriItem item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassContainer(
            width: double.infinity,
            height: 170,
            borderRadius: BorderRadius.circular(18),
            padding: const EdgeInsets.all(18),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A0630).withOpacity(0.95),
                const Color(0xFF240743).withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderColor: Colors.white.withOpacity(0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _backCircle(onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Anda Yakin Menghapus\nKategori Secara Permanen?",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _outlinePillButton(
                        text: "Ya",
                        onTap: () {
                          setState(() => _items.remove(item));
                          Navigator.pop(context);
                          _toast("Kategori dihapus");
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _pillButton(
                        text: "Tidak",
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // ======================= HELPERS =========================
  // =========================================================

  Widget _roundedSheet({required Widget child}) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0630),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: child,
      ),
    );
  }

  Widget _backCircle({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.12),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Colors.white),
      ),
    );
  }

  Widget _glassInput({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GlassContainer(
          width: double.infinity,
          height: 52,
          borderRadius: BorderRadius.circular(14),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.02)],
          ),
          borderColor: Colors.white.withOpacity(0.18),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pillButton({required String text, required VoidCallback onTap}) {
    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B2BFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _outlinePillButton({required String text, required VoidCallback onTap}) {
    return SizedBox(
      height: 38,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withOpacity(0.25)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ===== Model dummy lokal untuk kategori =====
class _KategoriItem {
  String nama;
  int batas;
  int terpakai;

  _KategoriItem({
    required this.nama,
    required this.batas,
    required this.terpakai,
  });
}

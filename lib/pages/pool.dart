import 'package:flutter/material.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';
import 'package:artos/controller/poolCtrl.dart';
import 'package:artos/model/pengguna.dart';
import 'package:artos/pages/homePage.dart';
import 'package:artos/model/grup.dart';
import 'package:artos/service/db_service.dart';
import 'package:artos/widgets/currency.dart';

class PoolPage extends StatefulWidget {
  const PoolPage({super.key});

  @override
  State<PoolPage> createState() => _PoolPageState();
}

class _PoolPageState extends State<PoolPage> {
  final PoolController _ctrl = PoolController();

  final _namaCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _durasiCtrl = TextEditingController();

  final _nominalTambahCtrl = TextEditingController();
  final _nominalTarikCtrl = TextEditingController();

  // Pengaturan grup
  final _targetBaruCtrl = TextEditingController();
  final _durasiBaruCtrl = TextEditingController();

  // Invite
  final _rekeningInviteCtrl = TextEditingController();
  final _teleponInviteCtrl = TextEditingController();

  List<Grup> _groups = [];
  bool _loading = true;

  // cache kontribusi user per grup
  final Map<String, int> _myContribByGroup = {};
  int _totalKontribusiSaya = 0;

  String get _uid => DBService.client.auth.currentUser?.id ?? "";

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _targetCtrl.dispose();
    _durasiCtrl.dispose();
    _nominalTambahCtrl.dispose();
    _nominalTarikCtrl.dispose();
    _targetBaruCtrl.dispose();
    _durasiBaruCtrl.dispose();
    _rekeningInviteCtrl.dispose();
    _teleponInviteCtrl.dispose();
    super.dispose();
  }

  String _shortId(String id, {int take = 6}) {
    if (id.isEmpty) return "-";
    return id.length <= take ? id : id.substring(0, take);
  }

  Future<void> _loadGroups() async {
    setState(() => _loading = true);

    if (_uid.isEmpty) {
      setState(() {
        _groups = [];
        _myContribByGroup.clear();
        _totalKontribusiSaya = 0;
        _loading = false;
      });
      return;
    }

    final data = await _ctrl.getMyGroups(idPengguna: _uid);

    final Map<String, int> contribMap = {};
    int total = 0;

    for (final g in data) {
      final c = await _ctrl.getMyContribution(idGrup: g.idGrup, idPengguna: _uid);
      contribMap[g.idGrup] = c;
      total += c;
    }

    setState(() {
      _groups = data;
      _myContribByGroup
        ..clear()
        ..addAll(contribMap);
      _totalKontribusiSaya = total;
      _loading = false;
    });
  }

  Future<void> _goToHomepage() async {
    final uid = DBService.client.auth.currentUser?.id;
    if (uid == null) {
      _toast('Belum login');
      return;
    }

    try {
      final res = await DBService.client.from('Pengguna').select().eq('id_pengguna', uid).single();
      final pengguna = Pengguna.fromJson(res);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Homepage(pengguna: pengguna)),
      );
    } catch (_) {
      _toast('Gagal memuat data pengguna');
    }
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: _goToHomepage,
        ),
        centerTitle: true,
        title: const Text(
          "Pool",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 26,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.pinkAccent),
            onPressed: _showBuatGrupSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BackgroundApp(child: SafeArea(child: _buildPoolContent())),
    );
  }

  Widget _buildPoolContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTotalKontribusiCard(),
                const SizedBox(height: 24),
                const Text(
                  "Grup",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_groups.isEmpty)
                  GlassContainer(
                    width: double.infinity,
                    height: 90,
                    borderRadius: BorderRadius.circular(18),
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: Text(
                        "Belum ada grup.\nTekan tombol + untuk membuat grup.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                else
                  ..._groups.map((g) {
                    final progress = (g.target <= 0) ? 0.0 : (g.totalSaldo / g.target);
                    final progressClamped = progress.clamp(0.0, 1.0);

                    final myContrib = _myContribByGroup[g.idGrup] ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildGroupCard(
                        grup: g,
                        myContrib: myContrib,
                        progress: progressClamped,
                        progressText: "${(progressClamped * 100).toStringAsFixed(0)}% Terkumpul",
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalKontribusiCard() {
    return GlassContainer(
      width: double.infinity,
      height: 130,
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7C1CF5), Color(0xFFBF2BD4)],
      ),
      borderColor: Colors.white.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Kontribusi Anda",
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency(_totalKontribusiSaya),
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            "Kumpulkan Uang Bersama Secara Pribadi",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard({
    required Grup grup,
    required int myContrib,
    required double progress,
    required String progressText,
  }) {
    final totalTerkumpul = "${formatCurrency(grup.totalSaldo)}/${formatCurrency(grup.target)}";

    return GestureDetector(
      onTap: () => _showGroupInfoSheet(grup: grup),
      child: GlassContainer(
        width: double.infinity,
        height: 230,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A0630).withOpacity(0.9),
            const Color(0xFF240743).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Colors.white.withOpacity(0.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    grup.namaGrup,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                _smallPillButton(label: "Tarik", onTap: () => _showTarikDanaSheet(grup)),
                const SizedBox(width: 8),
                _smallPillButton(label: "Tambah", onTap: () => _showTambahDanaSheet(grup)),
              ],
            ),
            const SizedBox(height: 4),
            Text("Durasi: ${grup.durasi}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 2),
            Text("ID ${_shortId(grup.idGrup)}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Terkumpul", style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(
                  totalTerkumpul,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 8,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFFFF4EC7), Color(0xFF7B3DFF)]),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            Row(
              children: [
                SizedBox(
                  height: 32,
                  child: Stack(
                    children: [
                      _circleAvatar(),
                      Positioned(left: 18, child: _circleAvatar()),
                      Positioned(left: 36, child: _circleAvatar()),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _showGroupInfoSheet(grup: grup),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4EC7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Selengkapnya",
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const Spacer(),
                Text(progressText, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),

            const Spacer(),
            const Divider(color: Colors.white24, height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.attach_money_rounded, color: Colors.pinkAccent, size: 20),
                    SizedBox(width: 4),
                    Text("Kontribusi Anda", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                Text(
                  formatCurrency(myContrib),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallPillButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFFFF4EC7), borderRadius: BorderRadius.circular(20)),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _circleAvatar() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withOpacity(0.5), width: 2),
        image: const DecorationImage(image: AssetImage('assets/images/21.png'), fit: BoxFit.cover),
      ),
    );
  }

  // ================== POPUP / BOTTOM SHEETS ==================

  void _showGroupInfoSheet({required Grup grup}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _roundedSheet(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _ctrl.getGroupMembers(idGrup: grup.idGrup),
            builder: (context, snap) {
              final members = snap.data ?? [];

              return FutureBuilder<bool>(
                future: _ctrl.isOwner(idGrup: grup.idGrup, idPengguna: _uid),
                builder: (context, ownerSnap) {
                  final isOwner = ownerSnap.data ?? false;
                  final memberCount = members.length;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Info Grup ${grup.namaGrup}",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),

                      if (snap.connectionState == ConnectionState.waiting)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        )
                      else if (members.isEmpty)
                        const Text("Belum ada member.", style: TextStyle(color: Colors.white70))
                      else
                        ...members.map((m) {
                          final pengguna = m['Pengguna'] as Map<String, dynamic>?;
                          final nama = (pengguna?['nama_lengkap'] ?? '-') as String;
                          final rekening = (pengguna?['rekening'] ?? '-')?.toString() ?? '-';
                          final kontribusi = (m['jumlah_kontribusi'] as num?)?.toInt() ?? 0;

                          return _memberRow(
                            name: nama,
                            id: rekening,
                            amount: formatCurrency(kontribusi),
                          );
                        }),

                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Target:", style: TextStyle(color: Colors.white70, fontSize: 13)),
                              Text(
                                formatCurrency(grup.target),
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text("Durasi: ${grup.durasi}", style: const TextStyle(color: Colors.white60, fontSize: 12)),
                            ],
                          ),
                          Column(
                            children: [
                              _smallPillButton(
                                label: "Undang",
                                onTap: () {
                                  Navigator.pop(context);
                                  _showInviteSheet(grup);
                                },
                              ),
                              const SizedBox(height: 8),
                              _smallPillButton(
                                label: "Pengaturan",
                                onTap: () {
                                  Navigator.pop(context);
                                  _showPengaturanGrupSheet(grup);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4EC7),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () async {
                            // ✅ Owner boleh keluar kalau cuma dia sendiri (anggota lain = 0) -> grup dihapus
                            // Artinya total member = 1 (owner doang)
                            if (isOwner && memberCount <= 1) {
                              final err = await _ctrl.deleteGroupIfOwnerAlone(
                                idGrup: grup.idGrup,
                                idOwner: _uid,
                              );
                              if (!mounted) return;
                              Navigator.pop(context);

                              if (err != null) {
                                _toast(err);
                              } else {
                                _toast("Grup berhasil dihapus");
                                _loadGroups();
                              }
                              return;
                            }

                            // normal leave
                            final err = await _ctrl.leaveGroup(idGrup: grup.idGrup, idPengguna: _uid);
                            if (!mounted) return;
                            Navigator.pop(context);

                            if (err != null) {
                              _toast(err);
                            } else {
                              _toast("Berhasil keluar grup");
                              _loadGroups();
                            }
                          },
                          child: Text(
                            (isOwner && memberCount <= 1) ? "Hapus Grup" : "Keluar Grup",
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showInviteSheet(Grup grup) {
    _rekeningInviteCtrl.clear();
    _teleponInviteCtrl.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _roundedSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Undang Anggota", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _glassTextFieldController(controller: _rekeningInviteCtrl, hint: "Rekening"),
              const SizedBox(height: 12),
              _glassTextFieldController(controller: _teleponInviteCtrl, hint: "Telepon", keyboardType: TextInputType.phone),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    final rek = _rekeningInviteCtrl.text.trim();
                    final tel = _teleponInviteCtrl.text.trim();

                    final err = await _ctrl.inviteMember(
                      idGrup: grup.idGrup,
                      rekening: rek.isEmpty ? null : rek,
                      telepon: tel.isEmpty ? null : tel,
                    );

                    if (!mounted) return;
                    Navigator.pop(context);

                    if (err != null) {
                      _toast(err);
                    } else {
                      _toast("Berhasil mengundang anggota");
                      _loadGroups();
                    }
                  },
                  child: const Text("Undang"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPengaturanGrupSheet(Grup grup) {
    _targetBaruCtrl.text = grup.target.toStringAsFixed(0);
    _durasiBaruCtrl.text = grup.durasi;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _roundedSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Pengaturan Grup", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _glassTextFieldController(controller: _targetBaruCtrl, hint: "Target Baru (angka)", keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _glassTextFieldController(controller: _durasiBaruCtrl, hint: "Durasi Baru (contoh: 6 bulan)"),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    final t = double.tryParse(_targetBaruCtrl.text.trim());
                    final d = _durasiBaruCtrl.text.trim();

                    final err = await _ctrl.updateGroupSettings(
                      idGrup: grup.idGrup,
                      targetBaru: t,
                      durasiBaru: d,
                    );

                    if (!mounted) return;
                    Navigator.pop(context);

                    if (err != null) {
                      _toast(err);
                    } else {
                      _toast("Pengaturan grup tersimpan");
                      _loadGroups();
                    }
                  },
                  child: const Text("Simpan"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTambahDanaSheet(Grup grup) {
    _nominalTambahCtrl.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _roundedSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tambah Dana", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _glassTextFieldController(controller: _nominalTambahCtrl, hint: "Masukkan Nominal", keyboardType: TextInputType.number),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    final jumlah = int.tryParse(_nominalTambahCtrl.text.trim()) ?? 0;

                    final err = await _ctrl.addContribution(
                      idGrup: grup.idGrup,
                      idPengguna: _uid,
                      jumlah: jumlah,
                    );

                    if (!mounted) return;
                    Navigator.pop(context);

                    if (err != null) {
                      _toast(err);
                    } else {
                      _toast("Berhasil tambah dana");
                      _loadGroups();
                    }
                  },
                  child: const Text("Tambah"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTarikDanaSheet(Grup grup) {
    _nominalTarikCtrl.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _roundedSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tarik Dana", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _glassTextFieldController(controller: _nominalTarikCtrl, hint: "Masukkan Nominal", keyboardType: TextInputType.number),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    final jumlah = int.tryParse(_nominalTarikCtrl.text.trim()) ?? 0;

                    final err = await _ctrl.withdraw(
                      idGrup: grup.idGrup,
                      idPengguna: _uid,
                      jumlah: jumlah,
                    );

                    if (!mounted) return;
                    Navigator.pop(context);

                    if (err != null) {
                      _toast(err);
                    } else {
                      _toast("Berhasil tarik dana");
                      _loadGroups();
                    }
                  },
                  child: const Text("Tarik"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBuatGrupSheet() {
    _namaCtrl.clear();
    _targetCtrl.clear();
    _durasiCtrl.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _roundedSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Buat Grup", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _glassTextFieldController(controller: _namaCtrl, hint: "Nama Grup"),
              const SizedBox(height: 12),
              _glassTextFieldController(controller: _targetCtrl, hint: "Target (angka)", keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _glassTextFieldController(controller: _durasiCtrl, hint: "Durasi (contoh: 6 bulan)"),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    final nama = _namaCtrl.text.trim();
                    final target = double.tryParse(_targetCtrl.text.trim()) ?? 0.0;
                    final durasi = _durasiCtrl.text.trim();

                    if (nama.isEmpty || target <= 0 || durasi.isEmpty) {
                      _toast("Lengkapi data grup dulu ya.");
                      return;
                    }

                    try {
                      await _ctrl.createGroup(
                        namaGrup: nama,
                        // password DIHAPUS dari UI (controller juga harus stop validasi password)
                        // passwordGrup: "",
                        target: target,
                        durasi: durasi,
                      );

                      if (!mounted) return;
                      Navigator.pop(context);
                      _toast("Grup berhasil dibuat");
                      _loadGroups();
                    } catch (e) {
                      _toast(e.toString());
                    }
                  },
                  child: const Text("Buat Grup", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= Helpers =================

  Widget _roundedSheet({required Widget child}) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0630),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: child,
      ),
    );
  }

  Widget _glassTextFieldController({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return GlassContainer(
      width: double.infinity,
      height: 55,
      borderRadius: BorderRadius.circular(14),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      gradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.04), Colors.white.withOpacity(0.01)],
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
            hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _memberRow({required String name, required String id, required String amount}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _circleAvatar(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(id, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(color: Colors.pinkAccent, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

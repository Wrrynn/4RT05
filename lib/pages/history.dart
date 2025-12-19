import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:artos/widgets/bgPurple.dart';
import 'package:artos/widgets/glass.dart';
import 'package:artos/pages/homePage.dart';
import 'package:artos/model/pengguna.dart';
import 'package:artos/service/db_service.dart';
import 'package:artos/controller/historyCtrl.dart';
import 'bukti.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryController _ctrl = HistoryController();
  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = true;
  String _uid = "";

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _uid = DBService.client.auth.currentUser?.id ?? "";
    _load();
    _searchCtrl.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applySearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    if (_uid.isEmpty) {
      setState(() {
        _items = [];
        _filtered = [];
        _loading = false;
      });
      return;
    }

    final data = await _ctrl.getHistory(_uid);

    setState(() {
      _items = data;
      _filtered = data;
      _loading = false;
    });
  }

  void _applySearch() {
    final q = _searchCtrl.text.trim().toLowerCase();

    if (q.isEmpty) {
      setState(() => _filtered = List.from(_items));
      return;
    }

    setState(() {
      _filtered = _items.where((item) {
        final title = (item['title'] ?? '').toString().toLowerCase();
        final subtitle = (item['subtitle'] ?? '').toString().toLowerCase();
        final amount = (item['amount'] ?? '').toString().toLowerCase();
        final type = (item['type'] ?? '').toString().toLowerCase();
        return title.contains(q) ||
            subtitle.contains(q) ||
            amount.contains(q) ||
            type.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBar(context),
      body: BackgroundApp(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _searchBar(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text(
                      "Semua Riwayat",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(child: _buildList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => _goToHomepage(context),
            ),
            title: const Text(
              "Riwayat Transaksi",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            actions: const [
              Icon(Icons.filter_alt_rounded, color: Colors.white),
              SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return GlassContainer(
      width: double.infinity,
      height: 54,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white54),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Cari transaksi / top up",
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchCtrl,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  FocusScope.of(context).unfocus();
                },
                child: const Icon(Icons.close, color: Colors.white54),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filtered.isEmpty) {
      return GlassContainer(
        width: double.infinity,
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.all(18),
        child: const Center(
          child: Text(
            "Belum ada riwayat.\nCoba lakukan transaksi atau top up.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _filtered[index];
        return _riwayatItem(
          context,
          title: item['title']?.toString() ?? '-',
          subtitle: item['subtitle']?.toString() ?? '',
          amount: item['amount']?.toString() ?? '',
          isIncome: (item['isIncome'] as bool?) ?? false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BuktiPembayaranPage(data: item)),
            );
          },
        );
      },
    );
  }

  Widget _riwayatItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String amount,
    required bool isIncome,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        width: double.infinity,
        height: 80,
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                color: isIncome ? Colors.greenAccent : Colors.pinkAccent,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToHomepage(BuildContext context) async {
    final uid = DBService.client.auth.currentUser?.id;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum login')),
      );
      return;
    }

    try {
      final res = await DBService.client
          .from('Pengguna')
          .select()
          .eq('id_pengguna', uid)
          .single();

      final pengguna = Pengguna.fromJson(res);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Homepage(pengguna: pengguna)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data pengguna: $e')),
      );
    }
  }
}

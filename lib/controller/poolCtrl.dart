import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:artos/service/db_service.dart';
import 'package:artos/model/grup.dart';
import 'package:artos/model/grup_member.dart';

class PoolController {
  final SupabaseClient _db = DBService.client;

  String? get _uid => _db.auth.currentUser?.id;

  String _err(dynamic e) {
    if (e is PostgrestException) return e.message;
    return e.toString();
  }

  // ============================================================
  // CREATE GROUP (insert grup + auto join owner)
  // ============================================================
  Future<Grup> createGroup({
    required String namaGrup,
    required String passwordGrup,
    required double target,
    required String durasi,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception("User belum login");
    if (namaGrup.trim().isEmpty)
      throw Exception("Nama grup tidak boleh kosong");
    if (passwordGrup.trim().isEmpty)
      throw Exception("Password grup tidak boleh kosong");
    if (target <= 0) throw Exception("Target harus lebih dari 0");
    if (durasi.trim().isEmpty) throw Exception("Durasi tidak boleh kosong");

    try {
      final grupDraft = Grup(
        idGrup: 'TEMP',
        namaGrup: namaGrup.trim(),
        passwordGrup: passwordGrup.trim(),
        target: target,
        durasi: durasi.trim(),
        totalSaldo: 0,
        dibuatOleh: uid,
      );

      final grupRow = await _db
          .from('Grup')
          .insert(grupDraft.toInsertJson())
          .select('*')
          .single();

      final grup = Grup.fromJson(grupRow);

      final ownerDraft = GrupMember(
        idMember: 'TEMP',
        idGrup: grup.idGrup,
        idPengguna: uid,
        jumlahKontribusi: 0,
        role: 'owner',
      );

      await _db.from('Grup Member').insert(ownerDraft.toInsertJson());
      return grup;
    } catch (e) {
      throw Exception("Database error: ${_err(e)}");
    }
  }

  // ============================================================
  // GET MY GROUPS
  // ============================================================
  Future<List<Grup>> getMyGroups({required String idPengguna}) async {
    try {
      final res = await _db
          .from('Grup Member')
          .select('grup:Grup(*)')
          .eq('id_pengguna', idPengguna);

      return (res as List)
          .map((row) => Grup.fromJson(row['grup'] as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // GET MEMBERS OF GROUP
  // ============================================================
  Future<List<Map<String, dynamic>>> getGroupMembers({
  required String idGrup,
}) async {
  try {
    final res = await _db
        .from('Grup Member')
        .select('''
          jumlah_kontribusi,
          Pengguna (
            nama_lengkap,
            rekening
          )
        ''')
        .eq('id_grup', idGrup)
        .order('jumlah_kontribusi', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  } catch (_) {
    return [];
  }
}


  // ============================================================
  // JOIN GROUP
  // ============================================================
  Future<String?> joinGroup({
    required String idGrup,
    required String idPengguna,
    String? password,
  }) async {
    try {
      // sudah join?
      final exists = await _db
          .from('Grup Member')
          .select('id_member')
          .eq('id_grup', idGrup)
          .eq('id_pengguna', idPengguna)
          .maybeSingle();

      if (exists != null) return null;

      // cek password kalau diberikan
      if (password != null) {
        final g = await _db
            .from('Grup')
            .select('password_grup')
            .eq('id_grup', idGrup)
            .single();

        final passDB = (g['password_grup'] ?? '') as String;
        if (passDB != password) return "Password grup salah";
      }

      final memberDraft = GrupMember(
        idMember: 'TEMP',
        idGrup: idGrup,
        idPengguna: idPengguna,
        jumlahKontribusi: 0,
        role: 'member',
      );

      await _db.from('Grup Member').insert(memberDraft.toInsertJson());
      return null;
    } catch (e) {
      return _err(e);
    }
  }

  // ============================================================
  // GET MY CONTRIBUTION IN A GROUP
  // ============================================================
  Future<int> getMyContribution({
    required String idGrup,
    required String idPengguna,
  }) async {
    try {
      final row = await _db
          .from('Grup Member')
          .select('jumlah_kontribusi')
          .eq('id_grup', idGrup)
          .eq('id_pengguna', idPengguna)
          .single();

      return (row['jumlah_kontribusi'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ============================================================
  // ADD CONTRIBUTION
  // ============================================================
  Future<String?> addContribution({
    required String idGrup,
    required String idPengguna,
    required int jumlah,
  }) async {
    if (jumlah <= 0) return "Nominal harus lebih dari 0";

    try {
      // 1) Ambil saldo pengguna
      final userRow = await _db
          .from('Pengguna')
          .select('saldo')
          .eq('id_pengguna', idPengguna)
          .single();

      final saldoUser = (userRow['saldo'] as num?)?.toDouble() ?? 0.0;
      if (saldoUser < jumlah) return "Saldo kamu tidak cukup";

      // 2) Ambil data member
      final memberRow = await _db
          .from('Grup Member')
          .select('id_member, jumlah_kontribusi')
          .eq('id_grup', idGrup)
          .eq('id_pengguna', idPengguna)
          .single();

      final idMember = memberRow['id_member'] as String;
      final kontribusi = (memberRow['jumlah_kontribusi'] as num?)?.toInt() ?? 0;

      // 3) Ambil saldo grup
      final grupRow = await _db
          .from('Grup')
          .select('total_saldo')
          .eq('id_grup', idGrup)
          .single();

      final saldoGrup = (grupRow['total_saldo'] as num?)?.toDouble() ?? 0.0;

      // =============================
      // UPDATE DATA
      // =============================

      // A) Kurangi saldo pengguna
      await _db
          .from('Pengguna')
          .update({'saldo': saldoUser - jumlah})
          .eq('id_pengguna', idPengguna);

      // B) Tambah kontribusi member
      await _db
          .from('Grup Member')
          .update({'jumlah_kontribusi': kontribusi + jumlah})
          .eq('id_member', idMember);

      // C) Tambah saldo grup
      await _db
          .from('Grup')
          .update({'total_saldo': saldoGrup + jumlah})
          .eq('id_grup', idGrup);

      return null;
    } catch (e) {
      return _err(e);
    }
  }

  // ============================================================
  // WITHDRAW (personal, max kontribusi sendiri)
  // ============================================================
  Future<String?> withdraw({
    required String idGrup,
    required String idPengguna,
    required int jumlah,
  }) async {
    if (jumlah <= 0) return "Nominal harus lebih dari 0";

    try {
      // 1) Ambil saldo pengguna
      final userRow = await _db
          .from('Pengguna')
          .select('saldo')
          .eq('id_pengguna', idPengguna)
          .single();

      final saldoUser = (userRow['saldo'] as num?)?.toDouble() ?? 0.0;

      // 2) Ambil kontribusi member
      final memberRow = await _db
          .from('Grup Member')
          .select('id_member, jumlah_kontribusi')
          .eq('id_grup', idGrup)
          .eq('id_pengguna', idPengguna)
          .single();

      final idMember = memberRow['id_member'] as String;
      final kontribusi = (memberRow['jumlah_kontribusi'] as num?)?.toInt() ?? 0;

      if (jumlah > kontribusi) {
        return "Saldo tabungan kamu tidak cukup";
      }

      // 3) Ambil saldo grup
      final grupRow = await _db
          .from('Grup')
          .select('total_saldo')
          .eq('id_grup', idGrup)
          .single();

      final saldoGrup = (grupRow['total_saldo'] as num?)?.toDouble() ?? 0.0;

      if (jumlah > saldoGrup) {
        return "Saldo grup tidak cukup";
      }

      // =============================
      // UPDATE DATA
      // =============================

      // A) Kurangi kontribusi member
      await _db
          .from('Grup Member')
          .update({'jumlah_kontribusi': kontribusi - jumlah})
          .eq('id_member', idMember);

      // B) Kurangi saldo grup
      await _db
          .from('Grup')
          .update({'total_saldo': saldoGrup - jumlah})
          .eq('id_grup', idGrup);

      // C) Tambah saldo pengguna
      await _db
          .from('Pengguna')
          .update({'saldo': saldoUser + jumlah})
          .eq('id_pengguna', idPengguna);

      return null;
    } catch (e) {
      return _err(e);
    }
  }

  // ============================================================
  // INVITE MEMBER (owner only) - by rekening / telepon
  // ============================================================
  Future<String?> inviteMember({
    required String idGrup,
    String? rekening,
    String? telepon,
  }) async {
    final uid = _uid;
    if (uid == null) return "User belum login";

    final rek = rekening?.trim() ?? "";
    final tel = telepon?.trim() ?? "";

    if (rek.isEmpty && tel.isEmpty) return "Isi rekening atau telepon";

    try {
      // cek owner
      final me = await _db
          .from('Grup Member')
          .select('role')
          .eq('id_grup', idGrup)
          .eq('id_pengguna', uid)
          .single();

      final role = (me['role'] ?? 'member') as String;
      if (role != 'owner') return "Hanya owner yang bisa mengundang anggota";

      // cari user target dari tabel Pengguna
      PostgrestFilterBuilder q = _db.from('Pengguna').select('id_pengguna');

      if (rek.isNotEmpty) {
        q = q.eq('rekening', rek);
      } else {
        q = q.eq('telepon', tel);
      }

      final userRow = await q.single();
      final idPenggunaBaru = userRow['id_pengguna'] as String;

      if (idPenggunaBaru == uid) return "Tidak bisa invite diri sendiri";

      return await joinGroup(idGrup: idGrup, idPengguna: idPenggunaBaru);
    } catch (e) {
      return _err(e);
    }
  }

  // ============================================================
  // UPDATE GROUP SETTINGS (owner only)
  // ============================================================
  Future<String?> updateGroupSettings({
    required String idGrup,
    double? targetBaru,
    String? durasiBaru,
  }) async {
    final uid = _uid;
    if (uid == null) return "User belum login";

    final d = durasiBaru?.trim();

    if (targetBaru == null && (d == null || d.isEmpty)) {
      return "Tidak ada perubahan";
    }

    try {
      final me = await _db
          .from('Grup Member')
          .select('role')
          .eq('id_grup', idGrup)
          .eq('id_pengguna', uid)
          .single();

      final role = (me['role'] ?? 'member') as String;
      if (role != 'owner')
        return "Hanya owner yang bisa mengubah pengaturan grup";

      final update = <String, dynamic>{};
      if (targetBaru != null && targetBaru > 0) update['target'] = targetBaru;
      if (d != null && d.isNotEmpty) update['durasi'] = d;

      await _db.from('Grup').update(update).eq('id_grup', idGrup);
      return null;
    } catch (e) {
      return _err(e);
    }
  }

  // ============================================================
  // LEAVE GROUP (member only; owner tidak boleh keluar)
  // ============================================================
  Future<String?> leaveGroup({
    required String idGrup,
    required String idPengguna,
  }) async {
    try {
      final me = await _db
          .from('Grup Member')
          .select('role')
          .eq('id_grup', idGrup)
          .eq('id_pengguna', idPengguna)
          .maybeSingle();

      if (me == null) return "Kamu bukan anggota grup ini";

      final role = (me['role'] ?? 'member') as String;
      if (role == 'owner') {
        return "Owner tidak bisa keluar. Transfer kepemilikan dulu.";
      }

      await _db
          .from('Grup Member')
          .delete()
          .eq('id_grup', idGrup)
          .eq('id_pengguna', idPengguna);

      return null;
    } catch (e) {
      return _err(e);
    }
  }

  Future<bool> isOwner({
    required String idGrup,
    required String idPengguna,
  }) async {
    try {
      final row = await _db
          .from('Grup Member')
          .select('role')
          .eq('id_grup', idGrup)
          .eq('id_pengguna', idPengguna)
          .single();

      return (row['role'] ?? 'member') == 'owner';
    } catch (_) {
      return false;
    }
  }
}

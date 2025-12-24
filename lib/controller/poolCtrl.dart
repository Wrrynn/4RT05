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
  // CREATE GROUP (insert Grup + auto join owner)
  // ============================================================
  Future<Grup> createGroup({
    required String namaGrup,
    required double target,
    required String durasi,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception("User belum login");
    if (namaGrup.trim().isEmpty) {
      throw Exception("Nama grup tidak boleh kosong");
    }
    if (target <= 0) throw Exception("Target harus lebih dari 0");
    if (durasi.trim().isEmpty) throw Exception("Durasi tidak boleh kosong");

    try {
      final draft = Grup(
        idGrup: 'TEMP',
        namaGrup: namaGrup.trim(),
        target: target,
        durasi: durasi.trim(),
        totalSaldo: 0,
        dibuatOleh: uid,
      );

      final grupRow = await _db
          .from('Grup')
          .insert(draft.toInsertJson())
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
  // GET MEMBERS (buat tampil nama + rekening)
  // ============================================================
  Future<List<Map<String, dynamic>>> getGroupMembers({
    required String idGrup,
  }) async {
    try {
      final res = await _db
          .from('Grup Member')
          .select('''
            jumlah_kontribusi,
            id_pengguna,
            role,
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
  }) async {
    try {
      final exists = await _db
          .from('Grup Member')
          .select('id_member')
          .eq('id_grup', idGrup)
          .eq('id_pengguna', idPengguna)
          .maybeSingle();

      if (exists != null) return null;

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
  // GET MY CONTRIBUTION
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
  // ADD CONTRIBUTION:
  // - saldo Pengguna berkurang
  // - kontribusi member bertambah
  // - total_saldo Grup bertambah
  // ============================================================
  Future<String?> addContribution({
    required String idGrup,
    required String idPengguna,
    required int jumlah,
  }) async {
    if (jumlah <= 0) return "Nominal harus lebih dari 0";

    try {
      final userRow = await _db
          .from('Pengguna')
          .select('saldo')
          .eq('id_pengguna', idPengguna)
          .single();

      final saldoUser = (userRow['saldo'] as num?)?.toDouble() ?? 0.0;
      if (saldoUser < jumlah) return "Saldo kamu tidak cukup";

      final memberRow = await _db
          .from('Grup Member')
          .select('id_member, jumlah_kontribusi')
          .eq('id_grup', idGrup)
          .eq('id_pengguna', idPengguna)
          .single();

      final idMember = memberRow['id_member'] as String;
      final kontribusi = (memberRow['jumlah_kontribusi'] as num?)?.toInt() ?? 0;

      final grupRow = await _db
          .from('Grup')
          .select('total_saldo')
          .eq('id_grup', idGrup)
          .single();

      final saldoGrup = (grupRow['total_saldo'] as num?)?.toDouble() ?? 0.0;

      // Update berurutan (minimal)
      await _db
          .from('Pengguna')
          .update({'saldo': saldoUser - jumlah})
          .eq('id_pengguna', idPengguna);
      await _db
          .from('Grup Member')
          .update({'jumlah_kontribusi': kontribusi + jumlah})
          .eq('id_member', idMember);
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
  // WITHDRAW:
  // - maksimal sebesar kontribusi sendiri
  // - saldo Pengguna bertambah
  // - kontribusi member berkurang
  // - total_saldo Grup berkurang
  // ============================================================
  Future<String?> withdraw({
    required String idGrup,
    required String idPengguna,
    required int jumlah,
  }) async {
    if (jumlah <= 0) return "Nominal harus lebih dari 0";

    try {
      final userRow = await _db
          .from('Pengguna')
          .select('saldo')
          .eq('id_pengguna', idPengguna)
          .single();

      final saldoUser = (userRow['saldo'] as num?)?.toDouble() ?? 0.0;

      final memberRow = await _db
          .from('Grup Member')
          .select('id_member, jumlah_kontribusi')
          .eq('id_grup', idGrup)
          .eq('id_pengguna', idPengguna)
          .single();

      final idMember = memberRow['id_member'] as String;
      final kontribusi = (memberRow['jumlah_kontribusi'] as num?)?.toInt() ?? 0;

      if (jumlah > kontribusi) return "Saldo tabungan kamu tidak cukup";

      final grupRow = await _db
          .from('Grup')
          .select('total_saldo')
          .eq('id_grup', idGrup)
          .single();

      final saldoGrup = (grupRow['total_saldo'] as num?)?.toDouble() ?? 0.0;
      if (jumlah > saldoGrup) return "Saldo grup tidak cukup";

      await _db
          .from('Grup Member')
          .update({'jumlah_kontribusi': kontribusi - jumlah})
          .eq('id_member', idMember);
      await _db
          .from('Grup')
          .update({'total_saldo': saldoGrup - jumlah})
          .eq('id_grup', idGrup);
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
      final me = await _db
          .from('Grup Member')
          .select('role')
          .eq('id_grup', idGrup)
          .eq('id_pengguna', uid)
          .single();

      if ((me['role'] ?? 'member') != 'owner') {
        return "Hanya owner yang bisa mengundang anggota";
      }

      PostgrestFilterBuilder q = _db.from('Pengguna').select('id_pengguna');
      q = rek.isNotEmpty ? q.eq('rekening', rek) : q.eq('telepon', tel);

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

      if ((me['role'] ?? 'member') != 'owner') {
        return "Hanya owner yang bisa mengubah pengaturan grup";
      }

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
  // LEAVE GROUP:
  // - Member biasa: boleh keluar
  // - Owner: boleh keluar hanya jika member lain = 0 -> grup kehapus
  // ============================================================
  Future<String?> leaveGroup({
  required String idGrup,
  required String idPengguna,
}) async {
  try {
    final me = await _db
        .from('Grup Member')
        .select('role, jumlah_kontribusi')
        .eq('id_grup', idGrup)
        .eq('id_pengguna', idPengguna)
        .maybeSingle();

    if (me == null) return "Kamu bukan anggota grup ini";

    final role = (me['role'] ?? 'member') as String;
    final kontribusi = (me['jumlah_kontribusi'] as num?)?.toInt() ?? 0;

    // ✅ kalau masih ada uang, wajib tarik dulu
    if (kontribusi > 0) {
      return "Kamu masih punya kontribusi $kontribusi. Tarik dulu sampai 0 sebelum keluar.";
    }

    // owner jangan lewat sini (owner pakai deleteGroupIfOwnerAlone)
    if (role == 'owner') {
      return "Owner tidak bisa keluar lewat tombol ini.";
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

  // ============================================================
  // DELETE GROUP (owner only, only if owner is alone)
  // owner boleh hapus grup kalau member cuma dia sendiri
  // ============================================================
  Future<String?> deleteGroupIfOwnerAlone({
    required String idGrup,
    required String idOwner,
  }) async {
    try {
      // 1) pastikan owner + ambil kontribusi owner
      final me = await _db
          .from('Grup Member')
          .select('role, jumlah_kontribusi')
          .eq('id_grup', idGrup)
          .eq('id_pengguna', idOwner)
          .maybeSingle();

      if (me == null) return "Kamu bukan anggota grup ini";

      final role = (me['role'] ?? 'member') as String;
      final ownerKontribusi = (me['jumlah_kontribusi'] as num?)?.toInt() ?? 0;

      if (role != 'owner') return "Hanya owner yang bisa menghapus grup";

      // 2) cek total member (harus cuma owner)
      final members = await _db
          .from('Grup Member')
          .select('id_member')
          .eq('id_grup', idGrup);

      final totalMember = (members as List).length;
      if (totalMember > 1) {
        return "Tidak bisa hapus grup: masih ada anggota lain";
      }

      // 3) cek saldo grup harus 0
      final grupRow = await _db
          .from('Grup')
          .select('total_saldo')
          .eq('id_grup', idGrup)
          .single();

      final totalSaldo = (grupRow['total_saldo'] as num?)?.toDouble() ?? 0.0;
      if (totalSaldo > 0) {
        return "Tidak bisa hapus grup: masih ada saldo ${totalSaldo.toInt()}. Tarik dulu sampai 0.";
      }

      // 4) cek kontribusi owner harus 0 juga
      if (ownerKontribusi > 0) {
        return "Tidak bisa hapus grup: kontribusi owner masih $ownerKontribusi. Tarik dulu sampai 0.";
      }

      // 5) hapus member + grup
      await _db.from('Grup Member').delete().eq('id_grup', idGrup);
      await _db.from('Grup').delete().eq('id_grup', idGrup);

      return null;
    } catch (e) {
      return _err(e);
    }
  }
}

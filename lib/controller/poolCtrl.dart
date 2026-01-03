import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:artos/service/db_service.dart';
import 'package:artos/model/grup.dart';
import 'package:artos/model/grup_member.dart';
import 'package:artos/model/pengguna.dart'; // Pastikan import ini ada

class PoolController {
  // Hanya ambil current user ID, tidak pegang _db client untuk query
  String? get _uid => DBService.client.auth.currentUser?.id;

  String _err(dynamic e) {
    if (e is PostgrestException) return e.message;
    return e.toString();
  }

  // ============================================================
  // CREATE GROUP
  // ============================================================
  Future<Grup> createGroup({
    required String namaGrup,
    required double target,
    required String durasi,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception("User belum login");
    if (namaGrup.trim().isEmpty) throw Exception("Nama grup tidak boleh kosong");
    if (target <= 0) throw Exception("Target harus lebih dari 0");
    if (durasi.trim().isEmpty) throw Exception("Durasi tidak boleh kosong");

    try {
      // 1. Buat Draft Object
      final draft = Grup(
        idGrup: '', // ID akan digenerate DB
        namaGrup: namaGrup.trim(),
        target: target,
        durasi: durasi.trim(),
        totalSaldo: 0,
        dibuatOleh: uid,
      );

      // 2. Insert Grup via Model
      final newGrup = await Grup.insert(draft);

      // 3. Insert Owner otomatis via Model GrupMember
      await GrupMember.insert(
        idGrup: newGrup.idGrup,
        idPengguna: uid,
        role: 'owner',
      );

      return newGrup;
    } catch (e) {
      throw Exception("Database error: ${_err(e)}");
    }
  }

  // ============================================================
  // GET MY GROUPS
  // ============================================================
  Future<List<Grup>> getMyGroups({required String idPengguna}) async {
    try {
      return await GrupMember.getGroupsByUser(idPengguna);
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // GET MEMBERS
  // ============================================================
  Future<List<Map<String, dynamic>>> getGroupMembers({required String idGrup}) async {
    try {
      return await GrupMember.getMembersWithProfile(idGrup);
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
      final existing = await GrupMember.find(idGrup, idPengguna);
      if (existing != null) return null; // Sudah join

      await GrupMember.insert(idGrup: idGrup, idPengguna: idPengguna);
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
      final member = await GrupMember.find(idGrup, idPengguna);
      return member?.jumlahKontribusi ?? 0;
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
      // 1. Cek Saldo User
      final saldoUser = await Pengguna.getSaldo(idPengguna); // Asumsi ada di Model Pengguna
      if (saldoUser == null) return "User tidak ditemukan";
      if (saldoUser < jumlah) return "Saldo kamu tidak cukup";

      // 2. Cek Member
      final member = await GrupMember.find(idGrup, idPengguna);
      if (member == null) return "Kamu bukan anggota grup";

      // 3. Eksekusi Update Berurutan (Via Model)
      await Pengguna.decreaseSaldoSafe(idPengguna, jumlah.toDouble());
      await GrupMember.updateKontribusi(member.idMember, member.jumlahKontribusi, jumlah);
      await Grup.updateSaldo(idGrup, jumlah.toDouble());

      return null;
    } catch (e) {
      return _err(e);
    }
  }

  // ============================================================
  // WITHDRAW
  // ============================================================
  Future<String?> withdraw({
    required String idGrup,
    required String idPengguna,
    required int jumlah,
  }) async {
    if (jumlah <= 0) return "Nominal harus lebih dari 0";

    try {
      // 1. Cek Member & Kontribusi
      final member = await GrupMember.find(idGrup, idPengguna);
      if (member == null) return "Bukan anggota";
      if (jumlah > member.jumlahKontribusi) return "Saldo tabungan kamu tidak cukup";

      // 2. Cek Saldo Grup (Validasi Double Check)
      final grup = await Grup.findById(idGrup);
      if (grup == null) return "Grup tidak valid";
      if (jumlah > grup.totalSaldo) return "Saldo grup tidak cukup (sinkronisasi error)";

      // 3. Eksekusi Update (Kebalikan Add Contribution)
      await GrupMember.updateKontribusi(member.idMember, member.jumlahKontribusi, -jumlah);
      await Grup.updateSaldo(idGrup, -(jumlah.toDouble()));
      await Pengguna.increaseSaldo(idPengguna, jumlah.toDouble());

      return null;
    } catch (e) {
      return _err(e);
    }
  }

  // ============================================================
  // INVITE MEMBER
  // ============================================================
  Future<String?> inviteMember({
    required String idGrup,
    String? rekening,
    String? telepon,
  }) async {
    final uid = _uid;
    if (uid == null) return "User belum login";
    if ((rekening == null || rekening.isEmpty) && (telepon == null || telepon.isEmpty)) {
      return "Isi rekening atau telepon";
    }

    try {
      // 1. Cek Permission (Harus Owner)
      final me = await GrupMember.find(idGrup, uid);
      if (me?.role != 'owner') return "Hanya owner yang bisa mengundang";

      // 2. Cari User Target
      Pengguna? targetUser;
      if (rekening != null && rekening.isNotEmpty) {
        targetUser = await Pengguna.findByRekening(rekening);
      } else if (telepon != null && telepon.isNotEmpty) {
        // Asumsi Anda perlu menambahkan findByTelepon di Model Pengguna
        // Jika belum ada, gunakan logic pencarian manual di sini via DB sementara
        // Tapi demi MVC Murni, sebaiknya tambahkan: static Future<Pengguna?> findByTelepon(...) di model Pengguna
         // targetUser = await Pengguna.findByTelepon(telepon); // Uncomment jika sudah ditambahkan
      }

      if (targetUser == null) return "User tidak ditemukan";
      if (targetUser.idPengguna == uid) return "Tidak bisa invite diri sendiri";

      // 3. Join
      return await joinGroup(idGrup: idGrup, idPengguna: targetUser.idPengguna);
    } catch (e) {
      return _err(e);
    }
  }

  // ============================================================
  // UPDATE GROUP SETTINGS
  // ============================================================
  Future<String?> updateGroupSettings({
    required String idGrup,
    double? targetBaru,
    String? durasiBaru,
  }) async {
    final uid = _uid;
    if (uid == null) return "User belum login";

    try {
      final me = await GrupMember.find(idGrup, uid);
      if (me?.role != 'owner') return "Hanya owner yang bisa mengubah pengaturan";

      final updates = <String, dynamic>{};
      if (targetBaru != null && targetBaru > 0) updates['target'] = targetBaru;
      if (durasiBaru != null && durasiBaru.isNotEmpty) updates['durasi'] = durasiBaru;

      if (updates.isEmpty) return "Tidak ada perubahan";

      await Grup.updateSettings(idGrup, updates);
      return null;
    } catch (e) {
      return _err(e);
    }
  }

  // ============================================================
  // LEAVE GROUP
  // ============================================================
  Future<String?> leaveGroup({
    required String idGrup,
    required String idPengguna,
  }) async {
    try {
      final me = await GrupMember.find(idGrup, idPengguna);
      if (me == null) return "Kamu bukan anggota grup ini";

      if (me.jumlahKontribusi > 0) {
        return "Tarik dulu kontribusi Rp${me.jumlahKontribusi} sebelum keluar.";
      }

      if (me.role == 'owner') {
        return "Owner tidak bisa keluar lewat tombol ini.";
      }

      await GrupMember.remove(idGrup, idPengguna);
      return null;
    } catch (e) {
      return _err(e);
    }
  }

  // ============================================================
  // IS OWNER CHECK
  // ============================================================
  Future<bool> isOwner({required String idGrup, required String idPengguna}) async {
    final me = await GrupMember.find(idGrup, idPengguna);
    return me?.role == 'owner';
  }

  // ============================================================
  // DELETE GROUP (Owner Only)
  // ============================================================
  Future<String?> deleteGroupIfOwnerAlone({
    required String idGrup,
    required String idOwner,
  }) async {
    try {
      // 1. Validasi Owner
      final me = await GrupMember.find(idGrup, idOwner);
      if (me == null || me.role != 'owner') return "Hanya owner yang bisa menghapus grup";

      // 2. Validasi Member Lain
      final memberCount = await GrupMember.countMembers(idGrup);
      if (memberCount > 1) return "Masih ada anggota lain";

      // 3. Validasi Saldo Grup
      final grup = await Grup.findById(idGrup);
      if (grup != null && grup.totalSaldo > 0) {
        return "Masih ada saldo ${grup.totalSaldo}. Tarik dulu.";
      }

      // 4. Validasi Kontribusi Owner
      if (me.jumlahKontribusi > 0) {
        return "Tarik kontribusi kamu dulu.";
      }

      // 5. Delete All
      await GrupMember.removeAllInGroup(idGrup);
      await Grup.delete(idGrup);

      return null;
    } catch (e) {
      return _err(e);
    }
  }
}
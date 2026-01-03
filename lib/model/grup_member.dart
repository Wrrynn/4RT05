import 'package:artos/service/db_service.dart';
import 'package:artos/model/grup.dart';

class GrupMember {
  final String idMember;
  final String idGrup;
  final String idPengguna;
  int jumlahKontribusi;
  String role;
  final DateTime joinedAt;

  GrupMember({
    required this.idMember,
    required this.idGrup,
    required this.idPengguna,
    this.jumlahKontribusi = 0,
    this.role = 'member',
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  // ==========================================
  // DATABASE METHODS (Static)
  // ==========================================
  static final _db = DBService.client;

  // Insert Member
  static Future<void> insert({
    required String idGrup,
    required String idPengguna,
    String role = 'member',
  }) async {
    await _db.from('Grup Member').insert({
      'id_grup': idGrup,
      'id_pengguna': idPengguna,
      'jumlah_kontribusi': 0,
      'role': role,
    });
  }

  // Get Specific Member (Cek Role / Kontribusi)
  static Future<GrupMember?> find(String idGrup, String idPengguna) async {
    final res = await _db
        .from('Grup Member')
        .select()
        .eq('id_grup', idGrup)
        .eq('id_pengguna', idPengguna)
        .maybeSingle();
    
    return res != null ? GrupMember.fromJson(res) : null;
  }

  // Get All Groups for a User
  static Future<List<Grup>> getGroupsByUser(String idPengguna) async {
    final res = await _db
        .from('Grup Member')
        .select('grup:Grup(*)')
        .eq('id_pengguna', idPengguna);

    return (res as List)
        .map((row) => Grup.fromJson(row['grup'] as Map<String, dynamic>))
        .toList();
  }

  // Get Members List with User Profile (Join)
  static Future<List<Map<String, dynamic>>> getMembersWithProfile(String idGrup) async {
    final res = await _db
        .from('Grup Member')
        .select('''
            jumlah_kontribusi,
            id_pengguna,
            role,
            Pengguna ( nama_lengkap, rekening )
          ''')
        .eq('id_grup', idGrup)
        .order('jumlah_kontribusi', ascending: false);
    
    return List<Map<String, dynamic>>.from(res);
  }

  // Update Kontribusi
  static Future<void> updateKontribusi(String idMember, int currentAmount, int changeAmount) async {
    await _db.from('Grup Member').update({
      'jumlah_kontribusi': currentAmount + changeAmount
    }).eq('id_member', idMember);
  }

  // Delete Member
  static Future<void> remove(String idGrup, String idPengguna) async {
    await _db
        .from('Grup Member')
        .delete()
        .eq('id_grup', idGrup)
        .eq('id_pengguna', idPengguna);
  }
  
  // Delete All Members in Group (for deleting group)
  static Future<void> removeAllInGroup(String idGrup) async {
    await _db.from('Grup Member').delete().eq('id_grup', idGrup);
  }

  // Count Members
  static Future<int> countMembers(String idGrup) async {
    final res = await _db
        .from('Grup Member')
        .select('id_member')
        .eq('id_grup', idGrup);
    return (res as List).length;
  }

  // ==========================================
  // JSON CONVERTERS
  // ==========================================
  factory GrupMember.fromJson(Map<String, dynamic> json) {
    return GrupMember(
      idMember: json['id_member'] as String,
      idGrup: json['id_grup'] as String,
      idPengguna: json['id_pengguna'] as String,
      jumlahKontribusi: (json['jumlah_kontribusi'] as num?)?.toInt() ?? 0,
      role: (json['role'] ?? 'member') as String,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'])
          : DateTime.now(),
    );
  }
}
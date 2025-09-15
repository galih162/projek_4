import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // Insert Data Siswa
  Future<void> insertSiswa(Map<String, dynamic> data) async {
    await supabase.from('data_siswa').insert(data);
  }

  // Ambil Data Siswa
  Future<List<Map<String, dynamic>>> fetchSiswa() async {
    final res = await supabase.from('data_siswa').select();
    return List<Map<String, dynamic>>.from(res);
  }

  // Update Data Siswa
  Future<void> updateSiswa(int id, Map<String, dynamic> data) async {
    await supabase.from('data_siswa').update(data).eq('id', id);
  }

  // Delete Data Siswa
  Future<void> deleteSiswa(int id) async {
    await supabase.from('data_siswa').delete().eq('id', id);
  }
}

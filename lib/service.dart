import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // Insert Data Siswa dengan error handling yang proper
  Future<void> insertSiswa(Map<String, dynamic> data) async {
    try {
      print('Mengirim data ke Supabase: $data'); // Debug log
      
      final response = await supabase.from('data_siswa').insert(data);
      
      print('Response dari Supabase: $response'); // Debug log
      
      // Supabase Flutter v2+ tidak mengembalikan error di response
      // Jika ada error, akan throw exception langsung
      
    } catch (e) {
      print('Error di insertSiswa: $e'); // Debug log
      
      // Handle specific Supabase errors
      if (e is PostgrestException) {
        throw _handlePostgrestException(e);
      } else {
        throw Exception('Gagal menyimpan data: ${e.toString()}');
      }
    }
  }

  // Ambil Data Siswa dengan error handling
  Future<List<Map<String, dynamic>>> fetchSiswa() async {
    try {
      final response = await supabase.from('data_siswa').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error di fetchSiswa: $e');
      
      if (e is PostgrestException) {
        throw _handlePostgrestException(e);
      } else {
        throw Exception('Gagal mengambil data: ${e.toString()}');
      }
    }
  }

  // Update Data Siswa dengan error handling
  Future<void> updateSiswa(int id, Map<String, dynamic> data) async {
    try {
      print('Mengupdate data ID $id: $data');
      
      await supabase.from('data_siswa').update(data).eq('id', id);
      
    } catch (e) {
      print('Error di updateSiswa: $e');
      
      if (e is PostgrestException) {
        throw _handlePostgrestException(e);
      } else {
        throw Exception('Gagal mengupdate data: ${e.toString()}');
      }
    }
  }

  // Delete Data Siswa dengan error handling
  Future<void> deleteSiswa(int id) async {
    try {
      print('Menghapus data ID: $id');
      
      await supabase.from('data_siswa').delete().eq('id', id);
      
    } catch (e) {
      print('Error di deleteSiswa: $e');
      
      if (e is PostgrestException) {
        throw _handlePostgrestException(e);
      } else {
        throw Exception('Gagal menghapus data: ${e.toString()}');
      }
    }
  }

  // Handle Postgrest Exception dengan pesan yang user-friendly
  String _handlePostgrestException(PostgrestException e) {
    print('PostgrestException details:');
    print('Code: ${e.code}');
    print('Message: ${e.message}');
    print('Details: ${e.details}');
    print('Hint: ${e.hint}');

    switch (e.code) {
      case '23505': // Unique violation
        return 'Data sudah ada (duplikat). Periksa NISN atau NIK.';
      
      case '23502': // Not null violation
        final field = _extractFieldFromError(e.message);
        return 'Field $field wajib diisi dan tidak boleh kosong.';
      
      case '23503': // Foreign key violation
        return 'Data referensi tidak valid. Periksa data yang dirujuk.';
      
      case '42703': // Undefined column
        return 'Struktur database tidak sesuai. Hubungi administrator.';
      
      case '42P01': // Undefined table
        return 'Tabel tidak ditemukan. Hubungi administrator.';
      
      default:
        return 'Error database: ${e.message}';
    }
  }

  // Extract field name dari error message
  String _extractFieldFromError(String message) {
    // Contoh message: "null value in column "tanggal_lahir" violates not-null constraint"
    final regex = RegExp(r'column "([^"]+)"');
    final match = regex.firstMatch(message);
    
    if (match != null && match.group(1) != null) {
      final field = match.group(1)!;
      
      // Convert field name ke bahasa yang user-friendly
      switch (field) {
        case 'nisn': return 'NISN';
        case 'nama_lengkap': return 'Nama Lengkap';
        case 'jenis_kelamin': return 'Jenis Kelamin';
        case 'agama': return 'Agama';
        case 'tempat_lahir': return 'Tempat Lahir';
        case 'tanggal_lahir': return 'Tanggal Lahir';
        case 'alamat_desa': return 'Desa';
        case 'alamat_kabupaten': return 'Kabupaten';
        case 'alamat_provinsi': return 'Provinsi';
        default: return field;
      }
    }
    
    return 'tidak diketahui';
  }

  // Method untuk test koneksi
  Future<bool> testConnection() async {
    try {
      await supabase.from('data_siswa').select().limit(1);
      return true;
    } catch (e) {
      print('Test koneksi gagal: $e');
      return false;
    }
  }

  // Method untuk cek struktur tabel
  Future<void> checkTableStructure() async {
    try {
      // Query untuk melihat struktur tabel
      final result = await supabase.rpc('get_table_columns', 
        params: {'table_name': 'data_siswa'}
      );
      print('Struktur tabel data_siswa: $result');
    } catch (e) {
      print('Tidak bisa cek struktur tabel: $e');
    }
  }
}
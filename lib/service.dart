import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  /// Inserts student data into the 'data_siswa' table.
  Future<void> insertSiswa(Map<String, dynamic> data) async {
    try {
      print('Mengirim data ke Supabase: $data');
      await supabase.from('data_siswa').insert(data);
      print('Data siswa berhasil disimpan');
    } catch (e) {
      print('Error di insertSiswa: $e');
      if (e is PostgrestException) {
        throw _handlePostgrestException(e);
      } else {
        throw Exception('Gagal menyimpan data: ${e.toString()}');
      }
    }
  }

  /// Fetches all student data from the 'data_siswa' table.
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

  /// Updates student data in the 'data_siswa' table by ID.
  Future<void> updateSiswa(int id, Map<String, dynamic> data) async {
    try {
      print('Mengupdate data ID $id: $data');
      await supabase.from('data_siswa').update(data).eq('id', id);
      print('Data siswa ID $id berhasil diupdate');
    } catch (e) {
      print('Error di updateSiswa: $e');
      if (e is PostgrestException) {
        throw _handlePostgrestException(e);
      } else {
        throw Exception('Gagal mengupdate data: ${e.toString()}');
      }
    }
  }

  /// Deletes student data from the 'data_siswa' table by ID.
  Future<void> deleteSiswa(int id) async {
    try {
      print('Menghapus data ID: $id');
      await supabase.from('data_siswa').delete().eq('id', id);
      print('Data siswa ID $id berhasil dihapus');
    } catch (e) {
      print('Error di deleteSiswa: $e');
      if (e is PostgrestException) {
        throw _handlePostgrestException(e);
      } else {
        throw Exception('Gagal menghapus data: ${e.toString()}');
      }
    }
  }

  /// Searches for dusun based on a keyword and returns related address data.
  Future<List<Map<String, dynamic>>> searchDusun(String keyword) async {
    try {
      final response = await supabase
          .from('dusun')
          .select('''
            id,
            nama_dusun,
            kode_pos,
            desa:desa_id (
              nama_desa,
              kecamatan:kecamatan_id (
                nama_kecamatan,
                kabupaten:kabupaten_id (
                  nama_kabupaten,
                  provinsi:provinsi_id (
                    nama_provinsi
                  )
                )
              )
            )
          ''')
          .ilike('nama_dusun', '%$keyword%')
          .limit(10);

      // Map the response to a simplified structure for UI
      return (response as List).map<Map<String, dynamic>>((d) {
        return {
          'id': d['id'],
          'dusun': d['nama_dusun'] ?? '',
          'kode_pos': d['kode_pos']?.toString() ?? '',
          'desa': d['desa']?['nama_desa'] ?? '',
          'kecamatan': d['desa']?['kecamatan']?['nama_kecamatan'] ?? '',
          'kabupaten': d['desa']?['kecamatan']?['kabupaten']?['nama_kabupaten'] ?? '',
          'provinsi': d['desa']?['kecamatan']?['kabupaten']?['provinsi']?['nama_provinsi'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error di searchDusun: $e');
      if (e is PostgrestException) {
        throw _handlePostgrestException(e);
      } else {
        throw Exception('Gagal mencari dusun: ${e.toString()}');
      }
    }
  }

  /// Fetches all dusun with related address data.
  Future<List<Map<String, dynamic>>> fetchDusunWithRelations() async {
    try {
      final response = await supabase
          .from('dusun')
          .select('''
            id,
            nama_dusun,
            desa:desa_id (
              id,
              nama_desa,
              kecamatan:kecamatan_id (
                id,
                nama_kecamatan,
                kabupaten:kabupaten_id (
                  id,
                  nama_kabupaten,
                  provinsi:provinsi_id (
                    id,
                    nama_provinsi
                  )
                )
              )
            )
          ''');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error di fetchDusunWithRelations: $e');
      if (e is PostgrestException) {
        throw _handlePostgrestException(e);
      } else {
        throw Exception('Gagal mengambil data dusun: ${e.toString()}');
      }
    }
  }

  /// Fetches complete address data by dusun ID.
  Future<Map<String, dynamic>?> fetchAlamatByDusunId(int dusunId) async {
    try {
      final response = await supabase
          .from('dusun')
          .select('''
            id,
            nama_dusun,
            desa:desa_id (
              nama_desa,
              kecamatan:kecamatan_id (
                nama_kecamatan,
                kabupaten:kabupaten_id (
                  nama_kabupaten,
                  provinsi:provinsi_id (
                    nama_provinsi
                  )
                )
              )
            )
          ''')
          .eq('id', dusunId)
          .single();
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('Error di fetchAlamatByDusunId: $e');
      if (e is PostgrestException) {
        throw _handlePostgrestException(e);
      } else {
        throw Exception('Gagal mengambil alamat: ${e.toString()}');
      }
    }
  }

  /// Tests the connection to Supabase by performing a simple query.
  Future<bool> testConnection() async {
    try {
      await supabase.from('data_siswa').select().limit(1);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Handles Postgrest exceptions and returns user-friendly error messages.
  String _handlePostgrestException(PostgrestException e) {
    switch (e.code) {
      case '23505':
        return 'Data sudah ada (duplikat).';
      case '23502':
        final field = _extractFieldFromError(e.message);
        return 'Field $field wajib diisi.';
      case '23503':
        return 'Data referensi tidak valid.';
      default:
        return 'Error database: ${e.message}';
    }
  }

  /// Extracts the field name from a Postgrest error message.
  String _extractFieldFromError(String message) {
    final regex = RegExp(r'column "([^"]+)"');
    final match = regex.firstMatch(message);
    return match?.group(1) ?? 'tidak diketahui';
  }
}
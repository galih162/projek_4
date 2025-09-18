// Impor package Supabase untuk komunikasi dengan database
import 'package:supabase_flutter/supabase_flutter.dart';

// Kelas untuk mengelola operasi CRUD dan pencarian data pada database Supabase
class SupabaseService {
  // Inisialisasi client Supabase
  final supabase = Supabase.instance.client;

  // Menyisipkan data siswa ke tabel 'data_siswa'
  Future<void> insertSiswa(Map<String, dynamic> data) async {
    try {
      print('Mengirim data ke Supabase: $data'); // Log data yang dikirim
      await supabase.from('data_siswa').insert(data);
      print('Data siswa berhasil disimpan');
    } catch (e) {
      print('Error di insertSiswa: $e'); // Log error jika terjadi
      if (e is PostgrestException) {
        throw _handlePostgrestException(e); // Tangani error spesifik Postgrest
      } else {
        throw Exception('Gagal menyimpan data: ${e.toString()}');
      }
    }
  }

  // Mengambil semua data siswa dari tabel 'data_siswa'
  Future<List<Map<String, dynamic>>> fetchSiswa() async {
    try {
      final response = await supabase.from('data_siswa').select();
      return List<Map<String, dynamic>>.from(response); // Konversi respons ke list map
    } catch (e) {
      print('Error di fetchSiswa: $e'); // Log error jika terjadi
      if (e is PostgrestException) {
        throw _handlePostgrestException(e);
      } else {
        throw Exception('Gagal mengambil data: ${e.toString()}');
      }
    }
  }

  // Memperbarui data siswa berdasarkan ID di tabel 'data_siswa'
  Future<void> updateSiswa(int id, Map<String, dynamic> data) async {
    try {
      print('Mengupdate data ID $id: $data'); // Log data yang diupdate
      await supabase.from('data_siswa').update(data).eq('id', id);
      print('Data siswa ID $id berhasil diupdate');
    } catch (e) {
      print('Error di updateSiswa: $e'); // Log error jika terjadi
      if (e is PostgrestException) {
        throw _handlePostgrestException(e);
      } else {
        throw Exception('Gagal mengupdate data: ${e.toString()}');
      }
    }
  }

  // Menghapus data siswa berdasarkan ID dari tabel 'data_siswa'
  Future<void> deleteSiswa(int id) async {
    try {
      print('Menghapus data ID: $id'); // Log ID yang dihapus
      await supabase.from('data_siswa').delete().eq('id', id);
      print('Data siswa ID $id berhasil dihapus');
    } catch (e) {
      print('Error di deleteSiswa: $e'); // Log error jika terjadi
      if (e is PostgrestException) {
        throw _handlePostgrestException(e);
      } else {
        throw Exception('Gagal menghapus data: ${e.toString()}');
      }
    }
  }

  // Mencari dusun berdasarkan kata kunci dengan data alamat terkait
  Future<List<Map<String, dynamic>>> searchDusun(String keyword) async {
    try {
      // Query untuk mengambil data dusun dan relasi (desa, kecamatan, kabupaten, provinsi)
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
          .ilike('nama_dusun', '%$keyword%') // Pencarian case-insensitive
          .limit(10); // Batasi hasil ke 10 item

      // Transformasi data respons ke format yang lebih sederhana untuk UI
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
      print('Error di searchDusun: $e'); // Log error jika terjadi
      if (e is PostgrestException) {
        throw _handlePostgrestException(e);
      } else {
        throw Exception('Gagal mencari dusun: ${e.toString()}');
      }
    }
  }

  // Mengambil semua data dusun dengan relasi alamat
  Future<List<Map<String, dynamic>>> fetchDusunWithRelations() async {
    try {
      // Query untuk mengambil semua data dusun dan relasi
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
      return List<Map<String, dynamic>>.from(response); // Kembalikan data mentah
    } catch (e) {
      print('Error di fetchDusunWithRelations: $e'); // Log error jika terjadi
      if (e is PostgrestException) {
        throw _handlePostgrestException(e);
      } else {
        throw Exception('Gagal mengambil data dusun: ${e.toString()}');
      }
    }
  }

  // Mengambil data alamat lengkap berdasarkan ID dusun
  Future<Map<String, dynamic>?> fetchAlamatByDusunId(int dusunId) async {
    try {
      // Query untuk mengambil data alamat berdasarkan ID dusun
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
          .single(); // Ambil satu record
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('Error di fetchAlamatByDusunId: $e'); // Log error jika terjadi
      if (e is PostgrestException) {
        throw _handlePostgrestException(e);
      } else {
        throw Exception('Gagal mengambil alamat: ${e.toString()}');
      }
    }
  }

  // Menguji koneksi ke Supabase dengan query sederhana
  Future<bool> testConnection() async {
    try {
      await supabase.from('data_siswa').select().limit(1); // Query uji
      return true; // Koneksi berhasil
    } catch (_) {
      return false; // Koneksi gagal
    }
  }

  // Menangani error Postgrest dengan pesan yang ramah pengguna
  String _handlePostgrestException(PostgrestException e) {
    switch (e.code) {
      case '23505':
        return 'Data sudah ada (duplikat).'; // Error duplikasi data
      case '23502':
        final field = _extractFieldFromError(e.message);
        return 'Field $field wajib diisi.'; // Error field wajib
      case '23503':
        return 'Data referensi tidak valid.'; // Error foreign key
      default:
        return 'Error database: ${e.message}'; // Error umum
    }
  }

  // Mengekstrak nama field dari pesan error Postgrest
  String _extractFieldFromError(String message) {
    final regex = RegExp(r'column "([^"]+)"');
    final match = regex.firstMatch(message);
    return match?.group(1) ?? 'tidak diketahui'; // Kembalikan nama field atau default
  }
}
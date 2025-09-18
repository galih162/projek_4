import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;
  final Duration _timeout = const Duration(seconds: 10);
  final int _maxRetries = 3;

  /// Memeriksa koneksi internet
  Future<bool> _checkInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Verifikasi koneksi dengan mencoba menghubungi server
      final result = await InternetAddress.lookup('google.com').timeout(Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    }
  }

  /// Menangani error dengan pesan yang lebih spesifik
  Map<String, dynamic> _handleError(dynamic e, String operation) {
    String message;
    String errorCode;
    bool canRetry = false;

    if (e is SocketException || e is TimeoutException) {
      message = 'Tidak ada koneksi internet saat $operation data. Silakan periksa koneksi Anda.';
      errorCode = 'no_connection';
      canRetry = true;
    } else if (e is PostgrestException) {
      switch (e.code) {
        case 'PGRST301': // Invalid data or schema mismatch
          message = 'Data tidak valid atau tidak sesuai dengan struktur database saat $operation.';
          errorCode = 'invalid_data';
          canRetry = false;
          break;
        case '42501': // Insufficient privileges
          message = 'Anda tidak memiliki izin untuk $operation data.';
          errorCode = 'permission_denied';
          canRetry = false;
          break;
        case 'PGRST116': // Duplicate key or unique constraint violation
          message = 'Data duplikat (misalnya, NISN sudah ada) saat $operation.';
          errorCode = 'duplicate_key';
          canRetry = false;
          break;
        default:
          message = 'Kesalahan server saat $operation: ${e.message}';
          errorCode = 'server_error';
          canRetry = true;
      }
    } else {
      message = 'Terjadi kesalahan tak terduga saat $operation: ${e.toString()}';
      errorCode = 'unknown_error';
      canRetry = true;
    }

    return {
      'success': false,
      'message': message,
      'error_code': errorCode,
      'can_retry': canRetry,
      'data': []
    };
  }

  /// Menjalankan operasi dengan retry mechanism
  Future<Map<String, dynamic>> _retryOperation(Future<Map<String, dynamic>> Function() operation) async {
    int attempt = 0;
    while (attempt < _maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (attempt == _maxRetries) {
          return _handleError(e, 'menjalankan operasi');
        }
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    return {
      'success': false,
      'message': 'Gagal setelah $_maxRetries percobaan.',
      'error_code': 'max_retries_exceeded',
      'can_retry': false,
      'data': []
    };
  }

  /// Mengambil data siswa
  Future<Map<String, dynamic>> fetchSiswa() async {
    bool hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      return {
        'success': false,
        'message': 'Tidak ada koneksi internet. Data tidak dapat dimuat.',
        'error_code': 'no_connection',
        'can_retry': true,
        'data': <Map<String, dynamic>>[]
      };
    }

    return await _retryOperation(() async {
      try {
        final response = await supabase
            .from('data_siswa')
            .select('''
              *,
              dusun_siswa:dusun_id (
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
              )
            ''')
            .timeout(_timeout);

        return {
          'success': true,
          'data': List<Map<String, dynamic>>.from(response),
          'message': 'Data berhasil dimuat',
          'can_retry': false
        };
      } catch (e) {
        print('Error di fetchSiswa: $e');
        final errorResult = _handleError(e, 'memuat');
        errorResult['data'] = <Map<String, dynamic>>[];
        return errorResult;
      }
    });
  }

  /// Menambahkan data siswa
  Future<Map<String, dynamic>> insertSiswa(Map<String, dynamic> data) async {
    bool hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      return {
        'success': false,
        'message': 'Tidak ada koneksi internet. Data tidak dapat disimpan. Silakan coba lagi nanti.',
        'error_code': 'no_connection',
        'can_retry': true,
        'data': []
      };
    }

    return await _retryOperation(() async {
      try {
        print('Mengirim data ke Supabase: $data');
        
        if (data.isEmpty) {
          return {
            'success': false,
            'message': 'Data tidak boleh kosong.',
            'error_code': 'empty_data',
            'can_retry': false,
            'data': []
          };
        }

        // Validasi data wajib
        final requiredFields = ['nisn', 'nama_lengkap', 'jenis_kelamin', 'agama', 'tempat_lahir', 'tanggal_lahir', 'nik', 'alamat_jalan', 'alamat_rt', 'alamat_desa', 'alamat_kabupaten', 'alamat_provinsi'];
        final missingFields = requiredFields.where((field) => !data.containsKey(field) || data[field] == null || data[field].toString().trim().isEmpty).toList();
        if (missingFields.isNotEmpty) {
          return {
            'success': false,
            'message': 'Field wajib berikut tidak lengkap: ${missingFields.join(', ')}',
            'error_code': 'missing_required_fields',
            'can_retry': false,
            'data': []
          };
        }

        // Validasi panjang NISN dan NIK
        if (data['nisn'].toString().length != 10) {
          return {
            'success': false,
            'message': 'NISN harus 10 digit.',
            'error_code': 'invalid_nisn',
            'can_retry': false,
            'data': []
          };
        }
        if (data['nik'].toString().length != 16) {
          return {
            'success': false,
            'message': 'NIK harus 16 digit.',
            'error_code': 'invalid_nik',
            'can_retry': false,
            'data': []
          };
        }

        // Cari dusun_id untuk alamat_dusun jika ada
        if (data.containsKey('alamat_dusun') && data['alamat_dusun'] != null && data['alamat_dusun'].toString().trim().isNotEmpty) {
          try {
            final dusunResponse = await supabase
                .from('dusun')
                .select('id')
                .eq('nama_dusun', data['alamat_dusun'].toString().trim())
                .maybeSingle()
                .timeout(_timeout);
            if (dusunResponse != null) {
              data['dusun_id'] = dusunResponse['id'];
            } else {
              return {
                'success': false,
                'message': 'Dusun "${data['alamat_dusun']}" tidak ditemukan di database.',
                'error_code': 'dusun_not_found',
                'can_retry': false,
                'data': []
              };
            }
            data.remove('alamat_dusun');
          } catch (e) {
            return _handleError(e, 'mencari dusun');
          }
        }

        // Cari dusun_id untuk alamat_dusun_ortu jika ada
        if (data.containsKey('alamat_dusun_ortu') && data['alamat_dusun_ortu'] != null && data['alamat_dusun_ortu'].toString().trim().isNotEmpty) {
          try {
            final dusunResponse = await supabase
                .from('dusun')
                .select('id')
                .eq('nama_dusun', data['alamat_dusun_ortu'].toString().trim())
                .maybeSingle()
                .timeout(_timeout);
            if (dusunResponse != null) {
              data['dusun_id_ortu'] = dusunResponse['id'];
            } else {
              return {
                'success': false,
                'message': 'Dusun orang tua "${data['alamat_dusun_ortu']}" tidak ditemukan di database.',
                'error_code': 'dusun_ortu_not_found',
                'can_retry': false,
                'data': []
              };
            }
            data.remove('alamat_dusun_ortu');
          } catch (e) {
            return _handleError(e, 'mencari dusun orang tua');
          }
        }

        final response = await supabase
            .from('data_siswa')
            .insert(data)
            .select()
            .timeout(_timeout);
            
        print('Data siswa berhasil disimpan: $response');
        
        return {
          'success': true,
          'message': 'Data berhasil disimpan',
          'data': List<Map<String, dynamic>>.from(response),
          'can_retry': false
        };
      } catch (e) {
        print('Error di insertSiswa: $e');
        return _handleError(e, 'menyimpan');
      }
    });
  }

  /// Memperbarui data siswa
  Future<Map<String, dynamic>> updateSiswa(int id, Map<String, dynamic> data) async {
    bool hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      return {
        'success': false,
        'message': 'Tidak ada koneksi internet. Data tidak dapat diupdate.',
        'error_code': 'no_connection',
        'can_retry': true,
        'data': []
      };
    }

    return await _retryOperation(() async {
      try {
        print('Mengupdate data ID $id: $data');
        
        if (data.isEmpty) {
          return {
            'success': false,
            'message': 'Data update tidak boleh kosong.',
            'error_code': 'empty_data',
            'can_retry': false,
            'data': []
          };
        }

        // Cari dusun_id untuk alamat_dusun jika ada
        if (data.containsKey('alamat_dusun') && data['alamat_dusun'] != null && data['alamat_dusun'].toString().trim().isNotEmpty) {
          try {
            final dusunResponse = await supabase
                .from('dusun')
                .select('id')
                .eq('nama_dusun', data['alamat_dusun'].toString().trim())
                .maybeSingle()
                .timeout(_timeout);
            if (dusunResponse != null) {
              data['dusun_id'] = dusunResponse['id'];
            } else {
              return {
                'success': false,
                'message': 'Dusun "${data['alamat_dusun']}" tidak ditemukan di database.',
                'error_code': 'dusun_not_found',
                'can_retry': false,
                'data': []
              };
            }
            data.remove('alamat_dusun');
          } catch (e) {
            return _handleError(e, 'mencari dusun');
          }
        }

        // Cari dusun_id untuk alamat_dusun_ortu jika ada
        if (data.containsKey('alamat_dusun_ortu') && data['alamat_dusun_ortu'] != null && data['alamat_dusun_ortu'].toString().trim().isNotEmpty) {
          try {
            final dusunResponse = await supabase
                .from('dusun')
                .select('id')
                .eq('nama_dusun', data['alamat_dusun_ortu'].toString().trim())
                .maybeSingle()
                .timeout(_timeout);
            if (dusunResponse != null) {
              data['dusun_id_ortu'] = dusunResponse['id'];
            } else {
              return {
                'success': false,
                'message': 'Dusun orang tua "${data['alamat_dusun_ortu']}" tidak ditemukan di database.',
                'error_code': 'dusun_ortu_not_found',
                'can_retry': false,
                'data': []
              };
            }
            data.remove('alamat_dusun_ortu');
          } catch (e) {
            return _handleError(e, 'mencari dusun orang tua');
          }
        }

        await supabase
            .from('data_siswa')
            .update(data)
            .eq('id', id)
            .timeout(_timeout);
            
        print('Data siswa ID $id berhasil diupdate');
        
        return {
          'success': true,
          'message': 'Data berhasil diupdate',
          'can_retry': false,
          'data': []
        };
      } catch (e) {
        print('Error di updateSiswa: $e');
        return _handleError(e, 'mengupdate');
      }
    });
  }

  /// Menghapus data siswa
  Future<Map<String, dynamic>> deleteSiswa(int id) async {
    bool hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      return {
        'success': false,
        'message': 'Tidak ada koneksi internet. Data tidak dapat dihapus.',
        'error_code': 'no_connection',
        'can_retry': true,
        'data': []
      };
    }

    return await _retryOperation(() async {
      try {
        await supabase
            .from('data_siswa')
            .delete()
            .eq('id', id)
            .timeout(_timeout);
            
        print('Data siswa ID $id berhasil dihapus');
        
        return {
          'success': true,
          'message': 'Data berhasil dihapus',
          'can_retry': false,
          'data': []
        };
      } catch (e) {
        print('Error di deleteSiswa: $e');
        return _handleError(e, 'menghapus');
      }
    });
  }

  /// Mencari dusun
  Future<Map<String, dynamic>> searchDusun(String query) async {
    bool hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      return {
        'success': false,
        'message': 'Tidak ada koneksi internet. Tidak dapat mencari dusun.',
        'error_code': 'no_connection',
        'can_retry': true,
        'data': []
      };
    }

    return await _retryOperation(() async {
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
            .ilike('nama_dusun', '%$query%')
            .limit(10)
            .timeout(_timeout);

        return {
          'success': true,
          'data': List<Map<String, dynamic>>.from(response),
          'message': response.isEmpty ? 'Tidak ada dusun ditemukan' : 'Dusun berhasil ditemukan',
          'can_retry': false
        };
      } catch (e) {
        print('Error di searchDusun: $e');
        return _handleError(e, 'mencari dusun');
      }
    });
  }
}
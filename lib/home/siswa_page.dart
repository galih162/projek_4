import 'package:flutter/material.dart';
import 'package:projek_4/service.dart';
import 'package:projek_4/screens/dasboard_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final service = SupabaseService();

  // controller sama persis seperti yang sudah kamu buat sebelumnya…
  final TextEditingController nisnC = TextEditingController();
  final TextEditingController namaC = TextEditingController();
  final TextEditingController jkC = TextEditingController();
  final TextEditingController agamaC = TextEditingController();
  final TextEditingController tempatTanggalLahirC = TextEditingController();
  final TextEditingController noHpC = TextEditingController();
  final TextEditingController nikC = TextEditingController();
  final TextEditingController jalanC = TextEditingController();
  final TextEditingController rtC = TextEditingController();
  final TextEditingController dusunC = TextEditingController();
  final TextEditingController desaC = TextEditingController();
  final TextEditingController kabupatenC = TextEditingController();
  final TextEditingController provinsiC = TextEditingController();
  final TextEditingController kodePosC = TextEditingController();
  final TextEditingController ayahC = TextEditingController();
  final TextEditingController ibuC = TextEditingController();
  final TextEditingController waliC = TextEditingController();
  final TextEditingController alamatOrtuC = TextEditingController();

  Future<void> _simpanData() async {
    try {
      final data = {
        'nisn': nisnC.text,
        'nama_lengkap': namaC.text,
        'jenis_kelamin': jkC.text,
        'agama': agamaC.text,
        'tempat_lahir': tempatTanggalLahirC.text,
        'no_hp': noHpC.text,
        'nik': nikC.text,
        'alamat_jalan': jalanC.text,
        'alamat_rt': rtC.text,
        'alamat_dusun': dusunC.text,
        'alamat_desa': desaC.text,
        'alamat_kabupaten': kabupatenC.text,
        'alamat_provinsi': provinsiC.text,
        'alamat_kode_pos': kodePosC.text,
        'nama_ayah': ayahC.text,
        'nama_ibu': ibuC.text,
        'nama_wali': waliC.text,
        'alamat_orang_tua': alamatOrtuC.text,
      };

      await service.insertSiswa(data);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal simpan data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Data Siswa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _field(nisnC, 'NISN'),
            _field(namaC, 'Nama Lengkap'),
            _field(jkC, 'Jenis Kelamin'),
            _field(agamaC, 'Agama'),
            _field(tempatTanggalLahirC, 'Tempat/Tgl Lahir'),
            _field(noHpC, 'No HP'),
            _field(nikC, 'NIK'),
            _field(jalanC, 'Jalan'),
            _field(rtC, 'RT'),
            _field(dusunC, 'Dusun'),
            _field(desaC, 'Desa'),
            _field(kabupatenC, 'Kabupaten'),
            _field(provinsiC, 'Provinsi'),
            _field(kodePosC, 'Kode Pos'),
            _field(ayahC, 'Nama Ayah'),
            _field(ibuC, 'Nama Ibu'),
            _field(waliC, 'Nama Wali'),
            _field(alamatOrtuC, 'Alamat Orang Tua/Wali'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _simpanData,
              child: const Text('Simpan Data'),
            )
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

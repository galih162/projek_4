// Impor package yang diperlukan untuk UI, service Supabase, dan navigasi
import 'package:flutter/material.dart';
import 'package:projek_4/service.dart';
import 'package:projek_4/screens/dasboard_page.dart';

// Kelas utama untuk halaman SplashScreen, berfungsi sebagai form input data siswa
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// State untuk SplashScreen dengan animasi dan pengelolaan form multi-step
class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Inisialisasi service untuk komunikasi dengan Supabase
  final service = SupabaseService();
  // Controller untuk animasi fade-in
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  // Controller untuk navigasi halaman pada PageView
  int currentStep = 0;
  final PageController _pageController = PageController();

  // Controller untuk setiap field input
  final TextEditingController nisnC = TextEditingController();
  final TextEditingController namaC = TextEditingController();
  final TextEditingController tempatLahirC = TextEditingController();
  final TextEditingController tanggalLahirC = TextEditingController();
  final TextEditingController noHpC = TextEditingController();
  final TextEditingController nikC = TextEditingController();
  final TextEditingController jalanC = TextEditingController();
  final TextEditingController rtC = TextEditingController();
  final TextEditingController dusunC = TextEditingController();
  final TextEditingController desaC = TextEditingController();
  final TextEditingController kabupatenC = TextEditingController();
  final TextEditingController provinsiC = TextEditingController();
  final TextEditingController kodePosC = TextEditingController();
  final TextEditingController kecamatanC = TextEditingController();
  final TextEditingController ayahC = TextEditingController();
  final TextEditingController ibuC = TextEditingController();
  final TextEditingController waliC = TextEditingController();
  final TextEditingController dusunOrtuC = TextEditingController();
  final TextEditingController desaOrtuC = TextEditingController();
  final TextEditingController kecamatanOrtuC = TextEditingController();
  final TextEditingController kabupatenOrtuC = TextEditingController();
  final TextEditingController provinsiOrtuC = TextEditingController();
  final TextEditingController kodePosOrtuC = TextEditingController();

  // Variabel untuk dropdown jenis kelamin dan agama
  String? selectedJenisKelamin;
  String? selectedAgama;

  // Variabel untuk fitur autocomplete alamat
  List<Map<String, dynamic>> dusunSuggestions = []; // Saran dusun siswa
  List<Map<String, dynamic>> ortuSuggestions = []; // Saran dusun orang tua
  bool isLoadingSuggestions = false; // Status loading untuk pencarian dusun
  OverlayEntry? _overlayEntry; // Overlay untuk menampilkan saran
  final LayerLink _layerLink = LayerLink(); // Link untuk posisi overlay siswa
  final LayerLink _ortuLayerLink = LayerLink(); // Link untuk posisi overlay ortu
  final FocusNode dusunFocusNode = FocusNode(); // Focus node untuk field dusun
  final FocusNode ortuFocusNode = FocusNode(); // Focus node untuk field ortu

  // Daftar opsi untuk dropdown
  final List<String> jenisKelamin = ['Laki-laki', 'Perempuan'];
  final List<String> agamaList = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
  ];

  // Inisialisasi animasi fade-in
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward(); // Mulai animasi saat halaman dimuat
  }

  // Dispose semua resource untuk mencegah memory leak
  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    dusunFocusNode.dispose();
    ortuFocusNode.dispose();
    _hideOverlay();

    // Dispose semua controller
    nisnC.dispose();
    namaC.dispose();
    tempatLahirC.dispose();
    tanggalLahirC.dispose();
    noHpC.dispose();
    nikC.dispose();
    jalanC.dispose();
    rtC.dispose();
    dusunC.dispose();
    desaC.dispose();
    kabupatenC.dispose();
    provinsiC.dispose();
    kodePosC.dispose();
    kecamatanC.dispose();
    ayahC.dispose();
    ibuC.dispose();
    waliC.dispose();
    dusunOrtuC.dispose();
    desaOrtuC.dispose();
    kecamatanOrtuC.dispose();
    kabupatenOrtuC.dispose();
    provinsiOrtuC.dispose();
    kodePosOrtuC.dispose();

    super.dispose();
  }

  // Tampilkan overlay saran dusun untuk siswa
  void _showOverlay() {
    _hideOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width * 0.9,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: isLoadingSuggestions
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Mencari dusun...'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: dusunSuggestions.length,
                      itemBuilder: (context, index) {
                        final dusun = dusunSuggestions[index];
                        return InkWell(
                          onTap: () {
                            debugPrint(
                              'Dusun clicked at index $index: ${dusun.toString()}',
                            );
                            _fillAlamatFromDusun(dusun); // Isi otomatis alamat
                            debugPrint(
                              'Calling _fillAlamatFromDusun for dusun: ${dusun['dusun']}',
                            );
                          },
                          splashColor: Colors.blue.withValues(alpha: 0.2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        dusun['dusun']?.toString() ??
                                            'Tidak diketahui',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (dusun['kode_pos'] != null)
                                      Chip(
                                        label: Text(
                                          dusun['kode_pos'].toString(),
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        backgroundColor: Colors.blue.shade50,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${dusun['desa']?.toString() ?? ''}, ${dusun['kecamatan']?.toString() ?? ''}\n${dusun['kabupaten']?.toString() ?? ''}, ${dusun['provinsi']?.toString() ?? ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    debugPrint('Overlay shown with ${dusunSuggestions.length} suggestions');
  }

  // Tampilkan overlay saran dusun untuk orang tua
  void _showOverlayOrtu() {
    _hideOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width * 0.9,
        child: CompositedTransformFollower(
          link: _ortuLayerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: isLoadingSuggestions
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Mencari dusun...'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: ortuSuggestions.length,
                      itemBuilder: (context, index) {
                        final dusun = ortuSuggestions[index];
                        return InkWell(
                          onTap: () {
                            debugPrint('Ortu dusun clicked at index $index: ${dusun.toString()}');
                            _fillAlamatFromOrtu(dusun); // Isi otomatis alamat ortu
                            debugPrint('Calling _fillAlamatFromOrtu for dusun: ${dusun['dusun']}');
                          },
                          splashColor: Colors.blue.withValues(alpha: 0.2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        dusun['dusun']?.toString() ?? 'Tidak diketahui',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (dusun['kode_pos'] != null)
                                      Chip(
                                        label: Text(
                                          dusun['kode_pos'].toString(),
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        backgroundColor: Colors.blue.shade50,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${dusun['desa']?.toString() ?? ''}, ${dusun['kecamatan']?.toString() ?? ''}\n${dusun['kabupaten']?.toString() ?? ''}, ${dusun['provinsi']?.toString() ?? ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    debugPrint('Ortu overlay shown with ${ortuSuggestions.length} suggestions');
  }

  // Sembunyikan overlay saran
  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    debugPrint('Overlay hidden');
  }

  // Isi otomatis field alamat siswa berdasarkan dusun yang dipilih
  void _fillAlamatFromDusun(Map<String, dynamic> selectedDusun) {
    debugPrint('=== _fillAlamatFromDusun called ===');
    debugPrint('Selected dusun data: ${selectedDusun.toString()}');
    debugPrint('Keys in selectedDusun: ${selectedDusun.keys.toList()}');

    setState(() {
      dusunC.text = selectedDusun['dusun']?.toString() ?? '';
      desaC.text = selectedDusun['desa']?.toString() ?? '';
      kecamatanC.text = selectedDusun['kecamatan']?.toString() ?? '';
      kabupatenC.text = selectedDusun['kabupaten']?.toString() ?? '';
      provinsiC.text = selectedDusun['provinsi'].toString().replaceAll('_', ' ');
      kodePosC.text = selectedDusun['kode_pos']?.toString() ?? '';
      debugPrint('Field values set:');
      debugPrint('dusun=${dusunC.text}');
      debugPrint('desa=${desaC.text}');
      debugPrint('kecamatan=${kecamatanC.text}');
      debugPrint('kabupaten=${kabupatenC.text}');
      debugPrint('provinsi=${provinsiC.text}');
      debugPrint('kodePos=${kodePosC.text}');
      // Atur posisi kursor di akhir teks
      dusunC.selection = TextSelection.fromPosition(
        TextPosition(offset: dusunC.text.length),
      );
      desaC.selection = TextSelection.fromPosition(
        TextPosition(offset: desaC.text.length),
      );
      kecamatanC.selection = TextSelection.fromPosition(
        TextPosition(offset: kecamatanC.text.length),
      );
      kabupatenC.selection = TextSelection.fromPosition(
        TextPosition(offset: kabupatenC.text.length),
      );
      provinsiC.selection = TextSelection.fromPosition(
        TextPosition(offset: provinsiC.text.length),
      );
      kodePosC.selection = TextSelection.fromPosition(
        TextPosition(offset: kodePosC.text.length),
      );
    });

    _hideOverlay();
    dusunFocusNode.unfocus();

    // Tampilkan pesan sukses
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Alamat berhasil diisi otomatis untuk ${selectedDusun['dusun'].toString()}',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Isi otomatis field alamat orang tua berdasarkan dusun yang dipilih
  void _fillAlamatFromOrtu(Map<String, dynamic> selectedDusun) {
    debugPrint('=== _fillAlamatFromOrtu called ===');
    debugPrint('Selected ortu dusun data: ${selectedDusun.toString()}');
    debugPrint('Keys in selectedDusun: ${selectedDusun.keys.toList()}');

    setState(() {
      dusunOrtuC.text = selectedDusun['dusun']?.toString() ?? '';
      desaOrtuC.text = selectedDusun['desa']?.toString() ?? '';
      kecamatanOrtuC.text = selectedDusun['kecamatan']?.toString() ?? '';
      kabupatenOrtuC.text = selectedDusun['kabupaten']?.toString() ?? '';
      provinsiOrtuC.text = selectedDusun['provinsi'].toString().replaceAll('_', ' ');
      kodePosOrtuC.text = selectedDusun['kode_pos']?.toString() ?? '';
      debugPrint('Ortu field values set:');
      debugPrint('dusun=${dusunOrtuC.text}');
      debugPrint('desa=${desaOrtuC.text}');
      debugPrint('kecamatan=${kecamatanOrtuC.text}');
      debugPrint('kabupaten=${kabupatenOrtuC.text}');
      debugPrint('provinsi=${provinsiOrtuC.text}');
      debugPrint('kodePos=${kodePosOrtuC.text}');
      // Atur posisi kursor di akhir teks
      dusunOrtuC.selection = TextSelection.fromPosition(
        TextPosition(offset: dusunOrtuC.text.length),
      );
      desaOrtuC.selection = TextSelection.fromPosition(
        TextPosition(offset: desaOrtuC.text.length),
      );
      kecamatanOrtuC.selection = TextSelection.fromPosition(
        TextPosition(offset: kecamatanOrtuC.text.length),
      );
      kabupatenOrtuC.selection = TextSelection.fromPosition(
        TextPosition(offset: kabupatenOrtuC.text.length),
      );
      provinsiOrtuC.selection = TextSelection.fromPosition(
        TextPosition(offset: provinsiOrtuC.text.length),
      );
      kodePosOrtuC.selection = TextSelection.fromPosition(
        TextPosition(offset: kodePosOrtuC.text.length),
      );
    });

    _hideOverlay();
    ortuFocusNode.unfocus();

    // Tampilkan pesan sukses
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Alamat orang tua berhasil diisi otomatis untuk ${selectedDusun['dusun'].toString()}',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Cari dusun untuk siswa dengan debounce
  Future<void> _searchDusun(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        dusunSuggestions = [];
      });
      _hideOverlay();
      return;
    }

    setState(() => isLoadingSuggestions = true);

    try {
      // Tambahkan delay untuk mencegah pencarian berulang yang cepat
      await Future.delayed(const Duration(milliseconds: 300));
      final results = await service.searchDusun(query);

      debugPrint('Raw search results: $results');
      for (var result in results) {
        debugPrint('Dusun entry: ${result.toString()}');
        debugPrint('Keys available: ${result.keys.toList()}');
      }

      _debugDusunData(results); // Log data untuk debugging

      if (mounted) {
        setState(() {
          dusunSuggestions = results;
          isLoadingSuggestions = false;
          debugPrint(
            'Updated dusunSuggestions with ${dusunSuggestions.length} items',
          );
        });

        // Tampilkan overlay jika ada hasil
        if (dusunSuggestions.isNotEmpty) {
          _showOverlay();
        } else {
          _hideOverlay();
          if (query.length > 2) {
            // Tampilkan pesan jika tidak ada hasil setelah query cukup panjang
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tidak ada dusun yang ditemukan'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error searching dusun: $e');
      if (mounted) {
        setState(() => isLoadingSuggestions = false);
        // Tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mencari dusun: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Cari dusun untuk alamat orang tua dengan debounce
  Future<void> _searchOrtu(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        ortuSuggestions = [];
      });
      _hideOverlay();
      return;
    }

    setState(() => isLoadingSuggestions = true);

    try {
      // Tambahkan delay untuk mencegah pencarian berulang yang cepat
      await Future.delayed(const Duration(milliseconds: 300));
      final results = await service.searchDusun(query);

      debugPrint('Raw search results for ortu: $results');
      for (var result in results) {
        debugPrint('Ortu entry: ${result.toString()}');
        debugPrint('Keys available: ${result.keys.toList()}');
      }

      _debugDusunData(results); // Log data untuk debugging

      if (mounted) {
        setState(() {
          ortuSuggestions = results;
          isLoadingSuggestions = false;
          debugPrint('Updated ortuSuggestions with ${ortuSuggestions.length} items');
        });

        // Tampilkan overlay jika ada hasil
        if (ortuSuggestions.isNotEmpty) {
          _showOverlayOrtu();
        } else {
          _hideOverlay();
          if (query.length > 2) {
            // Tampilkan pesan jika tidak ada hasil setelah query cukup panjang
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tidak ada dusun yang ditemukan untuk alamat orang tua'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error searching ortu: $e');
      if (mounted) {
        setState(() => isLoadingSuggestions = false);
        // Tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mencari dusun untuk alamat orang tua: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Log data dusun untuk debugging
  void _debugDusunData(List<Map<String, dynamic>> results) {
    debugPrint('=== DEBUG DUSUN DATA ===');
    debugPrint('Total results: ${results.length}');
    for (int i = 0; i < results.length && i < 3; i++) {
      debugPrint('Result $i: ${results[i].toString()}');
      debugPrint('Keys: ${results[i].keys.toList()}');
    }
    debugPrint('========================');
  }

  // Validasi data berdasarkan langkah saat ini
  bool _validateCurrentStep() {
    switch (currentStep) {
      case 0: // Langkah data pribadi
        if (nisnC.text.isEmpty ||
            namaC.text.isEmpty ||
            selectedJenisKelamin == null ||
            selectedAgama == null ||
            tempatLahirC.text.isEmpty ||
            tanggalLahirC.text.isEmpty ||
            nikC.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Mohon lengkapi semua data pribadi yang wajib diisi (termasuk NIK)',
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return false;
        }
        if (nisnC.text.length != 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('NISN harus 10 digit'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return false;
        }
        if (nikC.text.length != 16) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('NIK harus 16 digit'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return false;
        }
        break;

      case 1: // Langkah alamat
        if (jalanC.text.isEmpty ||
            rtC.text.isEmpty ||
            desaC.text.isEmpty ||
            kabupatenC.text.isEmpty ||
            provinsiC.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Mohon lengkapi data alamat yang wajib diisi (Jalan, RT, Desa, Kabupaten, Provinsi)',
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return false;
        }
        break;

      case 2: // Langkah data orang tua (opsional)
        if (dusunOrtuC.text.isNotEmpty ||
            desaOrtuC.text.isNotEmpty ||
            kecamatanOrtuC.text.isNotEmpty ||
            kabupatenOrtuC.text.isNotEmpty ||
            provinsiOrtuC.text.isNotEmpty ||
            kodePosOrtuC.text.isNotEmpty) {
          if (desaOrtuC.text.isEmpty ||
              kabupatenOrtuC.text.isEmpty ||
              provinsiOrtuC.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Mohon lengkapi data alamat orang tua (Desa, Kabupaten, Provinsi)',
                ),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return false;
          }
        }
        break;
    }
    return true;
  }

  // Simpan data siswa ke Supabase
  Future<void> _simpanData() async {
    // Validasi semua langkah sebelum menyimpan
    for (int i = 0; i <= 2; i++) {
      int tempStep = currentStep;
      currentStep = i;
      if (!_validateCurrentStep()) {
        currentStep = tempStep;
        return;
      }
    }
    currentStep = 2;

    try {
      // Tampilkan indikator loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      );

      // Kumpulkan data dari field
      final data = {
        'nisn': nisnC.text.trim(),
        'nama_lengkap': namaC.text.trim(),
        'jenis_kelamin': selectedJenisKelamin!,
        'agama': selectedAgama!,
        'tempat_lahir': tempatLahirC.text.trim(),
        'tanggal_lahir': tanggalLahirC.text.trim(),
        'nik': nikC.text.trim(),
        'alamat_jalan': jalanC.text.trim(),
        'alamat_rt': rtC.text.trim(),
        'alamat_desa': desaC.text.trim(),
        'alamat_kabupaten': kabupatenC.text.trim(),
        'alamat_provinsi': provinsiC.text.trim(),
        'no_hp': noHpC.text.trim().isEmpty ? null : noHpC.text.trim(),
        'alamat_dusun': dusunC.text.trim().isEmpty ? null : dusunC.text.trim(),
        'alamat_kecamatan':
            kecamatanC.text.trim().isEmpty ? null : kecamatanC.text.trim(),
        'alamat_kode_pos':
            kodePosC.text.trim().isEmpty ? null : kodePosC.text.trim(),
        'nama_ayah': ayahC.text.trim().isEmpty ? null : ayahC.text.trim(),
        'nama_ibu': ibuC.text.trim().isEmpty ? null : ibuC.text.trim(),
        'nama_wali': waliC.text.trim().isEmpty ? null : waliC.text.trim(),
        'alamat_dusun_ortu':
            dusunOrtuC.text.trim().isEmpty ? null : dusunOrtuC.text.trim(),
        'alamat_desa_ortu':
            desaOrtuC.text.trim().isEmpty ? null : desaOrtuC.text.trim(),
        'alamat_kecamatan_ortu':
            kecamatanOrtuC.text.trim().isEmpty ? null : kecamatanOrtuC.text.trim(),
        'alamat_kabupaten_ortu':
            kabupatenOrtuC.text.trim().isEmpty ? null : kabupatenOrtuC.text.trim(),
        'alamat_provinsi_ortu':
            provinsiOrtuC.text.trim().isEmpty ? null : provinsiOrtuC.text.trim(),
        'alamat_kode_pos_ortu':
            kodePosOrtuC.text.trim().isEmpty ? null : kodePosOrtuC.text.trim(),
      };

      // Hapus field yang null atau kosong
      data.removeWhere((key, value) => value == null || value == '');

      // Simpan data ke Supabase
      await service.insertSiswa(data);

      if (mounted) {
        Navigator.of(context).pop();
        // Tampilkan dialog sukses
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 10),
                Text('Berhasil!'),
              ],
            ),
            content: const Text('Data siswa berhasil disimpan'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigasi ke DashboardPage setelah sukses
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardPage()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        // Tampilkan pesan error jika gagal menyimpan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal simpan data: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Bangun UI utama dengan gradient background dan animasi
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(), // Header dengan ikon dan teks
                _buildStepIndicator(), // Indikator langkah
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentStep = index;
                        _hideOverlay(); // Sembunyikan overlay saat ganti halaman
                      });
                    },
                    children: [
                      _buildPersonalInfoStep(), // Langkah data pribadi
                      _buildAddressStep(), // Langkah alamat
                      _buildParentInfoStep(), // Langkah data orang tua
                    ],
                  ),
                ),
                _buildBottomButtons(), // Tombol navigasi
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Bangun header dengan ikon dan teks
  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: isSmallScreen ? 15 : 20,
      ),
      child: Column(
        children: [
          Icon(
            Icons.school,
            size: isSmallScreen ? 40 : 50,
            color: Colors.white,
          ),
          SizedBox(height: isSmallScreen ? 8 : 10),
          Text(
            'Form Data Siswa',
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Lengkapi data diri Anda',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // Bangun indikator langkah
  Widget _buildStepIndicator() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Row(
        children: [
          _buildStepCircle(0, 'Pribadi', Icons.person, isSmallScreen),
          Expanded(child: _buildStepLine(0)),
          _buildStepCircle(1, 'Alamat', Icons.home, isSmallScreen),
          Expanded(child: _buildStepLine(1)),
          _buildStepCircle(
            2,
            'Orang Tua',
            Icons.family_restroom,
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  // Bangun lingkaran untuk indikator langkah
  Widget _buildStepCircle(
    int step,
    String title,
    IconData icon,
    bool isSmallScreen,
  ) {
    bool isActive = currentStep >= step;
    return Column(
      children: [
        Container(
          width: isSmallScreen ? 40 : 50,
          height: isSmallScreen ? 40 : 50,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white30,
            borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 25),
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 18 : 24,
            color: isActive ? const Color(0xFF667eea) : Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white60,
            fontSize: isSmallScreen ? 10 : 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Bangun garis penghubung antar langkah
  Widget _buildStepLine(int step) {
    bool isActive = currentStep > step;
    return Container(
      height: 2,
      color: isActive ? Colors.white : Colors.white30,
      margin: const EdgeInsets.only(bottom: 20),
    );
  }

  // Bangun langkah untuk data pribadi
  Widget _buildPersonalInfoStep() {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Pribadi',
              style: TextStyle(
                fontSize: screenWidth < 360 ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF667eea),
              ),
            ),
            SizedBox(height: screenWidth < 360 ? 15 : 20),
            _buildAnimatedField(
              nisnC,
              'NISN *',
              Icons.badge,
              TextInputType.number,
            ),
            _buildAnimatedField(namaC, 'Nama Lengkap *', Icons.person),
            _buildDropdownField(
              'Jenis Kelamin *',
              selectedJenisKelamin,
              jenisKelamin,
              Icons.wc,
              (value) => setState(() => selectedJenisKelamin = value),
            ),
            _buildDropdownField(
              'Agama *',
              selectedAgama,
              agamaList,
              Icons.mosque,
              (value) => setState(() => selectedAgama = value),
            ),
            _buildAnimatedField(
              tempatLahirC,
              'Tempat Lahir *',
              Icons.location_on,
            ),
            _buildDateField(
              tanggalLahirC,
              'Tanggal Lahir *',
              Icons.calendar_today,
            ),
            _buildAnimatedField(
              noHpC,
              'No HP',
              Icons.phone,
              TextInputType.phone,
            ),
            _buildAnimatedField(
              nikC,
              'NIK (16 digit) *',
              Icons.credit_card,
              TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  // Bangun langkah untuk alamat
  Widget _buildAddressStep() {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alamat Lengkap',
              style: TextStyle(
                fontSize: screenWidth < 360 ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF667eea),
              ),
            ),
            SizedBox(height: screenWidth < 360 ? 15 : 20),
            _buildAnimatedField(jalanC, 'Alamat Jalan *', Icons.home_filled),
            screenWidth > 400
                ? Row(
                    children: [
                      Expanded(
                        child: _buildAnimatedField(
                          rtC,
                          'RT/RW *',
                          Icons.home_work,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: _buildDusunAutoComplete()),
                    ],
                  )
                : Column(
                    children: [
                      _buildAnimatedField(rtC, 'RT/RW *', Icons.home_work),
                      _buildDusunAutoComplete(),
                    ],
                  ),
            _buildReadOnlyField(
              desaC,
              'Desa *',
              Icons.landscape,
              TextInputType.text,
              1,
            ),
            _buildReadOnlyField(
              kecamatanC,
              'Kecamatan',
              Icons.location_city,
              TextInputType.text,
              1,
            ),
            _buildReadOnlyField(
              kabupatenC,
              'Kabupaten *',
              Icons.domain,
              TextInputType.text,
              1,
            ),
            _buildReadOnlyField(
              provinsiC,
              'Provinsi *',
              Icons.map,
              TextInputType.text,
              1,
            ),
            _buildReadOnlyField(
              kodePosC,
              'Kode Pos',
              Icons.local_post_office,
              TextInputType.number,
              1,
            ),
          ],
        ),
      ),
    );
  }

  // Bangun field autocomplete untuk dusun siswa
  Widget _buildDusunAutoComplete() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: dusunC,
          focusNode: dusunFocusNode,
          decoration: InputDecoration(
            labelText: 'Dusun (Ketik untuk mencari)',
            prefixIcon: const Icon(
              Icons.location_city,
              color: Color(0xFF667eea),
            ),
            suffixIcon: isLoadingSuggestions
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            hintText: 'Contoh: Ampelgading',
          ),
          onChanged: (value) {
            debugPrint('Dusun field changed: $value');
            _searchDusun(value); // Cari dusun saat teks berubah
          },
          onTap: () {
            debugPrint('Dusun field tapped');
            if (dusunC.text.isNotEmpty && dusunSuggestions.isNotEmpty) {
              _showOverlay(); // Tampilkan overlay jika ada saran
            }
          },
        ),
      ),
    );
  }

  // Bangun langkah untuk data orang tua
  Widget _buildParentInfoStep() {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Orang Tua/Wali',
              style: TextStyle(
                fontSize: screenWidth < 360 ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF667eea),
              ),
            ),
            SizedBox(height: screenWidth < 360 ? 15 : 20),
            _buildAnimatedField(ayahC, 'Nama Ayah', Icons.man),
            _buildAnimatedField(ibuC, 'Nama Ibu', Icons.woman),
            _buildAnimatedField(waliC, 'Nama Wali', Icons.group),
            _buildOrtuAutoComplete(),
            _buildReadOnlyField(
              desaOrtuC,
              'Desa',
              Icons.landscape,
              TextInputType.text,
              1,
            ),
            _buildReadOnlyField(
              kecamatanOrtuC,
              'Kecamatan',
              Icons.location_city,
              TextInputType.text,
              1,
            ),
            _buildReadOnlyField(
              kabupatenOrtuC,
              'Kabupaten',
              Icons.domain,
              TextInputType.text,
              1,
            ),
            _buildReadOnlyField(
              provinsiOrtuC,
              'Provinsi',
              Icons.map,
              TextInputType.text,
              1,
            ),
            _buildReadOnlyField(
              kodePosOrtuC,
              'Kode Pos',
              Icons.local_post_office,
              TextInputType.number,
              1,
            ),
          ],
        ),
      ),
    );
  }

  // Bangun field autocomplete untuk dusun orang tua
  Widget _buildOrtuAutoComplete() {
    return CompositedTransformTarget(
      link: _ortuLayerLink,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: dusunOrtuC,
          focusNode: ortuFocusNode,
          decoration: InputDecoration(
            labelText: 'Dusun Orang Tua (Ketik untuk mencari)',
            prefixIcon: const Icon(
              Icons.location_city,
              color: Color(0xFF667eea),
            ),
            suffixIcon: isLoadingSuggestions
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            hintText: 'Contoh: Ampelgading',
          ),
          onChanged: (value) {
            debugPrint('Ortu dusun field changed: $value');
            _searchOrtu(value); // Cari dusun saat teks berubah
          },
          onTap: () {
            debugPrint('Ortu dusun field tapped');
            if (dusunOrtuC.text.isNotEmpty && ortuSuggestions.isNotEmpty) {
              _showOverlayOrtu(); // Tampilkan overlay jika ada saran
            }
          },
        ),
      ),
    );
  }

  // Bangun field input dengan animasi
  Widget _buildAnimatedField(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  ]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  // Bangun field readonly
  Widget _buildReadOnlyField(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  ]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  // Bangun dropdown untuk field seperti jenis kelamin dan agama
  Widget _buildDropdownField(
    String label,
    String? selectedValue,
    List<String> items,
    IconData icon,
    void Function(String?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
      ),
    );
  }

  // Bangun field untuk input tanggal dengan date picker
  Widget _buildDateField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onTap: () async {
          // Tampilkan date picker untuk memilih tanggal
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.text =
                "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
          }
        },
      ),
    );
  }

  // Bangun tombol navigasi (Sebelumnya/Selanjutnya/Simpan)
  Widget _buildBottomButtons() {
    final isLastStep = currentStep == 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentStep > 0)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
              ),
              onPressed: () {
                if (currentStep > 0) {
                  setState(() {
                    currentStep--;
                    _hideOverlay(); // Sembunyikan overlay saat mundur
                  });
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: const Text('Sebelumnya'),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
            ),
            onPressed: () {
              if (!isLastStep) {
                if (_validateCurrentStep()) {
                  setState(() {
                    currentStep++;
                    _hideOverlay(); // Sembunyikan overlay saat maju
                  });
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              } else {
                _simpanData(); // Simpan data di langkah terakhir
              }
            },
            child: Text(isLastStep ? 'Simpan' : 'Selanjutnya'),
          ),
        ],
      ),
    );
  }
}
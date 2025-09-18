import 'package:flutter/material.dart';
import 'package:projek_4/service.dart';
import 'package:projek_4/screens/dasboard_page.dart';

class SiswaPage extends StatefulWidget {
  const SiswaPage({super.key});

  @override
  State<SiswaPage> createState() => _SiswaPageState();
}

class _SiswaPageState extends State<SiswaPage> with TickerProviderStateMixin {
  final service = SupabaseService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int currentStep = 0;
  final PageController _pageController = PageController();

  // Controllers
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

  // Dropdown values
  String? selectedJenisKelamin;
  String? selectedAgama;

  // Auto-complete variables
  List<Map<String, dynamic>> dusunSuggestions = [];
  List<Map<String, dynamic>> ortuSuggestions = [];
  bool isLoadingSuggestions = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final LayerLink _ortuLayerLink = LayerLink();
  final FocusNode dusunFocusNode = FocusNode();
  final FocusNode ortuFocusNode = FocusNode();

  final List<String> jenisKelamin = ['Laki-laki', 'Perempuan'];
  final List<String> agamaList = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
  ];

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    dusunFocusNode.dispose();
    ortuFocusNode.dispose();
    _hideOverlay();

    // Dispose all controllers
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

  // Show overlay suggestions untuk dusun siswa
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
                                'Dusun clicked at index $index: ${dusun.toString()}');
                            _fillAlamatFromDusun(dusun);
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
                                        dusun['nama_dusun']?.toString() ??
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
                                  '${dusun['desa']?['nama_desa']?.toString() ?? ''}, ${dusun['desa']?['kecamatan']?['nama_kecamatan']?.toString() ?? ''}\n${dusun['desa']?['kecamatan']?['kabupaten']?['nama_kabupaten']?.toString() ?? ''}, ${dusun['desa']?['kecamatan']?['kabupaten']?['provinsi']?['nama_provinsi']?.toString() ?? ''}',
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

  // Show overlay untuk alamat orang tua
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
                            debugPrint(
                                'Ortu dusun clicked at index $index: ${dusun.toString()}');
                            _fillAlamatFromOrtu(dusun);
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
                                        dusun['nama_dusun']?.toString() ??
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
                                  '${dusun['desa']?['nama_desa']?.toString() ?? ''}, ${dusun['desa']?['kecamatan']?['nama_kecamatan']?.toString() ?? ''}\n${dusun['desa']?['kecamatan']?['kabupaten']?['nama_kabupaten']?.toString() ?? ''}, ${dusun['desa']?['kecamatan']?['kabupaten']?['provinsi']?['nama_provinsi']?.toString() ?? ''}',
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

  // Hide overlay
  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    debugPrint('Overlay hidden');
  }

  // Auto-fill alamat siswa berdasarkan pilihan dusun
  void _fillAlamatFromDusun(Map<String, dynamic> selectedDusun) {
    debugPrint('=== _fillAlamatFromDusun called ===');
    debugPrint('Selected dusun data: ${selectedDusun.toString()}');
    debugPrint('Keys in selectedDusun: ${selectedDusun.keys.toList()}');

    setState(() {
      dusunC.text = selectedDusun['nama_dusun']?.toString() ?? '';
      desaC.text = selectedDusun['desa']?['nama_desa']?.toString() ?? '';
      kecamatanC.text =
          selectedDusun['desa']?['kecamatan']?['nama_kecamatan']?.toString() ??
              '';
      kabupatenC.text =
          selectedDusun['desa']?['kecamatan']?['kabupaten']?['nama_kabupaten']
                  ?.toString() ??
              '';
      provinsiC.text =
          selectedDusun['desa']?['kecamatan']?['kabupaten']?['provinsi']
                  ?['nama_provinsi']?.toString() ??
              '';
      kodePosC.text = selectedDusun['kode_pos']?.toString() ?? '';
      debugPrint('Field values set:');
      debugPrint('dusun=${dusunC.text}');
      debugPrint('desa=${desaC.text}');
      debugPrint('kecamatan=${kecamatanC.text}');
      debugPrint('kabupaten=${kabupatenC.text}');
      debugPrint('provinsi=${provinsiC.text}');
      debugPrint('kodePos=${kodePosC.text}');
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Alamat berhasil diisi otomatis untuk ${selectedDusun['nama_dusun'].toString()}',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Auto-fill alamat orang tua berdasarkan pilihan dusun
  void _fillAlamatFromOrtu(Map<String, dynamic> selectedDusun) {
    debugPrint('=== _fillAlamatFromOrtu called ===');
    debugPrint('Selected ortu dusun data: ${selectedDusun.toString()}');
    debugPrint('Keys in selectedDusun: ${selectedDusun.keys.toList()}');

    setState(() {
      dusunOrtuC.text = selectedDusun['nama_dusun']?.toString() ?? '';
      desaOrtuC.text = selectedDusun['desa']?['nama_desa']?.toString() ?? '';
      kecamatanOrtuC.text =
          selectedDusun['desa']?['kecamatan']?['nama_kecamatan']?.toString() ??
              '';
      kabupatenOrtuC.text =
          selectedDusun['desa']?['kecamatan']?['kabupaten']?['nama_kabupaten']
                  ?.toString() ??
              '';
      provinsiOrtuC.text =
          selectedDusun['desa']?['kecamatan']?['kabupaten']?['provinsi']
                  ?['nama_provinsi']?.toString() ??
              '';
      kodePosOrtuC.text = selectedDusun['kode_pos']?.toString() ?? '';
      debugPrint('Ortu field values set:');
      debugPrint('dusun=${dusunOrtuC.text}');
      debugPrint('desa=${desaOrtuC.text}');
      debugPrint('kecamatan=${kecamatanOrtuC.text}');
      debugPrint('kabupaten=${kabupatenOrtuC.text}');
      debugPrint('provinsi=${provinsiOrtuC.text}');
      debugPrint('kodePos=${kodePosOrtuC.text}');
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Alamat orang tua berhasil diisi otomatis untuk ${selectedDusun['nama_dusun'].toString()}',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Search dusun dengan debounce
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
      await Future.delayed(const Duration(milliseconds: 300));
      final results = await service.searchDusun(query);

      debugPrint('Raw search results: $results');
      for (var result in (results['data'] as List<dynamic>)) {
        debugPrint('Dusun entry: ${result.toString()}');
        debugPrint('Keys available: ${(result as Map<String, dynamic>).keys.toList()}');
      }

      _debugDusunData(results['data'] as List<Map<String, dynamic>>);

      if (mounted) {
        setState(() {
          dusunSuggestions =
              List<Map<String, dynamic>>.from(results['data'] ?? []);
          isLoadingSuggestions = false;
          debugPrint(
              'Updated dusunSuggestions with ${dusunSuggestions.length} items');
        });

        if (results['success'] == false) {
          _hideOverlay();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(results['message'] ?? 'Error mencari dusun'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (dusunSuggestions.isNotEmpty) {
          _showOverlay();
        } else {
          _hideOverlay();
          if (query.length > 2) {
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

  // Search alamat orang tua dengan debounce
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
      await Future.delayed(const Duration(milliseconds: 300));
      final results = await service.searchDusun(query);

      debugPrint('Raw search results for ortu: $results');
      for (var result in (results['data'] as List<dynamic>)) {
        debugPrint('Ortu entry: ${result.toString()}');
        debugPrint('Keys available: ${(result as Map<String, dynamic>).keys.toList()}');
      }

      _debugDusunData(results['data'] as List<Map<String, dynamic>>);

      if (mounted) {
        setState(() {
          ortuSuggestions =
              List<Map<String, dynamic>>.from(results['data'] ?? []);
          isLoadingSuggestions = false;
          debugPrint(
              'Updated ortuSuggestions with ${ortuSuggestions.length} items');
        });

        if (results['success'] == false) {
          _hideOverlay();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(results['message'] ?? 'Error mencari dusun orang tua'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (ortuSuggestions.isNotEmpty) {
          _showOverlayOrtu();
        } else {
          _hideOverlay();
          if (query.length > 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Tidak ada dusun yang ditemukan untuk alamat orang tua'),
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

  // Debug data dusun
  void _debugDusunData(List<Map<String, dynamic>> results) {
    debugPrint('=== DEBUG DUSUN DATA ===');
    debugPrint('Total results: ${results.length}');
    for (int i = 0; i < results.length && i < 3; i++) {
      debugPrint('Result $i: ${results[i].toString()}');
      debugPrint('Keys: ${results[i].keys.toList()}');
    }
    debugPrint('========================');
  }

  // Validation function
  bool _validateCurrentStep() {
    switch (currentStep) {
      case 0: // Personal Info
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

      case 1: // Address
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

      case 2: // Parent Info - Optional
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

  Future<void> _simpanData() async {
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      );

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

      data.removeWhere((key, value) => value == null || value == '');

      final response = await service.insertSiswa(data);

      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog loading
        if (response['success'] == true) {
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Gagal simpan data'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog loading
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
                _buildHeader(),
                _buildStepIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentStep = index;
                        _hideOverlay();
                      });
                    },
                    children: [
                      _buildPersonalInfoStep(),
                      _buildAddressStep(),
                      _buildParentInfoStep(),
                    ],
                  ),
                ),
                _buildBottomButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildStepCircle(
      int step, String title, IconData icon, bool isSmallScreen) {
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

  Widget _buildStepLine(int step) {
    bool isActive = currentStep > step;
    return Container(
      height: 2,
      color: isActive ? Colors.white : Colors.white30,
      margin: const EdgeInsets.only(bottom: 20),
    );
  }

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
                          'RT *',
                          Icons.home_work,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: _buildDusunAutoComplete()),
                    ],
                  )
                : Column(
                    children: [
                      _buildAnimatedField(rtC, 'RT *', Icons.home_work),
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
            _searchDusun(value);
          },
          onTap: () {
            debugPrint('Dusun field tapped');
            if (dusunC.text.isNotEmpty && dusunSuggestions.isNotEmpty) {
              _showOverlay();
            }
          },
        ),
      ),
    );
  }

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
            _searchOrtu(value);
          },
          onTap: () {
            debugPrint('Ortu dusun field tapped');
            if (dusunOrtuC.text.isNotEmpty && ortuSuggestions.isNotEmpty) {
              _showOverlayOrtu();
            }
          },
        ),
      ),
    );
  }

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
                    _hideOverlay();
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
                    _hideOverlay();
                  });
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              } else {
                _simpanData();
              }
            },
            child: Text(isLastStep ? 'Simpan' : 'Selanjutnya'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:projek_4/service.dart';
import 'package:projek_4/screens/dasboard_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final service = SupabaseService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int currentStep = 0;
  final PageController _pageController = PageController();

  // Controllers
  final TextEditingController nisnC = TextEditingController();
  final TextEditingController namaC = TextEditingController();
  final TextEditingController jkC = TextEditingController();
  final TextEditingController agamaC = TextEditingController();
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
  final TextEditingController ayahC = TextEditingController();
  final TextEditingController ibuC = TextEditingController();
  final TextEditingController waliC = TextEditingController();
  final TextEditingController alamatOrtuC = TextEditingController();

  // Dropdown values
  String? selectedJenisKelamin;
  String? selectedAgama;

  final List<String> jenisKelamin = ['Laki-laki', 'Perempuan'];
  final List<String> agamaList = ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'];

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
    
    // Dispose all controllers
    nisnC.dispose();
    namaC.dispose();
    jkC.dispose();
    agamaC.dispose();
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
    ayahC.dispose();
    ibuC.dispose();
    waliC.dispose();
    alamatOrtuC.dispose();
    
    super.dispose();
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
            nikC.text.isEmpty) { // NIK is required!
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mohon lengkapi semua data pribadi yang wajib diisi (termasuk NIK)'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return false;
        }
        
        // Validate NISN length (10 digits)
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
        
        // Validate NIK length (16 digits)
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
            rtC.text.isEmpty ||  // RT is required!
            desaC.text.isEmpty || 
            kabupatenC.text.isEmpty || 
            provinsiC.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mohon lengkapi data alamat yang wajib diisi (Jalan, RT, Desa, Kabupaten, Provinsi)'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return false;
        }
        break;
        
      case 2: // Parent Info - Optional based on schema
        // All parent data is optional in database
        break;
    }
    return true;
  }

  Future<void> _simpanData() async {
    // Validate all steps before saving
    for (int i = 0; i <= 2; i++) {
      int tempStep = currentStep;
      currentStep = i;
      if (!_validateCurrentStep()) {
        currentStep = tempStep;
        return;
      }
    }
    currentStep = 2; // Reset to final step
    
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      );

      // Prepare data - sesuai EXACT dengan struktur database
      final data = {
        // Data Utama Siswa (semua required)
        'nisn': nisnC.text.trim(),
        'nama_lengkap': namaC.text.trim(),
        'jenis_kelamin': selectedJenisKelamin!,  // Must not be null
        'agama': selectedAgama!,                 // Must not be null  
        'tempat_lahir': tempatLahirC.text.trim(),
        'tanggal_lahir': tanggalLahirC.text.trim(),
        'nik': nikC.text.trim(),                 // Required!
        
        // Alamat Siswa (jalan, rt, desa, kab, prov required)
        'alamat_jalan': jalanC.text.trim(),      // Required!
        'alamat_rt': rtC.text.trim(),            // Required!
        'alamat_desa': desaC.text.trim(),        // Required!
        'alamat_kabupaten': kabupatenC.text.trim(), // Required!
        'alamat_provinsi': provinsiC.text.trim(),   // Required!
        
        // Optional fields
        'no_hp': noHpC.text.trim().isEmpty ? null : noHpC.text.trim(),
        'alamat_dusun': dusunC.text.trim().isEmpty ? null : dusunC.text.trim(),
        'alamat_kode_pos': kodePosC.text.trim().isEmpty ? null : kodePosC.text.trim(),
        'nama_ayah': ayahC.text.trim().isEmpty ? null : ayahC.text.trim(),
        'nama_ibu': ibuC.text.trim().isEmpty ? null : ibuC.text.trim(),
        'nama_wali': waliC.text.trim().isEmpty ? null : waliC.text.trim(),
        'alamat_orang_tua': alamatOrtuC.text.trim().isEmpty ? null : alamatOrtuC.text.trim(),
      };

      // Remove null values to avoid database issues
      data.removeWhere((key, value) => value == null || value == '');

      print('Data yang akan dikirim: $data'); // Debug log

      await service.insertSiswa(data);
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading

        // Show success dialog
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
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        print('Error detail: $e'); // Debug log
        
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
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
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
          _buildStepCircle(2, 'Orang Tua', Icons.family_restroom, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String title, IconData icon, bool isSmallScreen) {
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
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 10,
      ),
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
            _buildAnimatedField(nisnC, 'NISN *', Icons.badge, TextInputType.number),
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
            _buildAnimatedField(tempatLahirC, 'Tempat Lahir *', Icons.location_on),
            _buildDateField(tanggalLahirC, 'Tanggal Lahir *', Icons.calendar_today),
            _buildAnimatedField(noHpC, 'No HP', Icons.phone, TextInputType.phone),
            _buildAnimatedField(nikC, 'NIK (16 digit) *', Icons.credit_card, TextInputType.number),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressStep() {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 10,
      ),
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
            // Responsive Row untuk RT dan Dusun
            screenWidth > 400 
                ? Row(
                    children: [
                      Expanded(child: _buildAnimatedField(rtC, 'RT *', Icons.home_work)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildAnimatedField(dusunC, 'Dusun', Icons.location_city)),
                    ],
                  )
                : Column(
                    children: [
                      _buildAnimatedField(rtC, 'RT *', Icons.home_work),
                      _buildAnimatedField(dusunC, 'Dusun', Icons.location_city),
                    ],
                  ),
            _buildAnimatedField(desaC, 'Desa *', Icons.landscape),
            _buildAnimatedField(kabupatenC, 'Kabupaten *', Icons.domain),
            _buildAnimatedField(provinsiC, 'Provinsi *', Icons.map),
            _buildAnimatedField(kodePosC, 'Kode Pos', Icons.local_post_office, TextInputType.number),
          ],
        ),
      ),
    );
  }

  Widget _buildParentInfoStep() {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 10,
      ),
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
            _buildAnimatedField(waliC, 'Nama Wali', Icons.person_outline),
            _buildAnimatedField(alamatOrtuC, 'Alamat Orang Tua/Wali', Icons.home_filled),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedField(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType? keyboardType,
    int maxLines = 1,
  ]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
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
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
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
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1980),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF667eea),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
          }
        },
      ),
    );
  }

  Widget _buildBottomButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: isSmallScreen ? 15 : 20,
      ),
      child: screenWidth > 400 
          ? Row(
              children: [
                if (currentStep > 0)
                  Expanded(
                    child: _buildButton(
                      'Sebelumnya',
                      () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      isSecondary: true,
                    ),
                  ),
                if (currentStep > 0) const SizedBox(width: 10),
                Expanded(
                  child: _buildButton(
                    currentStep == 2 ? 'Simpan Data' : 'Selanjutnya',
                    currentStep == 2 ? _simpanData : () {
                      if (_validateCurrentStep()) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
              ],
            )
          : Column(
              children: [
                _buildButton(
                  currentStep == 2 ? 'Simpan Data' : 'Selanjutnya',
                  currentStep == 2 ? _simpanData : () {
                    if (_validateCurrentStep()) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
                if (currentStep > 0) const SizedBox(height: 10),
                if (currentStep > 0)
                  _buildButton(
                    'Sebelumnya',
                    () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    isSecondary: true,
                  ),
              ],
            ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, {bool isSecondary = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.white30 : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSecondary ? Colors.white : const Color(0xFF667eea),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
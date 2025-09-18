import 'package:flutter/material.dart';
import 'package:projek_4/service.dart';
import 'package:projek_4/home/siswa_page.dart'; // Pastikan impor ini sesuai dengan lokasi file siswa_page.dart

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final SupabaseService service = SupabaseService();
  List<Map<String, dynamic>> siswaList = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final data = await service.fetchSiswa();
      setState(() {
        siswaList = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get filteredSiswa {
    if (searchQuery.isEmpty) return siswaList;
    return siswaList.where((siswa) {
      final nama = siswa['nama_lengkap']?.toString().toLowerCase() ?? '';
      final nisn = siswa['nisn']?.toString().toLowerCase() ?? '';
      final query = searchQuery.toLowerCase();
      return nama.contains(query) || nisn.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsCards(),
          Expanded(
            child: isLoading ? _buildLoadingWidget() : _buildDataList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SplashScreen(), 
            ),
          );
          if (result == true) {
            _loadData(); // Muat ulang data jika data berhasil disimpan dari SiswaPage
          }
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Dashboard Siswa',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.orange,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadData,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: const InputDecoration(
          hintText: 'Cari berdasarkan nama atau NISN...',
          prefixIcon: Icon(Icons.search, color: Colors.orange),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Siswa',
              siswaList.length.toString(),
              Icons.people,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Ditampilkan',
              filteredSiswa.length.toString(),
              Icons.visibility,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.orange),
          SizedBox(height: 16),
          Text('Memuat data siswa...'),
        ],
      ),
    );
  }

  Widget _buildDataList() {
    if (filteredSiswa.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              siswaList.isEmpty ? Icons.inbox : Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              siswaList.isEmpty 
                  ? 'Belum ada data siswa'
                  : 'Tidak ada hasil pencarian',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              siswaList.isEmpty
                  ? 'Tambahkan siswa baru dengan menekan tombol +'
                  : 'Coba kata kunci yang berbeda',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredSiswa.length,
      itemBuilder: (context, index) {
        final siswa = filteredSiswa[index];
        return _buildSiswaCard(siswa);
      },
    );
  }

  Widget _buildSiswaCard(Map<String, dynamic> siswa) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailDialog(siswa),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                    radius: 25,
                    child: Text(
                      siswa['nama_lengkap']?.toString().substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          siswa['nama_lengkap'] ?? 'Tidak ada nama',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'NISN: ${siswa['nisn'] ?? '-'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onSelected: (value) {
                      switch (value) {
                        case 'detail':
                          _showDetailDialog(siswa);
                          break;
                        case 'edit':
                          _showEditDialog(siswa);
                          break;
                        case 'delete':
                          _showDeleteDialog(siswa);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'detail',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Lihat Detail'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    siswa['jenis_kelamin'] ?? 'N/A',
                    siswa['jenis_kelamin'] == 'Laki-laki' ? Icons.male : Icons.female,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    siswa['agama'] ?? 'N/A',
                    Icons.mosque,
                    Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${siswa['dusun_siswa']?['nama_dusun'] ?? ''}, ${siswa['dusun_siswa']?['desa']?['nama_desa'] ?? ''}, ${siswa['dusun_siswa']?['desa']?['kecamatan']?['kabupaten']?['provinsi']?['nama_provinsi'] ?? ''}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> siswa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.orange,
              radius: 20,
              child: Text(
                siswa['nama_lengkap']?.toString().substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                siswa['nama_lengkap'] ?? 'Detail Siswa',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailSection('Data Pribadi', [
                  _buildDetailItem('NISN', siswa['nisn']),
                  _buildDetailItem('Nama Lengkap', siswa['nama_lengkap']),
                  _buildDetailItem('Jenis Kelamin', siswa['jenis_kelamin']),
                  _buildDetailItem('Agama', siswa['agama']),
                  _buildDetailItem('Tempat Lahir', siswa['tempat_lahir']),
                  _buildDetailItem('Tanggal Lahir', siswa['tanggal_lahir']),
                  _buildDetailItem('NIK', siswa['nik']),
                  _buildDetailItem('No HP', siswa['no_hp']),
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('Alamat Siswa', [
                  _buildDetailItem('Jalan', siswa['alamat_jalan']),
                  _buildDetailItem('RT', siswa['alamat_rt']),
                  _buildDetailItem('Dusun', siswa['alamat_dusun']),
                  _buildDetailItem('Desa', siswa['alamat_desa']),
                  _buildDetailItem('Kecamatan', siswa['alamat_kecamatan']),
                  _buildDetailItem('Kabupaten', siswa['alamat_kabupaten']),
                  _buildDetailItem('Provinsi', siswa['alamat_provinsi']),
                  _buildDetailItem('Kode Pos', siswa['alamat_kode_pos']),
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('Data Orang Tua/Wali', [
                  _buildDetailItem('Nama Ayah', siswa['nama_ayah']),
                  _buildDetailItem('Nama Ibu', siswa['nama_ibu']),
                  _buildDetailItem('Nama Wali', siswa['nama_wali']),
                  _buildDetailItem('Dusun', siswa['alamat_dusun_ortu']),
                  _buildDetailItem('Desa', siswa['alamat_desa_ortu']),
                  _buildDetailItem('Kecamatan', siswa['alamat_kecamatan_ortu']),
                  _buildDetailItem('Kabupaten', siswa['alamat_kabupaten_ortu']),
                  _buildDetailItem('Provinsi', siswa['alamat_provinsi_ortu']),
                  _buildDetailItem('Kode Pos', siswa['alamat_kode_pos_ortu']),
                ]),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditDialog(siswa);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Edit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, dynamic value) {
    final displayValue = value?.toString().isNotEmpty == true ? value.toString() : 'Tidak diisi';
    final isEmpty = value?.toString().isEmpty != false;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: TextStyle(
                color: isEmpty ? Colors.grey : Colors.black,
                fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NEW IMPROVED EDIT DIALOG METHOD
  void _showEditDialog(Map<String, dynamic> siswa) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (context) => _EditDialog(
        siswa: siswa,
        service: service,
        onSuccess: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data berhasil diupdate'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            _loadData();
          }
        },
        onError: (String error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal update: $error'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> siswa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Konfirmasi Hapus'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus data siswa "${siswa['nama_lengkap']}"?\n\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await service.deleteSiswa(siswa['id']);
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data berhasil dihapus'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  _loadData();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal hapus: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// SEPARATE EDIT DIALOG WIDGET WITH AUTOFILL FEATURE
class _EditDialog extends StatefulWidget {
  final Map<String, dynamic> siswa;
  final SupabaseService service;
  final VoidCallback onSuccess;
  final Function(String) onError;

  const _EditDialog({
    required this.siswa,
    required this.service,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  final Map<String, TextEditingController> controllers = {};
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? selectedJenisKelamin;
  String? selectedAgama;
  bool isLoading = false;
  
  // Autofill data
  List<Map<String, dynamic>> dusunList = [];
  Map<String, dynamic>? selectedDusun;
  bool isLoadingDusun = false;

  @override
  void initState() {
    super.initState();
    // Initialize all controllers with existing data
    widget.siswa.forEach((key, value) {
      controllers[key] = TextEditingController(text: value?.toString() ?? '');
    });
    
    selectedJenisKelamin = widget.siswa['jenis_kelamin'];
    selectedAgama = widget.siswa['agama'];
    
    // Load dusun data for autofill
    _loadDusunData();
  }

  @override
  void dispose() {
    // Properly dispose all controllers
    controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadDusunData() async {
    setState(() => isLoadingDusun = true);
    try {
      final data = await widget.service.fetchDusunWithRelations();
      setState(() {
        dusunList = data;
        isLoadingDusun = false;
      });
    } catch (e) {
      setState(() => isLoadingDusun = false);
      print('Error loading dusun data: $e');
    }
  }

  void _onDusunSelected(Map<String, dynamic>? dusun) {
    setState(() {
      selectedDusun = dusun;
      if (dusun != null) {
        // Autofill related fields
        controllers['alamat_dusun']?.text = dusun['nama_dusun'] ?? '';
        controllers['alamat_desa']?.text = dusun['desa']?['nama_desa'] ?? '';
        controllers['alamat_kecamatan']?.text = dusun['desa']?['kecamatan']?['nama_kecamatan'] ?? '';
        controllers['alamat_kabupaten']?.text = dusun['desa']?['kecamatan']?['kabupaten']?['nama_kabupaten'] ?? '';
        controllers['alamat_provinsi']?.text = dusun['desa']?['kecamatan']?['kabupaten']?['provinsi']?['nama_provinsi'] ?? '';
        controllers['alamat_dusun_ortu']?.text = dusun['nama_dusun'] ?? '';
        controllers['alamat_desa_ortu']?.text = dusun['desa']?['nama_desa'] ?? '';
        controllers['alamat_kecamatan_ortu']?.text = dusun['desa']?['kecamatan']?['nama_kecamatan'] ?? '';
        controllers['alamat_kabupaten_ortu']?.text = dusun['desa']?['kecamatan']?['kabupaten']?['nama_kabupaten'] ?? '';
        controllers['alamat_provinsi_ortu']?.text = dusun['desa']?['kecamatan']?['kabupaten']?['provinsi']?['nama_provinsi'] ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Data Siswa'),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildEditField(controllers['nama_lengkap']!, 'Nama Lengkap'),
                _buildEditField(controllers['nisn']!, 'NISN'),
                _buildEditDropdown(
                  'Jenis Kelamin',
                  selectedJenisKelamin,
                  ['Laki-laki', 'Perempuan'],
                  (value) => setState(() => selectedJenisKelamin = value),
                ),
                _buildEditDropdown(
                  'Agama',
                  selectedAgama,
                  ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'],
                  (value) => setState(() => selectedAgama = value),
                ),
                _buildEditField(controllers['tempat_lahir']!, 'Tempat Lahir'),
                _buildEditField(controllers['tanggal_lahir']!, 'Tanggal Lahir'),
                _buildEditField(controllers['alamat_jalan']!, 'Jalan'),
                _buildEditField(controllers['alamat_rt']!, 'RT'),
                
                // DUSUN DROPDOWN WITH AUTOFILL
                _buildDusunDropdown(),
                
                // These fields will be auto-filled when dusun is selected
                _buildEditField(controllers['alamat_dusun_ortu']!, 'Dusun Ortu', readOnly: true),
                _buildEditField(controllers['alamat_desa_ortu']!, 'Desa Ortu', readOnly: true),
                _buildEditField(controllers['alamat_kecamatan_ortu']!, 'Kecamatan Ortu', readOnly: true),
                _buildEditField(controllers['alamat_kabupaten_ortu']!, 'Kabupaten Ortu', readOnly: true),
                _buildEditField(controllers['alamat_provinsi_ortu']!, 'Provinsi Ortu', readOnly: true),
                
                _buildEditField(controllers['nama_ayah']!, 'Nama Ayah'),
                _buildEditField(controllers['nama_ibu']!, 'Nama Ibu'),
                _buildEditField(controllers['nama_wali']!, 'Nama Wali'),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _handleSave,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: isLoading 
              ? const SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Simpan', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildDusunDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<Map<String, dynamic>>(
        value: selectedDusun,
        decoration: const InputDecoration(
          labelText: 'Dusun (Autofill Alamat)',
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
          ),
          prefixIcon: Icon(Icons.location_on, color: Colors.orange),
        ),
        hint: isLoadingDusun 
            ? const Row(
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('Memuat dusun...'),
                ],
              )
            : const Text('Pilih Dusun untuk Autofill'),
        items: dusunList.map((dusun) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: dusun,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dusun['nama_dusun'] ?? 'Unknown Dusun',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${dusun['desa']?['nama_desa'] ?? ''}, ${dusun['desa']?['kecamatan']?['nama_kecamatan'] ?? ''}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: isLoading ? null : _onDusunSelected,
        isExpanded: true,
        menuMaxHeight: 200,
      ),
    );
  }

  Widget _buildEditField(TextEditingController controller, String label, {bool readOnly = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: !isLoading,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
          ),
          filled: readOnly,
          fillColor: readOnly ? Colors.grey[100] : null,
          prefixIcon: readOnly ? const Icon(Icons.lock, color: Colors.grey, size: 20) : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            if (label == 'NISN' || label == 'Nama Lengkap' || label == 'Jalan' || label == 'RT') {
              return '$label wajib diisi';
            }
          }
          if (label == 'NISN' && value != null && value.length != 10) {
            return 'NISN harus 10 digit';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildEditDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: isLoading ? null : onChanged,
        validator: (value) => value == null ? '$label wajib dipilih' : null,
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    setState(() => isLoading = true);

    try {
      final updatedData = <String, dynamic>{};
      controllers.forEach((key, controller) {
        if (controller.text.isNotEmpty) {
          updatedData[key] = controller.text;
        }
      });

      if (selectedJenisKelamin != null) {
        updatedData['jenis_kelamin'] = selectedJenisKelamin;
      }
      if (selectedAgama != null) {
        updatedData['agama'] = selectedAgama;
      }

      await widget.service.updateSiswa(widget.siswa['id'], updatedData);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess();
      }
    } catch (e) {
      setState(() => isLoading = false);
      widget.onError(e.toString());
    }
  }
}
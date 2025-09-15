import 'package:flutter/material.dart';
import 'package:projek_4/service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final service = SupabaseService();
  List<Map<String, dynamic>> siswaList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final data = await service.fetchSiswa();
    setState(() {
      siswaList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Data Siswa'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: siswaList.length,
          itemBuilder: (context, index) {
            final siswa = siswaList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(siswa['nama_lengkap'] ?? '-'),
                subtitle: Text(
                    'NISN: ${siswa['nisn'] ?? '-'}\nHP: ${siswa['no_hp'] ?? '-'}'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            );
          },
        ),
      ),
    );
  }
}

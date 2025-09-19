import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projek_4/screens/dasboard_page.dart';

void main() async {
  // supaya bisa async sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();

  // inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://utwtvbusdebgilszdgdo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV0d3R2YnVzZGViZ2lsc3pkZ2RvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MDg4MDYsImV4cCI6MjA3MzQ4NDgwNn0.W7Wtx6lMcI6qTJ9iQOgqOQs9GzfN02iyoGHaQ1UpJjU',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Halaman Dasboard Data Siswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DashboardPage(), // halaman pertama yang muncul
    );
  }
}

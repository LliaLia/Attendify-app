import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'login.dart'; // Menghubungkan ke file login.dart
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // 1. Memastikan binding widget siap
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi date_symbol_data_local untuk format tanggal
  initializeDateFormatting('id_ID', null);
  // 2. Inisialisasi Supabase
  // Ganti URL dan ANON_KEY dengan data dari Project Settings > API di Dashboard Supabase Anda
  await Supabase.initialize(
    url: 'https://iefnwebvtugvuuizchbv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImllZm53ZWJ2dHVndnV1aXpjaGJ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc4NTgzMjgsImV4cCI6MjA4MzQzNDMyOH0.JcSvTxSqn_FQ83kzyhYIrUdiEiR_g-7vzSe5vR8pS4k',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Absensi GPS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Tema warna hijau sesuai keinginan Anda
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF99C499)),
        useMaterial3: true,
      ),
      // Diarahkan ke LoginSosialPage yang ada di login.dart
      home: const LoginSosialPage(),
    );
  }
}
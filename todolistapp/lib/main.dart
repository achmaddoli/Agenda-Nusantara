// Mengimpor library dart:io untuk mengecek sistem operasi yang digunakan
import 'dart:io';

// Mengimpor package Flutter Material untuk membuat tampilan aplikasi
import 'package:flutter/material.dart';

// Mengimpor package sqflite_common_ffi untuk menjalankan database SQLite di Windows dan Linux
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Mengimpor package intl untuk mengaktifkan format tanggal sesuai bahasa tertentu
import 'package:intl/date_symbol_data_local.dart';

// Mengimpor package Google Fonts untuk menggunakan font dari Google
import 'package:google_fonts/google_fonts.dart';

// Mengimpor halaman login sebagai halaman pertama aplikasi
import 'login_page.dart';

// Fungsi main adalah fungsi pertama yang dijalankan saat aplikasi dibuka
void main() async {
  // Memastikan semua komponen Flutter sudah siap sebelum aplikasi dijalankan
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi database untuk sistem operasi Windows dan Linux
  // Bagian ini diperlukan karena sqflite biasa lebih umum digunakan di Android/iOS
  if (Platform.isWindows || Platform.isLinux) {
    // Mengaktifkan sqflite FFI
    sqfliteFfiInit();

    // Mengatur databaseFactory agar menggunakan databaseFactoryFfi
    databaseFactory = databaseFactoryFfi;
  }

  // Inisialisasi format tanggal bahasa Indonesia
  // Contohnya agar nama hari dan bulan bisa tampil dalam bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  // Menjalankan aplikasi Flutter
  runApp(const MyApp());
}

// Class MyApp adalah class utama yang mengatur aplikasi secara keseluruhan
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Judul aplikasi
      title: 'Agenda Nusantara',

      // Menghilangkan tulisan debug di pojok kanan atas aplikasi
      debugShowCheckedModeBanner: false,

      // Mengatur tema atau tampilan umum aplikasi
      theme: ThemeData(
        // Menggunakan desain Material 3
        useMaterial3: true,

        // Mengatur warna utama aplikasi berdasarkan warna orange
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          primary: Colors.orange,
          secondary: Colors.grey,
        ),

        // Mengatur font aplikasi menggunakan font Montserrat dari Google Fonts
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
      ),

      // Menentukan halaman pertama yang ditampilkan saat aplikasi dibuka
      home: const LoginPage(),
    );
  }
}

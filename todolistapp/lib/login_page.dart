// Mengimpor package Flutter Material untuk membuat tampilan aplikasi
import 'package:flutter/material.dart';

// Mengimpor halaman HomePage, yaitu halaman yang akan dibuka setelah login berhasil
import 'home_page.dart';

// Mengimpor DatabaseHelper untuk melakukan proses login ke database
import 'database_helper.dart';

// Class LoginPage adalah halaman login aplikasi
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Class _LoginPageState berisi logika dan tampilan dari halaman login
class _LoginPageState extends State<LoginPage> {
  // Controller untuk mengambil teks yang diketik pada field username
  final TextEditingController _usernameController = TextEditingController();

  // Controller untuk mengambil teks yang diketik pada field password
  final TextEditingController _passwordController = TextEditingController();

  // Membuat objek DatabaseHelper untuk memeriksa data login dari database
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Fungsi untuk menangani proses login
  void _handleLogin() async {
    // Mengambil isi teks dari input username
    String username = _usernameController.text;

    // Mengambil isi teks dari input password
    String password = _passwordController.text;

    // Memeriksa username dan password ke database
    final user = await _dbHelper.login(username, password);

    // Jika user ditemukan, berarti login berhasil
    if (user != null) {
      // Berpindah ke halaman HomePage atau Beranda
      // pushReplacement digunakan agar halaman login tidak bisa kembali lagi dengan tombol back
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Jika user tidak ditemukan, tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau Password salah!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengatur warna latar belakang halaman login
      backgroundColor: Colors.white,

      // Isi utama halaman diletakkan di tengah layar
      body: Center(
        child: SingleChildScrollView(
          // Memberi jarak kiri dan kanan pada isi halaman
          padding: const EdgeInsets.symmetric(horizontal: 30),

          child: Column(
            // Membuat semua widget berada di tengah secara vertikal
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              // 1. Menampilkan logo aplikasi
              Image.asset('assets/images/logo.png', height: 120),

              // Memberi jarak antara logo dan nama aplikasi
              const SizedBox(height: 24),

              // 2. Menampilkan nama aplikasi
              const Text(
                'AGENDA NUSANTARA',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.orange,
                ),
              ),

              // Menampilkan teks keterangan aplikasi
              const Text(
                'Productivity by PT. SDM',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),

              // Memberi jarak sebelum field username
              const SizedBox(height: 48),

              // 3. Field untuk memasukkan username
              TextField(
                // Menghubungkan TextField dengan controller username
                controller: _usernameController,

                // Mengatur tampilan field username
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Username',

                  // Menampilkan ikon orang di sebelah kiri field
                  prefixIcon: const Icon(Icons.person_outline),

                  // Membuat border field dengan sudut melengkung
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Memberi jarak antara field username dan password
              const SizedBox(height: 16),

              // 4. Field untuk memasukkan password
              TextField(
                // Menghubungkan TextField dengan controller password
                controller: _passwordController,

                // Membuat teks password menjadi tersembunyi
                obscureText: true,

                // Mengatur tampilan field password
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Password',

                  // Menampilkan ikon kunci di sebelah kiri field
                  prefixIcon: const Icon(Icons.lock_outline),

                  // Membuat border field dengan sudut melengkung
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Memberi jarak sebelum tombol login
              const SizedBox(height: 32),

              // 5. Tombol login
              SizedBox(
                // Membuat tombol memenuhi lebar layar yang tersedia
                width: double.infinity,

                // Mengatur tinggi tombol
                height: 50,

                child: ElevatedButton(
                  // Ketika tombol ditekan, fungsi _handleLogin akan dijalankan
                  onPressed: _handleLogin,

                  // Mengatur tampilan tombol
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,

                    // Membuat sudut tombol menjadi melengkung
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  // Teks yang ditampilkan pada tombol
                  child: const Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Memberi jarak antara tombol dan teks copyright
              const SizedBox(height: 24),

              // Menampilkan teks copyright di bagian bawah
              const Text(
                '© 2024 PT. Sumber Daya Makmur',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
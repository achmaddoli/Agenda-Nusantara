// Mengimpor package Flutter Material untuk membuat tampilan aplikasi
import 'package:flutter/material.dart';

// Mengimpor DatabaseHelper untuk mengakses dan mengubah data di database
import 'database_helper.dart';

// Class SettingsPage adalah halaman pengaturan aplikasi
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

// Class _SettingsPageState berisi logika dan tampilan dari halaman pengaturan
class _SettingsPageState extends State<SettingsPage> {
  // Controller untuk mengambil teks dari input password saat ini
  final TextEditingController _currentPasswordController =
      TextEditingController();

  // Controller untuk mengambil teks dari input password baru
  final TextEditingController _newPasswordController = TextEditingController();

  // Membuat objek DatabaseHelper untuk proses login dan update password
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Variabel untuk mengatur apakah password saat ini disembunyikan atau ditampilkan
  bool _obscureCurrent = true;

  // Variabel untuk mengatur apakah password baru disembunyikan atau ditampilkan
  bool _obscureNew = true;

  // Fungsi untuk mengganti password
  void _changePassword() async {
    // Mengambil isi input password saat ini
    String currentInput = _currentPasswordController.text;

    // Mengambil isi input password baru
    String newInput = _newPasswordController.text;

    // Mengecek apakah ada field yang masih kosong
    if (currentInput.isEmpty || newInput.isEmpty) {
      _showSnackBar('Harap isi semua field');
      return;
    }

    // 1. Memvalidasi password saat ini
    // Pada program ini diasumsikan username default adalah "user"
    var user = await _dbHelper.login('user', currentInput);

    // Jika password saat ini benar
    if (user != null) {
      // 2. Mengubah password lama menjadi password baru
      await _dbHelper.updateUserPassword('user', newInput);

      // Menampilkan pesan bahwa password berhasil diperbarui
      _showSnackBar('Password berhasil diperbarui!', isError: false);

      // Mengosongkan kembali field password saat ini
      _currentPasswordController.clear();

      // Mengosongkan kembali field password baru
      _newPasswordController.clear();
    } else {
      // 3. Jika password saat ini salah, tampilkan pesan error
      _showSnackBar('Password saat ini salah');
    }
  }

  // Fungsi untuk menampilkan pesan singkat di bagian bawah layar
  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Isi pesan yang akan ditampilkan
        content: Text(message),

        // Jika error, warna merah. Jika berhasil, warna hijau
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengatur warna latar belakang halaman
      backgroundColor: const Color(0xFFF5F7F9),

      // Membuat AppBar atau bagian atas halaman
      appBar: AppBar(
        backgroundColor: Colors.orange,

        // Judul halaman pengaturan
        title: const Text(
          'Pengaturan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        // Tombol kembali ke halaman sebelumnya
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        // Menghilangkan bayangan AppBar
        elevation: 0,
      ),

      // Isi halaman dibuat bisa digulir
      body: SingleChildScrollView(
        // Memberi jarak pada seluruh isi halaman
        padding: const EdgeInsets.all(24.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian judul untuk fitur ganti password
            const Text(
              'GANTI PASSWORD',
              style: TextStyle(
                color: Color(0xFF546E7A),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),

            // Kotak utama untuk form ganti password
            Container(
              padding: const EdgeInsets.all(20),

              // Mengatur tampilan kotak form
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label untuk input password saat ini
                  const Text(
                    'PASSWORD SAAT INI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Field untuk memasukkan password saat ini
                  TextField(
                    // Menghubungkan field dengan controller password saat ini
                    controller: _currentPasswordController,

                    // Mengatur apakah teks password disembunyikan atau tidak
                    obscureText: _obscureCurrent,

                    // Mengatur tampilan input password saat ini
                    decoration: InputDecoration(
                      hintText: '••••',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      // Tombol untuk menampilkan atau menyembunyikan password
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrent
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),

                        // Ketika ditekan, status tampil/sembunyi password berubah
                        onPressed: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Label untuk input password baru
                  const Text(
                    'PASSWORD BARU',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Field untuk memasukkan password baru
                  TextField(
                    // Menghubungkan field dengan controller password baru
                    controller: _newPasswordController,

                    // Mengatur apakah teks password baru disembunyikan atau tidak
                    obscureText: _obscureNew,

                    // Mengatur tampilan input password baru
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      // Tombol untuk menampilkan atau menyembunyikan password baru
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew ? Icons.visibility_off : Icons.visibility,
                        ),

                        // Ketika ditekan, status tampil/sembunyi password baru berubah
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tombol untuk menyimpan password baru
                  SizedBox(
                    // Membuat tombol memenuhi lebar kotak
                    width: double.infinity,

                    // Mengatur tinggi tombol
                    height: 50,

                    child: ElevatedButton(
                      // Ketika tombol ditekan, fungsi ganti password dijalankan
                      onPressed: _changePassword,

                      // Mengatur tampilan tombol
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      // Teks pada tombol
                      child: const Text(
                        'SIMPAN PASSWORD',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Bagian judul informasi developer
            const Text(
              'DEVELOPER',
              style: TextStyle(
                color: Color(0xFF546E7A),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),

            // Kotak informasi developer aplikasi
            Container(
              padding: const EdgeInsets.all(20),

              // Mengatur tampilan kotak developer
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),

              child: Row(
                children: [
                  // Menampilkan avatar developer dengan ikon orang
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFFCFD8DC),
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),

                  // Fungsi mengganti gambar
                  // Bagian di bawah ini adalah contoh jika ingin mengganti ikon
                  // menjadi foto dari assets/images/doli.jpg
                  /*
child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage('assets/images/doli.jpg'),
                  ),
*/

                  // Memberi jarak antara avatar dan teks informasi developer
                  const SizedBox(width: 16),

                  // Expanded digunakan agar teks menyesuaikan sisa ruang yang tersedia
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Menampilkan nama developer
                        const Text(
                          'Achmad Doli Harahap', // Silakan ganti dengan nama asli kamu
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Menampilkan NIM developer
                        const Text(
                          'NIM: 254107027010', // Silakan ganti dengan NIM asli kamu
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),

                        const SizedBox(height: 4),

                        // Menampilkan keterangan sebagai developer aplikasi
                        const Text(
                          'DEVELOPER APLIKASI',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mengimpor package Flutter Material untuk membuat tampilan aplikasi
import 'package:flutter/material.dart';

// Mengimpor file database_helper.dart untuk mengambil data tugas dari database
import 'database_helper.dart';

// Mengimpor package intl untuk mengatur format tanggal
import 'package:intl/intl.dart';

// Mengimpor halaman untuk menambah tugas penting
import 'add_important_task_page.dart';

// Mengimpor halaman untuk menambah tugas biasa
import 'add_normal_task_page.dart';

// Mengimpor halaman daftar tugas
import 'task_list_page.dart';

// Mengimpor halaman pengaturan
import 'settings_page.dart';

// Class HomePage adalah halaman utama atau halaman beranda aplikasi
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Class _HomePageState berisi tampilan dan logika dari halaman HomePage
class _HomePageState extends State<HomePage> {
  // Membuat objek DatabaseHelper untuk mengambil data dari database
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Variabel untuk menyimpan data statistik tugas
  Map<String, int> _stats = {
    'total_important': 0, // Jumlah tugas penting
    'total_normal': 0, // Jumlah tugas biasa
    'total_completed': 0, // Jumlah tugas yang sudah selesai
    'total_pending': 0, // Jumlah tugas yang belum selesai
  };

  // Variabel untuk menyimpan jumlah tugas selama 7 hari terakhir
  List<int> _chartData = [0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();

    // Memanggil fungsi _refreshData saat halaman pertama kali dibuka
    _refreshData();
  }

  // Fungsi untuk memperbarui data statistik dan grafik dari database
  void _refreshData() async {
    // Mengambil data statistik tugas dari database
    final stats = await _dbHelper.getTaskStats();

    // Mengambil data jumlah tugas per hari dari database
    final chartData = await _dbHelper.getTasksPerDay();

    // Memperbarui tampilan setelah data berhasil diambil
    setState(() {
      _stats = stats;
      _chartData = chartData;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil tanggal hari ini dan menampilkannya dalam format bahasa Indonesia
    String today = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    return Scaffold(
      // Mengatur warna latar belakang halaman
      backgroundColor: Colors.white,

      // Membuat AppBar atau bagian atas halaman
      appBar: AppBar(
        title: const Text(
          'Beranda',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        // Mengatur warna AppBar
        backgroundColor: Colors.orange,

        // Mengatur warna teks dan ikon pada AppBar
        foregroundColor: Colors.white,

        // Menghilangkan bayangan pada AppBar
        elevation: 0,

        // Menampilkan logo di bagian kanan AppBar
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset('assets/images/logo.png', height: 30),
          ),
        ],
      ),

      // Membuat isi halaman agar bisa digulir ke bawah
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Bagian header sapaan pengguna
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Menampilkan teks sapaan
                          const Text(
                            'Halo, Achmad Doli Harahap!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // Memberi jarak antara teks dan emoji
                          const SizedBox(width: 8),

                          // Menampilkan emoji tangan
                          const Text('👋', style: TextStyle(fontSize: 24)),
                        ],
                      ),

                      // Menampilkan tanggal hari ini
                      Text(
                        today,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Bagian kartu ringkasan tugas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  // Menampilkan jumlah tugas yang sudah selesai
                  _buildSummaryCard(
                    'TUGAS SELESAI',
                    _stats['total_completed'].toString(),
                    Colors.green,
                  ),

                  // Memberi jarak antar kartu
                  const SizedBox(width: 16),

                  // Menampilkan jumlah tugas yang belum selesai
                  _buildSummaryCard(
                    'BELUM SELESAI',
                    _stats['total_pending'].toString(),
                    Colors.orange,
                  ),
                ],
              ),
            ),

            // Memberi jarak vertikal
            const SizedBox(height: 24),

            // 3. Bagian grafik jumlah tugas selama 7 hari terakhir
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(16),

                // Mengatur tampilan kotak grafik
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul grafik
                    const Text(
                      'JUMLAH TUGAS / HARI (7 HARI TERAKHIR)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Memanggil fungsi untuk menampilkan grafik batang sederhana
                    _buildSimpleBarChart(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 4. Bagian tombol navigasi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Baris pertama tombol navigasi
                  Row(
                    children: [
                      // Tombol untuk membuka halaman tambah tugas penting
                      _buildNavButton(
                        'Tambah Tugas Penting',
                        Icons.add,
                        Colors.red,
                        () async {
                          // Membuka halaman AddImportantTaskPage
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AddImportantTaskPage(),
                            ),
                          );

                          // Jika ada data baru, maka data beranda diperbarui
                          if (result == true) {
                            _refreshData();
                          }
                        },
                      ),

                      const SizedBox(width: 16),

                      // Tombol untuk membuka halaman tambah tugas biasa
                      _buildNavButton(
                        'Tambah Tugas Biasa',
                        Icons.add,
                        Colors.green,
                        () async {
                          // Membuka halaman AddNormalTaskPage
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddNormalTaskPage(),
                            ),
                          );

                          // Jika ada data baru, maka data beranda diperbarui
                          if (result == true) {
                            _refreshData();
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Baris kedua tombol navigasi
                  Row(
                    children: [
                      // Tombol untuk membuka halaman daftar tugas
                      _buildNavButton(
                        'Daftar Tugas',
                        Icons.list_alt_rounded,
                        Colors.blueAccent,
                        () async {
                          // Membuka halaman TaskListPage
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TaskListPage(),
                            ),
                          );

                          // Jika data tugas berubah, maka data beranda diperbarui
                          if (result == true) {
                            _refreshData();
                          }
                        },
                      ),

                      const SizedBox(width: 16),

                      // Tombol untuk membuka halaman pengaturan
                      _buildNavButton(
                        'Pengaturan',
                        Icons.settings,
                        Colors.blueGrey,
                        () {
                          // Membuka halaman SettingsPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Memberi jarak di bagian bawah halaman
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membuat kartu ringkasan tugas
  Widget _buildSummaryCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),

        // Mengatur tampilan kartu
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan judul kartu, seperti TUGAS SELESAI
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 8),

            // Menampilkan jumlah tugas
            Text(
              count,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membuat grafik batang sederhana
  Widget _buildSimpleBarChart() {
    // Menyimpan label nama hari selama 7 hari terakhir
    final List<String> days = [];

    // Mengambil tanggal saat ini
    DateTime now = DateTime.now();

    // Mengisi daftar hari dari 6 hari yang lalu sampai hari ini
    for (int i = 6; i >= 0; i--) {
      days.add(
        DateFormat('E', 'id_ID').format(now.subtract(Duration(days: i))),
      );
    }

    // Mencari jumlah tugas paling banyak untuk menentukan tinggi grafik
    int maxCount = _chartData.reduce((curr, next) => curr > next ? curr : next);

    // Jika semua data bernilai 0, maxCount dibuat 1 agar tidak terjadi pembagian dengan nol
    if (maxCount == 0) maxCount = 1;

    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,

        // Membuat 7 batang grafik sesuai jumlah data
        children: List.generate(7, (index) {
          // Menghitung tinggi batang berdasarkan jumlah tugas
          double normalizedHeight =
              (_chartData[index] / maxCount) *
              60; // Tinggi maksimal batang adalah 60

          // Jika ada tugas tetapi tinggi batang terlalu kecil, tinggi minimal dibuat 5
          if (normalizedHeight < 5 && _chartData[index] > 0)
            normalizedHeight = 5;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Menampilkan jumlah tugas di atas batang grafik
              Text(
                _chartData[index] > 0 ? _chartData[index].toString() : '',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),

              const SizedBox(height: 2),

              // Membuat batang grafik
              Container(
                width: 30,
                height: normalizedHeight,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 4),

              // Menampilkan nama hari di bawah batang grafik
              Text(
                days[index],
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Fungsi untuk membuat tombol navigasi berbentuk kartu
  Widget _buildNavButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        // Fungsi yang dijalankan ketika tombol ditekan
        onTap: onTap,

        // Membuat efek klik mengikuti bentuk sudut tombol
        borderRadius: BorderRadius.circular(16),

        child: Container(
          padding: const EdgeInsets.all(20),

          // Mengatur tampilan tombol
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),

          child: Column(
            children: [
              // Membuat kotak kecil untuk ikon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),

                // Menampilkan ikon tombol
                child: Icon(icon, color: Colors.white, size: 28),
              ),

              const SizedBox(height: 12),

              // Menampilkan teks pada tombol
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan pesan singkat di bagian bawah layar
  // Fungsi ini belum dipakai pada tombol di program ini
}

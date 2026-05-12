// Mengimpor package Flutter Material untuk membuat tampilan aplikasi
import 'package:flutter/material.dart';

// Mengimpor DatabaseHelper untuk mengambil dan mengubah data tugas dari database
import 'database_helper.dart';

// Mengimpor package intl untuk memformat tanggal ke bahasa Indonesia
import 'package:intl/intl.dart';

// Class TaskListPage adalah halaman untuk menampilkan daftar tugas
class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

// Class _TaskListPageState berisi logika dan tampilan dari halaman daftar tugas
class _TaskListPageState extends State<TaskListPage> {
  // Membuat objek DatabaseHelper untuk mengakses database
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Variabel untuk menyimpan daftar tugas dari database
  List<Map<String, dynamic>> _tasks = [];

  // Variabel untuk menandai apakah data sedang dimuat atau tidak
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Memanggil fungsi untuk mengambil data tugas saat halaman pertama kali dibuka
    _fetchTasks();
  }

  // Fungsi untuk mengambil semua data tugas dari database
  Future<void> _fetchTasks() async {
    // Menampilkan loading sebelum data selesai diambil
    setState(() => _isLoading = true);

    // Mengambil semua data tugas dari database
    final data = await _dbHelper.queryAllTasks();

    // Menyimpan data tugas ke dalam variabel _tasks
    // Setelah data selesai diambil, loading dihentikan
    setState(() {
      _tasks = data;
      _isLoading = false;
    });
  }

  // Fungsi untuk mengubah status tugas menjadi selesai atau belum selesai
  void _toggleTaskStatus(Map<String, dynamic> task) async {
    // Jika tugas sudah selesai, ubah menjadi belum selesai
    // Jika tugas belum selesai, ubah menjadi selesai
    int newStatus = task['is_completed'] == 1 ? 0 : 1;

    // Mengupdate status tugas di database berdasarkan id tugas
    await _dbHelper.updateTask({'id': task['id'], 'is_completed': newStatus});

    // Mengambil ulang data tugas agar tampilan ikut berubah
    _fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengatur warna latar belakang halaman
      backgroundColor: const Color(0xFFF5F7F9),

      // Membuat AppBar atau bagian atas halaman
      appBar: AppBar(
        // Mengatur warna AppBar
        backgroundColor: Colors.blue,

        // Judul halaman
        title: const Text(
          'Daftar Tugas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        // Tombol kembali ke halaman sebelumnya
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),

          // Saat tombol kembali ditekan, halaman ditutup
          // Nilai true dikirim agar halaman sebelumnya tahu bahwa data mungkin berubah
          onPressed: () => Navigator.pop(context, true),
        ),

        // Menghilangkan bayangan pada AppBar
        elevation: 0,
      ),

      // Jika data sedang dimuat, tampilkan loading
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          // Jika data sudah selesai dimuat tetapi daftar tugas kosong,
          // tampilkan teks bahwa belum ada tugas
          : _tasks.isEmpty
          ? const Center(child: Text('Belum ada tugas.'))
          // Jika ada data tugas, tampilkan menggunakan ListView
          : ListView.builder(
              // Memberi jarak pada seluruh daftar tugas
              padding: const EdgeInsets.all(16),

              // Jumlah item sesuai jumlah tugas yang ada
              itemCount: _tasks.length,

              // Membuat tampilan untuk setiap tugas
              itemBuilder: (context, index) {
                // Mengambil satu data tugas berdasarkan index
                final task = _tasks[index];

                // Mengecek apakah tugas sudah selesai
                bool isCompleted = task['is_completed'] == 1;

                // Mengecek apakah tugas termasuk kategori penting
                bool isImportant = task['category'] == 'Penting';

                // Variabel untuk menyimpan tanggal yang sudah diformat
                String formattedDate = '';

                // Jika tugas memiliki tanggal jatuh tempo, tanggal akan diformat
                if (task['due_date'] != null) {
                  // Mengubah data tanggal dari String menjadi DateTime
                  DateTime dt = DateTime.parse(task['due_date']);

                  // Mengubah format tanggal menjadi contoh: 12 Jan 2024
                  formattedDate = DateFormat('dd MMM yyyy', 'id_ID').format(dt);
                }

                // Container digunakan sebagai kotak untuk setiap tugas
                return Container(
                  // Memberi jarak bawah antar tugas
                  margin: const EdgeInsets.only(bottom: 12),

                  // Mengatur tampilan kotak tugas
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),

                  // ListTile digunakan untuk menampilkan isi tugas secara rapi
                  child: ListTile(
                    // Mengatur jarak isi di dalam ListTile
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    // Bagian kiri berisi checkbox untuk status tugas
                    leading: Transform.scale(
                      // Memperbesar ukuran checkbox
                      scale: 1.2,

                      child: Checkbox(
                        // Nilai checkbox mengikuti status tugas
                        value: isCompleted,

                        // Warna checkbox saat aktif
                        activeColor: const Color(0xFF4A8B7A),

                        // Membuat sudut checkbox sedikit melengkung
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),

                        // Saat checkbox ditekan, status tugas akan diubah
                        onChanged: (_) => _toggleTaskStatus(task),
                      ),
                    ),

                    // Judul tugas
                    title: Text(
                      task['title'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,

                        // Jika tugas selesai, warna teks menjadi abu-abu
                        color: isCompleted ? Colors.grey : Colors.black87,

                        // Jika tugas selesai, teks diberi garis coret
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),

                    // Bagian bawah judul berisi tanggal dan kategori tugas
                    subtitle: Text(
                      '$formattedDate · ${task['category']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    // Ikon di sebelah kanan tugas
                    trailing: Icon(
                      Icons.play_arrow_rounded,

                      // Jika tugas penting, ikon berwarna merah
                      // Jika tugas biasa, ikon berwarna hijau
                      color: isImportant ? Colors.red : Colors.green,
                      size: 24,
                    ),

                    // Saat item tugas ditekan, status tugas juga akan berubah
                    onTap: () => _toggleTaskStatus(task),
                  ),
                );
              },
            ),
    );
  }
}

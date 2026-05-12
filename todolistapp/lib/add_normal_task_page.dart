// Mengimpor package Flutter Material untuk membuat tampilan aplikasi
import 'package:flutter/material.dart';

// Mengimpor package intl untuk mengatur format tanggal
import 'package:intl/intl.dart';

// Mengimpor DatabaseHelper untuk menyimpan data tugas ke database
import 'database_helper.dart';

// Class AddNormalTaskPage adalah halaman untuk menambahkan tugas biasa
class AddNormalTaskPage extends StatefulWidget {
  const AddNormalTaskPage({super.key});

  @override
  State<AddNormalTaskPage> createState() => _AddNormalTaskPageState();
}

// Class _AddNormalTaskPageState berisi logika dan tampilan halaman tambah tugas biasa
class _AddNormalTaskPageState extends State<AddNormalTaskPage> {
  // Controller untuk mengambil teks dari input judul tugas
  final TextEditingController _titleController = TextEditingController();

  // Controller untuk mengambil teks dari input deskripsi tugas
  final TextEditingController _descriptionController = TextEditingController();

  // Variabel untuk menyimpan tanggal yang dipilih pengguna
  // Nilai awalnya adalah tanggal hari ini
  DateTime _selectedDate = DateTime.now();

  // Membuat objek DatabaseHelper untuk menyimpan tugas ke database
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Fungsi untuk memilih tanggal jatuh tempo menggunakan date picker
  Future<void> _selectDate(BuildContext context) async {
    // Menampilkan kalender untuk memilih tanggal
    final DateTime? picked = await showDatePicker(
      context: context,

      // Tanggal awal yang ditampilkan adalah tanggal yang sedang dipilih
      initialDate: _selectedDate,

      // Batas tanggal paling awal yang bisa dipilih
      firstDate: DateTime(2000),

      // Batas tanggal paling akhir yang bisa dipilih
      lastDate: DateTime(2101),

      // Mengatur tema warna date picker
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              // Warna utama date picker dibuat hijau karena kategori tugas biasa
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    // Jika pengguna memilih tanggal dan tanggalnya berbeda dari sebelumnya
    if (picked != null && picked != _selectedDate) {
      setState(() {
        // Simpan tanggal baru yang dipilih
        _selectedDate = picked;
      });
    }
  }

  // Fungsi untuk menyimpan tugas biasa ke database
  void _saveTask() async {
    // Mengecek apakah judul tugas masih kosong
    if (_titleController.text.isEmpty) {
      // Jika kosong, tampilkan pesan peringatan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tugas tidak boleh kosong')),
      );
      return;
    }

    // Menyimpan data tugas ke dalam tabel tasks
    await _dbHelper.insertTask({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'due_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'category': 'Biasa',
      'is_completed': 0,
    });

    // Jika halaman masih aktif, kembali ke halaman sebelumnya
    // Nilai true dikirim agar halaman sebelumnya tahu bahwa ada data baru
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengatur warna latar belakang halaman
      backgroundColor: Colors.white,

      // Membuat AppBar atau bagian atas halaman
      appBar: AppBar(
        // Warna hijau digunakan untuk menandai tugas kategori biasa
        backgroundColor: const Color(0xFF4CAF50),

        // Judul halaman
        title: const Text(
          'Tambah Tugas Biasa',
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

      // Isi halaman dapat digulir jika layar kecil
      body: SingleChildScrollView(
        // Memberi jarak pada seluruh isi halaman
        padding: const EdgeInsets.all(24.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge atau label kategori tugas biasa
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'BIASA',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Label untuk memilih tanggal jatuh tempo
            const Text(
              'TANGGAL JATUH TEMPO',
              style: TextStyle(
                color: Color(0xFF546E7A),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 8),

            // Area yang bisa ditekan untuk membuka date picker
            InkWell(
              onTap: () => _selectDate(context),

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  children: [
                    // Ikon kalender
                    const Icon(Icons.calendar_month, color: Color(0xFF546E7A)),

                    const SizedBox(width: 12),

                    // Menampilkan tanggal yang dipilih dalam format Indonesia
                    Text(
                      DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Label untuk input judul tugas
            const Text(
              'JUDUL TUGAS',
              style: TextStyle(
                color: Color(0xFF546E7A),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 8),

            // Field untuk memasukkan judul tugas
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Contoh: Beli buah',
                hintStyle: TextStyle(color: Colors.grey.shade400),

                // Border saat field tidak aktif
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                // Border saat field aktif atau bisa digunakan
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Label untuk input deskripsi tugas
            const Text(
              'DESKRIPSI',
              style: TextStyle(
                color: Color(0xFF546E7A),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 8),

            // Field untuk memasukkan deskripsi tugas
            TextField(
              controller: _descriptionController,

              // Membuat field deskripsi bisa menampung beberapa baris
              maxLines: 4,

              decoration: InputDecoration(
                hintText: 'Jelaskan tugas...',
                hintStyle: TextStyle(color: Colors.grey.shade400),

                // Border saat field tidak aktif
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                // Border saat field aktif atau bisa digunakan
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Tombol untuk menyimpan tugas
            SizedBox(
              // Membuat tombol memenuhi lebar layar
              width: double.infinity,

              // Mengatur tinggi tombol
              height: 56,

              child: ElevatedButton(
                // Saat tombol ditekan, fungsi _saveTask akan dijalankan
                onPressed: _saveTask,

                // Mengatur tampilan tombol simpan
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),

                // Teks pada tombol
                child: const Text(
                  'SIMPAN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

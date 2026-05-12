// Mengimpor package Flutter Material untuk membuat tampilan aplikasi
import 'package:flutter/material.dart';

// Mengimpor package intl untuk mengatur format tanggal
import 'package:intl/intl.dart';

// Mengimpor DatabaseHelper untuk menyimpan data tugas ke database
import 'database_helper.dart';

// Class AddImportantTaskPage adalah halaman untuk menambahkan tugas penting
class AddImportantTaskPage extends StatefulWidget {
  const AddImportantTaskPage({super.key});

  @override
  State<AddImportantTaskPage> createState() => _AddImportantTaskPageState();
}

// Class _AddImportantTaskPageState berisi logika dan tampilan halaman tambah tugas penting
class _AddImportantTaskPageState extends State<AddImportantTaskPage> {
  // Controller untuk mengambil teks dari input judul tugas
  final TextEditingController _titleController = TextEditingController();

  // Controller untuk mengambil teks dari input deskripsi tugas
  final TextEditingController _descriptionController = TextEditingController();

  // Variabel untuk menyimpan tanggal yang dipilih pengguna
  // Nilai awalnya adalah tanggal hari ini
  DateTime _selectedDate = DateTime.now();

  // Membuat objek DatabaseHelper untuk menyimpan data tugas ke database
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Fungsi untuk memilih tanggal jatuh tempo menggunakan kalender
  Future<void> _selectDate(BuildContext context) async {
    // Menampilkan date picker atau kalender pilihan tanggal
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
              // Warna utama date picker dibuat merah karena tugas ini kategori penting
              primary: Color(0xFFC62828),
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
        // Menyimpan tanggal baru yang dipilih pengguna
        _selectedDate = picked;
      });
    }
  }

  // Fungsi untuk menyimpan tugas penting ke database
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
      'category': 'Penting',
      'is_completed': 0,
    });

    // Jika halaman masih aktif, kembali ke halaman sebelumnya
    // Nilai true dikirim agar halaman sebelumnya memperbarui data
    if (mounted) {
      Navigator.pop(
        context,
        true,
      ); // Mengirim true agar halaman sebelumnya melakukan refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengatur warna latar belakang halaman
      backgroundColor: Colors.white,

      // Membuat AppBar atau bagian atas halaman
      appBar: AppBar(
        // Warna merah digunakan karena halaman ini untuk tugas penting
        backgroundColor: const Color(0xFFC62828),

        // Judul halaman
        title: const Text(
          'Tambah Tugas Penting',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        // Tombol kembali ke halaman sebelumnya
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        // Menghilangkan bayangan pada AppBar
        elevation: 0,
      ),

      // Isi halaman dibuat bisa digulir agar tetap nyaman di layar kecil
      body: SingleChildScrollView(
        // Memberi jarak pada seluruh isi halaman
        padding: const EdgeInsets.all(24.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge atau label kategori tugas penting
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                // Warna latar badge dibuat merah muda
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'PENTING',
                style: TextStyle(
                  color: Color(0xFFC62828),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Label untuk bagian tanggal jatuh tempo
            const Text(
              'TANGGAL JATUH TEMPO',
              style: TextStyle(
                color: Color(0xFF546E7A),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 8),

            // Area yang bisa ditekan untuk membuka kalender pemilihan tanggal
            InkWell(
              onTap: () => _selectDate(context),

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                // Mengatur tampilan kotak tanggal
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  children: [
                    // Ikon kalender
                    const Icon(Icons.calendar_month, color: Color(0xFF546E7A)),

                    const SizedBox(width: 12),

                    // Menampilkan tanggal yang sudah dipilih dengan format Indonesia
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
              // Menghubungkan TextField dengan controller judul
              controller: _titleController,

              // Mengatur tampilan input judul
              decoration: InputDecoration(
                hintText: 'Contoh: Submit laporan',
                hintStyle: TextStyle(color: Colors.grey.shade400),

                // Border utama input
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                // Border saat input aktif atau tersedia
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
              // Menghubungkan TextField dengan controller deskripsi
              controller: _descriptionController,

              // Membuat input deskripsi bisa terdiri dari beberapa baris
              maxLines: 4,

              // Mengatur tampilan input deskripsi
              decoration: InputDecoration(
                hintText: 'Jelaskan tugas...',
                hintStyle: TextStyle(color: Colors.grey.shade400),

                // Border utama input
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                // Border saat input aktif atau tersedia
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Tombol untuk menyimpan tugas penting
            SizedBox(
              // Membuat tombol memenuhi lebar layar
              width: double.infinity,

              // Mengatur tinggi tombol
              height: 56,

              child: ElevatedButton(
                // Ketika tombol ditekan, fungsi _saveTask akan dijalankan
                onPressed: _saveTask,

                // Mengatur tampilan tombol simpan
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
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

// Mengimpor package sqflite untuk menggunakan database SQLite di Flutter
import 'package:sqflite/sqflite.dart';

// Mengimpor package path untuk menggabungkan lokasi folder dan nama file database
import 'package:path/path.dart';

// Mengimpor package intl untuk memformat tanggal
import 'package:intl/intl.dart';

// Class DatabaseHelper digunakan untuk mengelola semua proses database aplikasi
class DatabaseHelper {
  // Membuat instance tunggal dari DatabaseHelper
  // Tujuannya agar database tidak dibuat berulang-ulang
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Variabel untuk menyimpan koneksi database
  static Database? _database;

  // Factory constructor agar setiap pemanggilan DatabaseHelper()
  // tetap menggunakan instance yang sama
  factory DatabaseHelper() => _instance;

  // Constructor internal khusus untuk class ini
  DatabaseHelper._internal();

  // Getter untuk mengambil database
  // Jika database sudah ada, langsung digunakan
  // Jika belum ada, maka database akan dibuat terlebih dahulu
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // Fungsi untuk membuat atau membuka database
  Future<Database> _initDatabase() async {
    // Menentukan lokasi dan nama file database
    String path = join(await getDatabasesPath(), 'agenda_nusantara.db');

    // Membuka database dengan versi 2
    return await openDatabase(
      path,
      version: 2,

      // Jika database belum ada, fungsi _onCreate akan dijalankan
      onCreate: _onCreate,

      // Jika versi database berubah, fungsi _onUpgrade akan dijalankan
      onUpgrade: _onUpgrade,
    );
  }

  // Fungsi untuk memperbarui struktur database jika versi database berubah
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Jika database masih versi lama, tambahkan kolom completed_date pada tabel tasks
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN completed_date TEXT');
    }
  }

  // Fungsi ini dijalankan saat database pertama kali dibuat
  Future<void> _onCreate(Database db, int version) async {
    // Membuat tabel tasks untuk menyimpan data tugas
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        category TEXT,
        is_completed INTEGER DEFAULT 0,
        completed_date TEXT
      )
    ''');

    // Membuat tabel users untuk menyimpan data akun pengguna
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Menambahkan akun default ke tabel users
    // Username: user
    // Password: user
    await db.insert('users', {'username': 'user', 'password': 'user'});
  }

  // =========================
  // BAGIAN LOGIN / AKUN
  // =========================

  // Fungsi untuk memeriksa username dan password saat login
  Future<Map<String, dynamic>?> login(String username, String password) async {
    // Mengambil koneksi database
    Database db = await database;

    // Mencari data user yang username dan password-nya sesuai
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    // Jika data ditemukan, kembalikan data user pertama
    if (results.isNotEmpty) {
      return results.first;
    }

    // Jika tidak ditemukan, kembalikan null
    return null;
  }

  // Fungsi untuk mengganti password user
  Future<int> updateUserPassword(String username, String newPassword) async {
    // Mengambil koneksi database
    Database db = await database;

    // Mengubah password user berdasarkan username
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  // =========================
  // BAGIAN CRUD DATA TUGAS
  // =========================

  // Fungsi untuk menambahkan data tugas baru ke tabel tasks
  Future<int> insertTask(Map<String, dynamic> row) async {
    // Mengambil koneksi database
    Database db = await database;

    // Menambahkan data tugas ke tabel tasks
    return await db.insert('tasks', row);
  }

  // Fungsi untuk mengambil semua data tugas dari tabel tasks
  Future<List<Map<String, dynamic>>> queryAllTasks() async {
    // Mengambil koneksi database
    Database db = await database;

    // Mengambil semua tugas dan mengurutkannya berdasarkan tanggal jatuh tempo
    return await db.query('tasks', orderBy: 'due_date ASC');
  }

  // Fungsi untuk memperbarui data tugas
  Future<int> updateTask(Map<String, dynamic> row) async {
    // Mengambil koneksi database
    Database db = await database;

    // Mengambil id tugas yang akan diperbarui
    int id = row['id'];

    // Jika tugas ditandai selesai, maka tanggal selesai diisi dengan tanggal hari ini
    if (row['is_completed'] == 1) {
      // Membuat salinan data agar data asli tidak langsung berubah
      row = Map<String, dynamic>.from(row);

      // Menyimpan tanggal selesai dengan format tahun-bulan-tanggal
      row['completed_date'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    } else {
      // Jika tugas ditandai belum selesai, tanggal selesai dikosongkan
      row = Map<String, dynamic>.from(row);
      row['completed_date'] = null;
    }

    // Mengupdate data tugas berdasarkan id
    return await db.update('tasks', row, where: 'id = ?', whereArgs: [id]);
  }

  // Fungsi untuk menghapus data tugas berdasarkan id
  Future<int> deleteTask(int id) async {
    // Mengambil koneksi database
    Database db = await database;

    // Menghapus tugas dari tabel tasks sesuai id
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // =========================
  // BAGIAN STATISTIK TUGAS
  // =========================

  // Fungsi untuk mengambil statistik jumlah tugas
  Future<Map<String, int>> getTaskStats() async {
    // Mengambil koneksi database
    Database db = await database;

    // Menghitung jumlah tugas dengan kategori Penting
    var important = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE category = "Penting"',
    );

    // Menghitung jumlah tugas dengan kategori Biasa
    var normal = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE category = "Biasa"',
    );

    // Menghitung jumlah tugas yang sudah selesai
    var completed = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE is_completed = 1',
    );

    // Menghitung jumlah tugas yang belum selesai
    var pending = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE is_completed = 0',
    );

    // Mengembalikan semua hasil statistik dalam bentuk Map
    return {
      'total_important': Sqflite.firstIntValue(important) ?? 0,
      'total_normal': Sqflite.firstIntValue(normal) ?? 0,
      'total_completed': Sqflite.firstIntValue(completed) ?? 0,
      'total_pending': Sqflite.firstIntValue(pending) ?? 0,
    };
  }

  // Fungsi untuk mengambil jumlah tugas selesai selama 7 hari terakhir
  // Data ini digunakan untuk membuat grafik pada halaman beranda
  Future<List<int>> getTasksPerDay() async {
    // Mengambil koneksi database
    Database db = await database;

    // List untuk menyimpan jumlah tugas selesai per hari
    List<int> counts = [];

    // Mengambil tanggal hari ini
    DateTime now = DateTime.now();

    // Melakukan perulangan dari 6 hari lalu sampai hari ini
    for (int i = 6; i >= 0; i--) {
      // Menghitung tanggal berdasarkan hari ke-i
      DateTime date = now.subtract(Duration(days: i));

      // Mengubah tanggal menjadi format yyyy-MM-dd agar cocok dengan database
      String dateStr = DateFormat('yyyy-MM-dd').format(date);

      // Menghitung jumlah tugas yang selesai pada tanggal tersebut
      var result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tasks WHERE completed_date = ? AND is_completed = 1',
        [dateStr],
      );

      // Menambahkan hasil hitungan ke dalam list counts
      counts.add(Sqflite.firstIntValue(result) ?? 0);
    }

    // Mengembalikan data jumlah tugas selesai selama 7 hari terakhir
    return counts;
  }
}

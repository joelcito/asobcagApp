import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ejemplares.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ejemplares (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        especie TEXT,
        descripcion TEXT
      )
    ''');
  }

  Future<int> insertEjemplar(Map<String, dynamic> ejemplar) async {
    final db = await instance.database;
    return await db.insert('ejemplares', ejemplar);
  }

  Future<List<Map<String, dynamic>>> getEjemplaresPendientes() async {
    final db = await instance.database;
    return await db.query('ejemplares');
  }

  Future<void> deleteEjemplar(int id) async {
    final db = await instance.database;
    await db.delete('ejemplares', where: 'id = ?', whereArgs: [id]);
  }
}

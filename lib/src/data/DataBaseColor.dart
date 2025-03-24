import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Databasecolor {
  static final Databasecolor instance = Databasecolor._init();
  static Database? _database;

  Databasecolor._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('colores.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE colores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        color_id INTEGER,
        nombre TEXT
      )
    ''');
  }

  Future<int> insertColor(Map<String, dynamic> color) async {
    final db = await instance.database;
    return await db.insert('colores', color);
  }

  Future<List<Map<String, dynamic>>> getColores() async {
    final db = await instance.database;
    return await db.query('colores');
  }

  Future<void> deleteColor(int id) async {
    final db = await instance.database;
    await db.delete('colores', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> editarColor(int color_id, String nombre) async {
    final db = await instance.database;
    await db.update(
      'colores',
      {'nombre': nombre},
      where: 'color_id = ?',
      whereArgs: [color_id],
    );
  }

  Future<Map<String, dynamic>?> getColorFindById(int color_id) async {
    final db = await instance.database;

    List<Map<String, dynamic>> result = await db.query(
      'colores',
      where: 'color_id = ?',
      whereArgs: [color_id],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }
}

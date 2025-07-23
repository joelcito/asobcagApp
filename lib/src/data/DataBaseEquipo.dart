import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Databaseequipo {
  static final Databaseequipo instance = Databaseequipo._init();
  static Database? _database;

  Databaseequipo._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('equipos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE equipos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        equipo_id INTEGER,
        nombre TEXT
      )
    ''');
  }

  Future<int> insertEquipo(Map<String, dynamic> equipo) async {
    final db = await instance.database;
    return await db.insert('equipos', equipo);
  }

  Future<List<Map<String, dynamic>>> getEquipos() async {
    final db = await instance.database;
    return await db.query('equipos');
  }

  Future<void> deleteEquipo(int id) async {
    final db = await instance.database;
    await db.delete('equipos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> editarEquipo(int equipo_id, String nombre) async {
    final db = await instance.database;
    await db.update(
      'equipos',
      {'nombre': nombre},
      where: 'equipo_id = ?',
      whereArgs: [equipo_id],
    );
  }

  Future<Map<String, dynamic>?> getEquipoFindById(int equipo_id) async {
    final db = await instance.database;

    List<Map<String, dynamic>> result = await db.query(
      'equipos',
      where: 'equipo_id = ?',
      whereArgs: [equipo_id],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }
}

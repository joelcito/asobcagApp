import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseFenotipo {
  static final DataBaseFenotipo instance = DataBaseFenotipo._init();
  static Database? _database;

  DataBaseFenotipo._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fenotipos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // 🛑 Elimina la base de datos existente para asegurarte de que se cree de nuevo
    // await deleteDatabase(path);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS fenotipos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fenotipo_id INTEGER,
        nombre TEXT
      )
    ''');
  }

  Future<int> insertFenotipo(Map<String, dynamic> fenotipo) async {
    final db = await instance.database;
    return await db.insert('fenotipos', fenotipo);
  }

  Future<List<Map<String, dynamic>>> getFenotipos() async {
    final db = await instance.database;
    return await db.query('fenotipos');
  }

  Future<void> deleteFenotipo(int id) async {
    final db = await instance.database;
    await db.delete('fenotipos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> editarFenotipo(int fenotipo_id, String nombre) async {
    final db = await instance.database;
    await db.update(
      'fenotipos',
      {'nombre': nombre},
      where: 'fenotipo_id = ?',
      whereArgs: [fenotipo_id],
    );
  }

  Future<Map<String, dynamic>?> getFenotipoFindById(int fenotipo_id) async {
    final db = await instance.database;

    List<Map<String, dynamic>> result = await db.query(
      'fenotipos',
      where: 'fenotipo_id = ?',
      whereArgs: [fenotipo_id],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }
}

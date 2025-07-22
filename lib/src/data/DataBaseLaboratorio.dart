import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Databaselaboratorio {
  static final Databaselaboratorio instance = Databaselaboratorio._init();
  static Database? _database;

  Databaselaboratorio._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('laboratorios.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE laboratorios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        laboratorio_id INTEGER,
        nombre TEXT
      )
    ''');
  }

  Future<int> insertLaboratorio(Map<String, dynamic> laboratorio) async {
    final db = await instance.database;
    return await db.insert('laboratorios', laboratorio);
  }

  Future<List<Map<String, dynamic>>> getLaboratorios() async {
    final db = await instance.database;
    return await db.query('laboratorios');
  }

  Future<void> deleteLaboratorio(int id) async {
    final db = await instance.database;
    await db.delete('laboratorios', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> editarLaboratorio(int laboratorio_id, String nombre) async {
    final db = await instance.database;
    await db.update(
      'laboratorios',
      {'nombre': nombre},
      where: 'laboratorio_id = ?',
      whereArgs: [laboratorio_id],
    );
  }

  Future<Map<String, dynamic>?> getLaboratorioFindById(
    int laboratorio_id,
  ) async {
    final db = await instance.database;

    List<Map<String, dynamic>> result = await db.query(
      'laboratorios',
      where: 'laboratorio_id = ?',
      whereArgs: [laboratorio_id],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }
}

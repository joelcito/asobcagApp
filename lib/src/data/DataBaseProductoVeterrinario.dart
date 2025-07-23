import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Databaseproductoveterrinario {
  static final Databaseproductoveterrinario instance =
      Databaseproductoveterrinario._init();
  static Database? _database;

  Databaseproductoveterrinario._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('producto_veterrinarios.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE producto_veterrinarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        producto_veterrinario_id INTEGER,
        nombre TEXT
      )
    ''');
  }

  Future<int> insertProductoVeterrinario(
    Map<String, dynamic> producto_veterrinario,
  ) async {
    final db = await instance.database;
    return await db.insert('producto_veterrinarios', producto_veterrinario);
  }

  Future<List<Map<String, dynamic>>> getProductoVeterrinarios() async {
    final db = await instance.database;
    return await db.query('producto_veterrinarios');
  }

  Future<void> deleteProductoVeterrinario(int id) async {
    final db = await instance.database;
    await db.delete('producto_veterrinarios', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> editarProductoVeterrinario(
    int producto_veterrinario_id,
    String nombre,
  ) async {
    final db = await instance.database;
    await db.update(
      'producto_veterrinarios',
      {'nombre': nombre},
      where: 'producto_veterrinario_id = ?',
      whereArgs: [producto_veterrinario_id],
    );
  }

  Future<Map<String, dynamic>?> getProductoVeterrinarioFindById(
    int producto_veterrinario_id,
  ) async {
    final db = await instance.database;

    List<Map<String, dynamic>> result = await db.query(
      'producto_veterrinarios',
      where: 'producto_veterrinario_id = ?',
      whereArgs: [producto_veterrinario_id],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseImage {
  static final DataBaseImage instance = DataBaseImage._init();
  static Database? _database;

  DataBaseImage._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('imagenes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      readOnly: false,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE imagenes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ejemplar_id INTEGER,
        ruta TEXT,
        FOREIGN KEY (ejemplar_id) REFERENCES ejemplares(id)
      )
    ''');
  }

  Future<int> insertImagen(Map<String, dynamic> imagen) async {
    final db = await instance.database;
    return await db.insert('imagenes', imagen);
  }

  Future<List<Map<String, dynamic>>> getImagenes() async {
    final db = await instance.database;
    return await db.query('imagenes');
  }

  Future<void> deleteImagen(int id) async {
    final db = await instance.database;
    await db.delete('imagenes', where: 'id = ?', whereArgs: [id]);
  }

  // Future<void> editarColor(int color_id, String nombre) async {
  //   final db = await instance.database;
  //   await db.update(
  //     'colores',
  //     {'nombre': nombre},
  //     where: 'color_id = ?',
  //     whereArgs: [color_id],
  //   );
  // }

  Future<List<Map<String, dynamic>>> getImagenesFindByIdEjemplar(
    int ejemplar_id,
  ) async {
    final db = await instance.database;

    List<Map<String, dynamic>> result = await db.query(
      'imagenes',
      where: 'ejemplar_id = ?',
      whereArgs: [ejemplar_id],
    );

    return result;
  }
}

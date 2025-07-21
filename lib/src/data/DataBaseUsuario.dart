import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Databaseusuario {
  static final Databaseusuario instance = Databaseusuario._init();
  static Database? _database;

  Databaseusuario._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('usuarios.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER,
        nombre TEXT
      )
    ''');
  }

  Future<int> insertUsuario(Map<String, dynamic> color) async {
    final db = await instance.database;
    return await db.insert('usuarios', color);
  }

  Future<List<Map<String, dynamic>>> getUsuarios() async {
    final db = await instance.database;
    return await db.query('usuarios');
  }

  Future<void> deleteUsuario(int id) async {
    final db = await instance.database;
    await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> editarUsuario(int usuario_id, String nombre) async {
    final db = await instance.database;
    await db.update(
      'usuarios',
      {'nombre': nombre},
      where: 'usuario_id = ?',
      whereArgs: [usuario_id],
    );
  }

  Future<Map<String, dynamic>?> getUsuarioFindById(int usuario_id) async {
    final db = await instance.database;

    List<Map<String, dynamic>> result = await db.query(
      'usuarios',
      where: 'usuario_id = ?',
      whereArgs: [usuario_id],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }
}

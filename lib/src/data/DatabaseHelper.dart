import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool isFirstTime = true;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ejemplares.db');
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
      // onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ejemplares (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        color_id INTEGER NOT NULL, 
        fenotipo_id INTEGER NOT NULL, 
        tipo TEXT,
        tipo_parto TEXT,
        sexo TEXT,
        fecha_nacimiento TEXT,
        microchip TEXT,
        arete TEXT
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

  // Método para eliminar la base de datos (solo para desarrollo)
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ejemplares.db');
    await deleteDatabase(path);
  }

  Future<List<Map<String, dynamic>>> getEjemplaresConImagenes() async {
    final db = await instance.database;

    // Obtener todos los ejemplares
    final List<Map<String, dynamic>> ejemplares = await db.query('ejemplares');
    // final List<Map<String, dynamic>> imagenes = await db.query('imagenes');
    print("**************************************************");
    print(ejemplares);
    // print(ejemplares);
    print("**************************************************");

    // Usar Future.wait para esperar que se obtengan todas las imágenes
    // final List<Map<String, dynamic>> ejemplaresConImagenes = await Future.wait(
    //   ejemplares.map((ejemplar) async {
    //     // Obtener las imágenes para cada ejemplar
    //     final List<Map<String, dynamic>> imagenes = await db.query(
    //       'imagenes',
    //       where: 'ejemplar_id = ?',
    //       whereArgs: [ejemplar['id']],
    //     );

    //     // Agregar las rutas de las imágenes al ejemplar
    //     ejemplar['images'] =
    //         imagenes.map((img) => img['ruta'].toString()).toList();

    //     return ejemplar;
    //   }).toList(),
    // );
    // return ejemplaresConImagenes;

    return [];
  }
}

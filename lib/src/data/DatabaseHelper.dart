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
      // onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    // Solo elimina las tablas la primera vez
    // if (isFirstTime) {
    //   await db.execute('DROP TABLE IF EXISTS ejemplares');
    //   isFirstTime =
    //       false; // Cambia el flag a false después de la primera ejecución
    // }

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

  // Método de actualización para manejar la migración (de la versión 1 a la versión 2)
  // Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
  //   if (oldVersion < 2) {
  //     // Verificar si la columna 'fenotipo_id' existe
  //     final columnCheck = await db.rawQuery("PRAGMA table_info(ejemplares)");
  //     bool hasFenotipoIdColumn = columnCheck.any(
  //       (column) => column['name'] == 'fenotipo_id',
  //     );

  //     if (!hasFenotipoIdColumn) {
  //       // Si la columna no existe, agregarla
  //       await db.execute('''
  //         ALTER TABLE ejemplares ADD COLUMN fenotipo_id INTEGER NOT NULL DEFAULT 0
  //       ''');
  //     }

  //     // Verificar si la columna 'color_id' existe
  //     bool hasColorIdColumn = columnCheck.any(
  //       (column) => column['name'] == 'color_id',
  //     );
  //     if (!hasColorIdColumn) {
  //       // Si la columna no existe, agregarla
  //       await db.execute('''
  //         ALTER TABLE ejemplares ADD COLUMN color_id INTEGER NOT NULL DEFAULT 0
  //       ''');
  //     }
  //   }
  // }

  Future<int> insertEjemplar(Map<String, dynamic> ejemplar) async {
    // print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
    // final db = await instance.database;
    // final result = await db.rawQuery("PRAGMA table_info(ejemplares)");
    // print(result); // Esto imprimirá las columnas de la tabla 'ejemplares'
    // print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");

    // print(
    //   await db.rawQuery("PRAGMA table_info(ejemplares)"),
    // ); // Esto imprimirá las columnas de la tabla 'ejemplares'

    // deleteDatabaseFile();
    // return 1;

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
}

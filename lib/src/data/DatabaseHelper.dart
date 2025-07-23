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
        arete TEXT,

        reg_biometrico_motivo TEXT,
        reg_biometrico_fecha TEXT,
        reg_biometrico_evaluador_id INTEGER,
        reg_biometrico_peso TEXT,
        reg_biometrico_altura_cruz TEXT,
        reg_biometrico_altura_grupa TEXT,
        reg_biometrico_altura_cabeza TEXT,
        reg_biometrico_ancho_pecho TEXT,
        reg_biometrico_ancho_isquiones TEXT,
        reg_biometrico_perimetro_toracico TEXT,
        reg_biometrico_perimetro_abdominal TEXT,
        reg_biometrico_largo_cuello TEXT,
        reg_biometrico_cuello_perimetro_sup TEXT,
        reg_biometrico_cuello_perimetro_inf TEXT,
        reg_biometrico_largo_oreja TEXT,
        reg_biometrico_largo_cola TEXT,
        reg_biometrico_diametro_cania_ant TEXT,
        reg_biometrico_diametro_cania_post TEXT,

        reg_morfologico_motivo TEXT,
        reg_morfologico_fecha TEXT,
        reg_morfologico_evaluador_id INTEGER,
        reg_morfologico_oreja TEXT,
        reg_morfologico_cuello TEXT,
        reg_morfologico_cabeza TEXT,
        reg_morfologico_alzada TEXT,
        reg_morfologico_largo_cuerpo TEXT,
        reg_morfologico_amplitud_pecho TEXT,
        reg_morfologico_fortaleza TEXT,
        reg_morfologico_balance TEXT,
        reg_morfologico_canias TEXT,
        reg_morfologico_copete TEXT,
        reg_morfologico_linea_superior TEXT,
        reg_morfologico_grupa TEXT,

        reg_fibra_laboratorio_id INTEGER,
        reg_fibra_equipo_id INTEGER,
        reg_fibra_fecha_muestreo TEXT,
        reg_fibra_fecha_analisis TEXT,
        reg_fibra_zona_corporal TEXT,
        reg_fibra_fd TEXT,
        reg_fibra_sd TEXT,
        reg_fibra_cv TEXT,
        reg_fibra_fc TEXT,
        reg_fibra_pm TEXT,
        reg_fibra_mfd TEXT,

        reg_esquila_esquilador_id INTEGER,
        reg_esquila_fecha TEXT,
        reg_esquila_tipo_esquila TEXT,
        reg_esquila_inca_esquila INTEGER,
        reg_esquila_peso_manto TEXT,
        reg_esquila_peso_cuello TEXT,
        reg_esquila_peso_braga TEXT,
        reg_esquila_peso_total TEXT,
        reg_esquila_longitud TEXT,
        reg_esquila_observacion TEXT,

        reg_medicacion_producto_veterrinario_id INTEGER,
        reg_medicacion_responsable_id INTEGER,
        reg_medicacion_fecha TEXT,
        reg_medicacion_tipo TEXT,
        reg_medicacion_docis TEXT,
        reg_medicacion_unidades TEXT,
        reg_medicacion_observacion TEXT

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

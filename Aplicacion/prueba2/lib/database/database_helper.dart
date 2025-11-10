import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE USUARIO (
        id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
        config_notificaciones BOOLEAN DEFAULT TRUE,
        tema_aplicacion TEXT DEFAULT 'claro'
      )
    ''');

    await db.execute('''
      CREATE TABLE SESION_VOZ (
        id_sesion INTEGER PRIMARY KEY AUTOINCREMENT,
        id_usuario INTEGER NOT NULL,
        fecha_hora_inicio DATETIME DEFAULT CURRENT_TIMESTAMP,
        fecha_hora_fin DATETIME,
        audio_duracion_segundos INTEGER,
        texto_transcrito TEXT,
        FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
      )
    ''');

    await db.execute('''
      CREATE TABLE TIPO_EJERCICIO (
        id_tipo_ejercicio INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        duracion_recomendada_minutos INTEGER,
        audio_guia_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS SESION_VOZ (
        id_sesion INTEGER PRIMARY KEY AUTOINCREMENT,
        id_usuario INTEGER NOT NULL,
        fecha_hora_inicio TEXT NOT NULL,
        fecha_hora_fin TEXT,
        audio_duracion_segundos INTEGER,
        texto_transcrito TEXT,
        FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
      )
    ''');

    // Tabla ANALISIS_EMOCIONAL
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ANALISIS_EMOCIONAL (
        id_analisis INTEGER PRIMARY KEY AUTOINCREMENT,
        id_sesion INTEGER NOT NULL,
        nivel_ansiedad TEXT NOT NULL,
        palabras_clave_detectadas TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (id_sesion) REFERENCES SESION_VOZ(id_sesion)
      )
    ''');
    print('✅ Tabla ANALISIS_EMOCIONAL creada');

    // Tabla RESPUESTA_ASISTENTE
    await db.execute('''
      CREATE TABLE IF NOT EXISTS RESPUESTA_ASISTENTE (
        id_respuesta INTEGER PRIMARY KEY AUTOINCREMENT,
        id_sesion INTEGER NOT NULL,
        id_tipo_ejercicio_recomendado INTEGER,
        respuesta_texto TEXT NOT NULL,
        tecnica_aplicada TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (id_sesion) REFERENCES SESION_VOZ(id_sesion),
        FOREIGN KEY (id_tipo_ejercicio_recomendado) REFERENCES TIPO_EJERCICIO(id_tipo_ejercicio)
      )
    ''');
    print('✅ Tabla RESPUESTA_ASISTENTE creada');


    // Tabla EJERCICIO_REALIZADO
    await db.execute('''
      CREATE TABLE IF NOT EXISTS EJERCICIO_REALIZADO (
        id_ejercicio INTEGER PRIMARY KEY AUTOINCREMENT,
        id_usuario INTEGER NOT NULL,
        id_tipo_ejercicio INTEGER NOT NULL,
        fecha_hora_inicio TEXT NOT NULL,
        fecha_hora_fin TEXT,
        duracion_real_segundos INTEGER,
        nivel_ansiedad_inicial TEXT,
        nivel_ansiedad_final TEXT,
        satisfaccion_usuario INTEGER,
        FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario),
        FOREIGN KEY (id_tipo_ejercicio) REFERENCES TIPO_EJERCICIO(id_tipo_ejercicio)
      )
    ''');
    print('✅ Tabla EJERCICIO_REALIZADO creada');


    // Insertar tipos de ejercicio por defecto
    await _insertDefaultExerciseTypes(db);
  }

  Future<void> _insertDefaultExerciseTypes(Database db) async {
    try {
      // Verificar si ya existen los tipos de ejercicio
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM TIPO_EJERCICIO');
      final count = result.first['count'] as int? ?? 0;
      
      if (count == 0) {
        await db.insert('TIPO_EJERCICIO', {
          'nombre': 'Respiración',
          'descripcion': 'Ejercicios de respiración guiada para calmar la ansiedad',
          'duracion_recomendada_minutos': 5,
          'audio_guia_url': ''
        });
  
        await db.insert('TIPO_EJERCICIO', {
          'nombre': 'Mindfulness',
          'descripcion': 'Meditación guiada para atención plena',
          'duracion_recomendada_minutos': 10,
          'audio_guia_url': ''
        });
  
        await db.insert('TIPO_EJERCICIO', {
          'nombre': 'Grounding',
          'descripcion': 'Técnicas para conectar con el presente',
          'duracion_recomendada_minutos': 5,
          'audio_guia_url': ''
        });
        
        print('✅ Tipos de ejercicio insertados correctamente');
      } else {
        print('ℹ️ Tipos de ejercicio ya existen en la base de datos');
      }
    } catch (e) {
      print('❌ Error insertando tipos de ejercicio: $e');
    }

  }

}
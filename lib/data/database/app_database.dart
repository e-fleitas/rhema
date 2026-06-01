// lib/data/database/app_database.dart
//
// Definición del esquema SQLite y punto de conexión a la base de datos.
//
// drift genera automáticamente el archivo app_database.g.dart
// a partir de este archivo. Ese archivo NO se edita manualmente.
// Para regenerarlo: flutter pub run build_runner build
//
// La anotación @DriftDatabase le dice a drift qué tablas y DAOs
// forman parte de esta base de datos.

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// Esta línea importa el código generado por build_runner.
// Dará error hasta que corramos el generador por primera vez.
part 'app_database.g.dart';

// ─── DEFINICIÓN DE TABLAS ─────────────────────────────────────────────────────
//
// Cada clase que extiende Table define una tabla en SQLite.
// Los campos son getters que retornan tipos de columna de drift.
// drift infiere el nombre de la tabla del nombre de la clase en snake_case.
// BooksTable → tabla "books_table". Para personalizar: override get tableName.

// Tabla de libros de la Biblia.
class BooksTable extends Table {
  @override
  String get tableName => 'books';

  // IntColumn: columna de tipo INTEGER en SQLite.
  // autoIncrement() marca esta columna como PRIMARY KEY AUTOINCREMENT.
  IntColumn get id => integer().autoIncrement()();

  // TextColumn: columna de tipo TEXT en SQLite.
  // withLength establece validación de longitud (no un constraint SQL,
  // sino validación a nivel de Dart).
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get abbreviation => text().withLength(min: 1, max: 10)();

  // Almacenamos el testamento como String ('old' o 'new_').
  // drift no tiene tipo enum nativo, pero lo mapeamos en el DAO.
  TextColumn get testament => text().withLength(min: 3, max: 4)();

  IntColumn get chapterCount => integer()();

  // Posición en el canon. Usamos unique() para garantizar que
  // no haya dos libros con el mismo orden.
  IntColumn get order => integer().unique()();
}

// Tabla de versículos.
class VersesTable extends Table {
  @override
  String get tableName => 'verses';

  // drift maneja el id como PRIMARY KEY autoincremental.
  // El id canónico bíblico (bookId*1_000_000 + chapter*1_000 + verse)
  // lo calculamos y almacenamos en la columna canonicalId.
  IntColumn get id => integer().autoIncrement()();

  // Id canónico bíblico para búsquedas y referencias cruzadas.
  // Tiene índice único para garantizar que no se dupliquen versículos.
  IntColumn get canonicalId => integer().unique()();

  IntColumn get bookId => integer().references(BooksTable, #id)();
  TextColumn get bookName => text().withLength(min: 1, max: 100)();
  IntColumn get chapter => integer()();
  IntColumn get verseNumber => integer()();
  TextColumn get text => text()();
}

// Tabla de playlists.
class PlaylistsTable extends Table {
  @override
  String get tableName => 'playlists';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();

  // Almacenamos DateTime como INTEGER (Unix timestamp en milisegundos).
  // drift maneja la conversión automáticamente con el tipo DateTimeColumn.
  DateTimeColumn get createdAt => dateTime()();

  // Modo de reproducción como String ('sequential', 'shuffle', 'loop').
  TextColumn get playbackMode => text().withDefault(const Constant('sequential'))();
  IntColumn get lastPlayedIndex => integer().withDefault(const Constant(0))();
}

// Tabla de ítems de playlist.
class PlaylistItemsTable extends Table {
  @override
  String get tableName => 'playlist_items';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get playlistId => integer().references(PlaylistsTable, #id)();

  // Tipo como String ('verse', 'chapter', 'book').
  TextColumn get type => text().withLength(min: 4, max: 7)();

  IntColumn get bookId => integer()();
  IntColumn get order => integer()();

  // Campos opcionales según el tipo de ítem.
  IntColumn get chapter => integer().nullable()();
  IntColumn get verseNumber => integer().nullable()();
  TextColumn get label => text().nullable()();
}

// ─── CONEXIÓN A LA BASE DE DATOS ──────────────────────────────────────────────

// La anotación @DriftDatabase registra las tablas que forman el esquema.
// drift genera la clase _$AppDatabase en app_database.g.dart.
@DriftDatabase(tables: [BooksTable, VersesTable, PlaylistsTable, PlaylistItemsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // schemaVersion debe incrementarse cada vez que modifiques el esquema.
  // drift usa este número para ejecutar las migraciones correctas.
  // Empezamos en 1 y solo subimos cuando cambiamos tablas.
  @override
  int get schemaVersion => 1;

  // migration define qué hacer cuando schemaVersion cambia.
  // Por ahora solo soportamos la creación inicial (from: 0, to: 1).
  // En versiones futuras agregaremos ALTER TABLE y migraciones de datos.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
      );
}

// _openConnection crea la conexión física al archivo SQLite en disco.
// Es una función de nivel superior (no un método de clase) porque
// drift la necesita antes de que AppDatabase esté inicializada.
LazyDatabase _openConnection() {
  // LazyDatabase abre la conexión solo cuando se realiza la primera query,
  // no al instanciar AppDatabase. Esto evita bloquear el arranque de la app.
  return LazyDatabase(() async {
    // getApplicationDocumentsDirectory() retorna la carpeta privada
    // de la app en Android: /data/data/com.rhema/files/
    // El usuario no puede acceder a esta carpeta sin root.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'rhema.db'));
    return NativeDatabase.createInBackground(file);
  });
}
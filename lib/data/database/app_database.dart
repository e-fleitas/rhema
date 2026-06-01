// lib/data/database/app_database.dart
//
// Capa de base de datos SQLite usando sqflite directamente.
//
// Responsabilidades:
//   1. Crear y versionar el esquema de la base de datos.
//   2. Proveer acceso a la instancia singleton de la DB.
//   3. Definir las migraciones entre versiones del esquema.
//
// A diferencia de drift, sqflite no genera código. Escribimos
// SQL explícito, lo que hace el código más portable y auditable.

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static Database? _database;

  // Versión actual del esquema. Incrementar cuando se modifiquen tablas.
  static const int _schemaVersion = 1;

  static const String dbName = 'rhema.db';

  // Nombres de tablas como constantes para evitar errores tipográficos.
  static const String tableBooks = 'books';
  static const String tableVerses = 'verses';
  static const String tablePlaylists = 'playlists';
  static const String tablePlaylistItems = 'playlist_items';

  // Retorna la instancia de la base de datos, creándola si no existe.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, dbName);

    return openDatabase(
      path,
      version: _schemaVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      // Activa foreign keys en SQLite (desactivadas por defecto).
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Crea todas las tablas en la primera instalación.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_createBooksTable);
    await db.execute(_createVersesTable);
    await db.execute(_createPlaylistsTable);
    await db.execute(_createPlaylistItemsTable);
    await db.execute(_createVersesIndex);
  }

  // Maneja migraciones entre versiones del esquema.
  // Por ahora solo existe la versión 1, pero la estructura
  // está lista para agregar casos cuando sea necesario.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Ejemplo para versión futura:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE books ADD COLUMN color TEXT');
    // }
  }

  // ── DDL: Definición de tablas ────────────────────────────────────────────

  static const String _createBooksTable = '''
    CREATE TABLE $tableBooks (
      id          INTEGER PRIMARY KEY,
      name        TEXT    NOT NULL,
      abbreviation TEXT   NOT NULL,
      testament   TEXT    NOT NULL CHECK(testament IN ('old', 'new_')),
      chapter_count INTEGER NOT NULL,
      sort_order  INTEGER NOT NULL UNIQUE
    )
  ''';

  // canonicalId: (bookId * 1_000_000) + (chapter * 1_000) + verseNumber
  // Permite ordenar y referenciar versículos con un solo entero.
  static const String _createVersesTable = '''
    CREATE TABLE $tableVerses (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      canonical_id  INTEGER NOT NULL UNIQUE,
      book_id       INTEGER NOT NULL,
      book_name     TEXT    NOT NULL,
      chapter       INTEGER NOT NULL,
      verse_number  INTEGER NOT NULL,
      text          TEXT    NOT NULL,
      FOREIGN KEY (book_id) REFERENCES $tableBooks(id)
    )
  ''';

  static const String _createPlaylistsTable = '''
    CREATE TABLE $tablePlaylists (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      name            TEXT    NOT NULL,
      description     TEXT,
      created_at      INTEGER NOT NULL,
      playback_mode   TEXT    NOT NULL DEFAULT 'sequential',
      last_played_idx INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const String _createPlaylistItemsTable = '''
    CREATE TABLE $tablePlaylistItems (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      playlist_id   INTEGER NOT NULL,
      type          TEXT    NOT NULL CHECK(type IN ('verse', 'chapter', 'book')),
      book_id       INTEGER NOT NULL,
      sort_order    INTEGER NOT NULL,
      chapter       INTEGER,
      verse_number  INTEGER,
      label         TEXT,
      FOREIGN KEY (playlist_id) REFERENCES $tablePlaylists(id)
        ON DELETE CASCADE
    )
  ''';

  // Índice compuesto para acelerar la query más frecuente:
  // "dame todos los versículos del capítulo X del libro Y"
  static const String _createVersesIndex = '''
    CREATE INDEX idx_verses_book_chapter
    ON $tableVerses (book_id, chapter)
  ''';

  // Cierra la conexión. Llamar al cerrar la app.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
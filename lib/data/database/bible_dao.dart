// lib/data/database/bible_dao.dart
//
// DAO para operaciones de lectura y escritura de libros y versículos.
//
// Todas las queries SQL relacionadas con la Biblia viven aquí.
// Ninguna otra capa del sistema toca SQL directamente.

import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

class BibleDao {
  BibleDao(this._db);

  final Database _db;

  // ── Queries de libros ────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllBooks() {
    return _db.query(
      AppDatabase.tableBooks,
      orderBy: 'sort_order ASC',
    );
  }

  Future<Map<String, dynamic>?> getBookById(int id) async {
    final results = await _db.query(
      AppDatabase.tableBooks,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  Future<List<Map<String, dynamic>>> getBooksByTestament(
    String testament,
  ) {
    return _db.query(
      AppDatabase.tableBooks,
      where: 'testament = ?',
      whereArgs: [testament],
      orderBy: 'sort_order ASC',
    );
  }

  // ── Queries de versículos ────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getVersesForChapter({
    required int bookId,
    required int chapter,
  }) {
    return _db.query(
      AppDatabase.tableVerses,
      where: 'book_id = ? AND chapter = ?',
      whereArgs: [bookId, chapter],
      orderBy: 'verse_number ASC',
    );
  }

  Future<Map<String, dynamic>?> getVerseByCanonicalId(
    int canonicalId,
  ) async {
    final results = await _db.query(
      AppDatabase.tableVerses,
      where: 'canonical_id = ?',
      whereArgs: [canonicalId],
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  // Búsqueda de texto libre en versículos.
  // LIKE con % es case-insensitive en SQLite para ASCII.
  // Limitamos a 50 resultados para no saturar la UI.
  Future<List<Map<String, dynamic>>> searchVerses(String query) {
    return _db.query(
      AppDatabase.tableVerses,
      where: 'text LIKE ?',
      whereArgs: ['%$query%'],
      limit: 50,
    );
  }

  Future<int> getVerseCountForChapter({
    required int bookId,
    required int chapter,
  }) async {
    final result = await _db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM ${AppDatabase.tableVerses}
      WHERE book_id = ? AND chapter = ?
      ''',
      [bookId, chapter],
    );
    return result.first['count'] as int? ?? 0;
  }

  // ── Operaciones de escritura (solo para el importador) ───────────────────

  // Inserta libros en batch dentro de una transacción.
  // ConflictAlgorithm.replace reemplaza si ya existe el mismo id.
  Future<void> insertBooks(
    List<Map<String, dynamic>> books,
  ) async {
    final batch = _db.batch();
    for (final book in books) {
      batch.insert(
        AppDatabase.tableBooks,
        book,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Inserta versículos en batch. Para Biblias completas (31.000+
  // versículos) los dividimos en chunks de 500 para no saturar
  // la memoria en dispositivos de gama baja.
  Future<void> insertVerses(
    List<Map<String, dynamic>> verses,
  ) async {
    const chunkSize = 500;
    for (var i = 0; i < verses.length; i += chunkSize) {
      final end = (i + chunkSize < verses.length)
          ? i + chunkSize
          : verses.length;
      final chunk = verses.sublist(i, end);

      final batch = _db.batch();
      for (final verse in chunk) {
        batch.insert(
          AppDatabase.tableVerses,
          verse,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }
  }
}
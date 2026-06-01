// lib/data/repositories/bible_repository.dart
//
// Repositorio de la Biblia.
//
// Responsabilidades:
//   1. Actuar como única fuente de verdad para datos bíblicos.
//   2. Convertir los Map<String, dynamic> crudos del DAO
//      en objetos de dominio tipados (Book, Verse).
//   3. Abstraer la fuente de datos: la UI no sabe si los datos
//      vienen de SQLite, de un archivo JSON, o de memoria.
//
// Regla: ningún widget ni BLoC importa sqflite o toca SQL.
// Todo pasa por este repositorio.

import '../../core/models/book.dart';
import '../../core/models/verse.dart';
import '../database/bible_dao.dart';

class BibleRepository {
  BibleRepository(this._dao);

  final BibleDao _dao;

  // ── Libros ───────────────────────────────────────────────────────────────

  Future<List<Book>> getAllBooks() async {
    final rows = await _dao.getAllBooks();
    return rows.map(_rowToBook).toList();
  }

  Future<Book?> getBookById(int id) async {
    final row = await _dao.getBookById(id);
    return row == null ? null : _rowToBook(row);
  }

  Future<List<Book>> getBooksByTestament(Testament testament) async {
    // Convertimos el enum a String para la query SQL.
    final testamentStr = testament == Testament.old ? 'old' : 'new_';
    final rows = await _dao.getBooksByTestament(testamentStr);
    return rows.map(_rowToBook).toList();
  }

  // ── Versículos ───────────────────────────────────────────────────────────

  Future<List<Verse>> getVersesForChapter({
    required int bookId,
    required int chapter,
  }) async {
    final rows = await _dao.getVersesForChapter(
      bookId: bookId,
      chapter: chapter,
    );
    return rows.map(_rowToVerse).toList();
  }

  Future<Verse?> getVerseByCanonicalId(int canonicalId) async {
    final row = await _dao.getVerseByCanonicalId(canonicalId);
    return row == null ? null : _rowToVerse(row);
  }

  Future<List<Verse>> searchVerses(String query) async {
    if (query.trim().isEmpty) return [];
    final rows = await _dao.searchVerses(query.trim());
    return rows.map(_rowToVerse).toList();
  }

  Future<int> getVerseCountForChapter({
    required int bookId,
    required int chapter,
  }) {
    return _dao.getVerseCountForChapter(
      bookId: bookId,
      chapter: chapter,
    );
  }

  // ── Conversores privados (Map → modelo de dominio) ───────────────────────
  //
  // Estos métodos son el puente entre el mundo SQL (snake_case, tipos
  // primitivos) y el mundo Dart (camelCase, tipos semánticos).
  // Si el esquema cambia, solo cambian estos métodos.

  Book _rowToBook(Map<String, dynamic> row) {
    return Book(
      id: row['id'] as int,
      name: row['name'] as String,
      abbreviation: row['abbreviation'] as String,
      testament: row['testament'] == 'old' ? Testament.old : Testament.new_,
      chapterCount: row['chapter_count'] as int,
      order: row['sort_order'] as int,
    );
  }

  Verse _rowToVerse(Map<String, dynamic> row) {
    return Verse(
      id: row['canonical_id'] as int,
      bookId: row['book_id'] as int,
      bookName: row['book_name'] as String,
      chapter: row['chapter'] as int,
      verseNumber: row['verse_number'] as int,
      text: row['text'] as String,
    );
  }

  // ── Escritura (delegada al importador) ───────────────────────────────────

  // Estos métodos los llamará el importador de Biblias (Hito 4).
  // El repositorio los expone para que el importador no toque el DAO.

  Future<void> insertBooks(List<Book> books) async {
    final rows = books.map(_bookToRow).toList();
    await _dao.insertBooks(rows);
  }

  Future<void> insertVerses(List<Verse> verses) async {
    final rows = verses.map(_verseToRow).toList();
    await _dao.insertVerses(rows);
  }

  Map<String, dynamic> _bookToRow(Book book) {
    return {
      'id': book.id,
      'name': book.name,
      'abbreviation': book.abbreviation,
      'testament': book.testament == Testament.old ? 'old' : 'new_',
      'chapter_count': book.chapterCount,
      'sort_order': book.order,
    };
  }

  Map<String, dynamic> _verseToRow(Verse verse) {
    return {
      'canonical_id': verse.id,
      'book_id': verse.bookId,
      'book_name': verse.bookName,
      'chapter': verse.chapter,
      'verse_number': verse.verseNumber,
      'text': verse.text,
    };
  }
}
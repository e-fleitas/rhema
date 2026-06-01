// lib/data/importers/json_bible_importer.dart
//
// Importador de Biblias en formato JSON.
//
// Soporta el formato thiagobodruk:
// [{"abbrev": "gn", "chapters": [["v1", "v2"], ["v1"...]]}, ...]
//
// El proceso completo es:
//   1. Leer el archivo JSON desde assets o desde el sistema de archivos.
//   2. Parsear la estructura y mapear abreviaturas a metadatos.
//   3. Construir objetos Book y Verse.
//   4. Insertar en SQLite via BibleRepository en chunks.
//   5. Reportar progreso via Stream para actualizar la UI.

import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/models/book.dart';
import '../../core/models/verse.dart';
import '../repositories/bible_repository.dart';
import 'bible_metadata.dart';

// ImportProgress representa el estado actual de una importación.
class ImportProgress {
  const ImportProgress({
    required this.currentBook,
    required this.totalBooks,
    required this.bookName,
    this.isComplete = false,
    this.error,
  });

  final int currentBook;
  final int totalBooks;
  final String bookName;
  final bool isComplete;
  final String? error;

  double get percentage => totalBooks == 0 ? 0 : currentBook / totalBooks;

  bool get hasError => error != null;
}

class JsonBibleImporter {
  JsonBibleImporter(this._repository);

  final BibleRepository _repository;

  // Importa una Biblia desde los assets del APK.
  // assetPath: ruta relativa a assets/, ej: 'bibles/es_rv1909.json'
  // language: 'es' o 'en', determina qué nombre de libro usar.
  Stream<ImportProgress> importFromAssets({
    required String assetPath,
    required String language,
  }) async* {
    yield* _runImport(
      loader: () => rootBundle.loadString('assets/$assetPath'),
      language: language,
    );
  }

  // Importa una Biblia desde una ruta absoluta del sistema de archivos.
  // Para cuando el usuario importa su propia Biblia desde Downloads.
  Stream<ImportProgress> importFromFile({
    required String filePath,
    required String language,
  }) async* {
    yield* _runImport(
      loader: () async {
        // Usamos un Isolate para leer el archivo sin bloquear la UI.
        // Los archivos de Biblia son grandes (4+ MB) y parsearlos
        // en el hilo principal congelaría la pantalla.
        return await Isolate.run(() async {
          // Leemos el archivo en el isolate secundario.
          final bytes = await rootBundle.loadString(filePath);
          return bytes;
        });
      },
      language: language,
    );
  }

  // Núcleo del importador. Recibe un loader que provee el JSON
  // como String, y emite eventos de progreso mientras inserta.
  Stream<ImportProgress> _runImport({
    required Future<String> Function() loader,
    required String language,
  }) async* {
    try {
      // 1. Cargar el JSON
      final jsonString = await loader();

      // 2. Parsear. jsonDecode retorna dynamic; lo casteamos explícitamente.
      final List<dynamic> jsonData = jsonDecode(jsonString) as List<dynamic>;

      final totalBooks = jsonData.length;
      final books = <Book>[];
      final verses = <Verse>[];

      // 3. Iterar por cada libro del JSON
      for (var bookIndex = 0; bookIndex < jsonData.length; bookIndex++) {
        final bookJson = jsonData[bookIndex] as Map<String, dynamic>;
        final abbrev = bookJson['abbrev'] as String;

        // Buscar metadatos por abreviatura
        final meta = kBibleMetadataByAbbrev[abbrev];
        if (meta == null) {
          // Abreviatura desconocida: la saltamos con un warning.
          // Esto puede pasar con libros apócrifos en algunas versiones.
          continue;
        }

        final bookId = meta['id'] as int;
        final bookName = language == 'es'
            ? meta['name_es'] as String
            : meta['name_en'] as String;

        // Emitir progreso antes de procesar cada libro
        yield ImportProgress(
          currentBook: bookIndex + 1,
          totalBooks: totalBooks,
          bookName: bookName,
        );

        // Construir el objeto Book
        books.add(Book(
          id: bookId,
          name: bookName,
          abbreviation: abbrev,
          testament: meta['testament'] == 'old' ? Testament.old : Testament.new_,
          chapterCount: meta['chapters'] as int,
          order: bookId,
        ));

        // 4. Iterar por capítulos y versículos
        final chapters = bookJson['chapters'] as List<dynamic>;
        for (var chapIndex = 0; chapIndex < chapters.length; chapIndex++) {
          final chapterNumber = chapIndex + 1; // 1-based
          final verseList = chapters[chapIndex] as List<dynamic>;

          for (var verseIndex = 0; verseIndex < verseList.length; verseIndex++) {
            final verseNumber = verseIndex + 1; // 1-based
            final text = verseList[verseIndex] as String;

            // Calcular el id canónico bíblico
            final canonicalId =
                (bookId * 1000000) + (chapterNumber * 1000) + verseNumber;

            verses.add(Verse(
              id: canonicalId,
              bookId: bookId,
              bookName: bookName,
              chapter: chapterNumber,
              verseNumber: verseNumber,
              text: text,
            ));
          }
        }

        // Insertar en chunks cada 5 libros para no acumular
        // demasiados versículos en memoria en dispositivos lentos.
        if (books.length >= 5) {
          await _repository.insertBooks(books);
          await _repository.insertVerses(verses);
          books.clear();
          verses.clear();
        }
      }

      // Insertar el remanente final
      if (books.isNotEmpty) {
        await _repository.insertBooks(books);
        await _repository.insertVerses(verses);
      }

      // 5. Emitir completado
      yield ImportProgress(
        currentBook: totalBooks,
        totalBooks: totalBooks,
        bookName: '',
        isComplete: true,
      );
    } catch (e) {
      yield ImportProgress(
        currentBook: 0,
        totalBooks: 0,
        bookName: '',
        error: e.toString(),
      );
    }
  }
}
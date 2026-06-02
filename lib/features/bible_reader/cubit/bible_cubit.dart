// lib/features/bible_reader/cubit/bible_cubit.dart
//
// Cubit que maneja la lógica de navegación bíblica.
//
// Un Cubit es una clase que:
//   1. Recibe eventos (llamadas a métodos)
//   2. Ejecuta lógica de negocio
//   3. Emite nuevos estados
//
// La UI observa el estado y se reconstruye automáticamente.
// El Cubit no conoce widgets ni BuildContext: es Dart puro.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/book.dart';
import '../../../data/repositories/bible_repository.dart';
import 'bible_state.dart';

class BibleCubit extends Cubit<BibleState> {
  BibleCubit(this._repository) : super(const BibleInitial());

  final BibleRepository _repository;

  // Carga todos los libros y los separa por testamento.
  // Llamado al abrir la pantalla de libros.
  Future<void> loadBooks() async {
    emit(const BibleLoading());

    try {
      final allBooks = await _repository.getAllBooks();

      final oldTestament = allBooks
          .where((b) => b.testament == Testament.old)
          .toList();

      final newTestament = allBooks
          .where((b) => b.testament == Testament.new_)
          .toList();

      emit(BooksLoaded(oldTestament: oldTestament, newTestament: newTestament));
    } catch (e) {
      emit(BibleError('Error cargando libros: $e'));
    }
  }

  // Carga los capítulos de un libro específico.
  // chapterCount ya está en el modelo Book, no necesitamos
  // consultar la DB: solo emitimos el estado con esos datos.
  void loadChapters(Book book) {
    emit(const BibleLoading());
    emit(ChaptersLoaded(book: book, chapterCount: book.chapterCount));
  }

  // Carga los versículos de un capítulo específico.
  Future<void> loadVerses({required Book book, required int chapter}) async {
    emit(const BibleLoading());

    try {
      final verses = await _repository.getVersesForChapter(
        bookId: book.id,
        chapter: chapter,
      );

      emit(VersesLoaded(book: book, chapter: chapter, verses: verses));
    } catch (e) {
      emit(BibleError('Error cargando versículos: $e'));
    }
  }
}

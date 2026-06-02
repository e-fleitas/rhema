// lib/features/bible_reader/cubit/bible_state.dart
//
// Estados del BibleCubit.
//
// En BLoC/Cubit, el estado es la única fuente de verdad de la UI.
// La pantalla no guarda datos localmente: todo viene del estado.
//
// Usamos clases selladas (sealed) de Dart 3 para que el compilador
// nos obligue a manejar todos los casos en los switches de la UI.
// Si agregas un estado nuevo y olvidas manejarlo en un switch,
// el compilador lanza un error. Eso es seguridad de tipos real.

import 'package:equatable/equatable.dart';

import '../../../core/models/book.dart';
import '../../../core/models/verse.dart';

// BibleState es la clase base sellada.
// 'sealed' significa que todas las subclases deben estar
// en el mismo archivo. Nadie puede extenderla desde afuera.
sealed class BibleState extends Equatable {
  const BibleState();
}

// Estado inicial antes de cargar cualquier dato.
class BibleInitial extends BibleState {
  const BibleInitial();

  @override
  List<Object?> get props => [];
}

// Cargando datos desde SQLite.
class BibleLoading extends BibleState {
  const BibleLoading();

  @override
  List<Object?> get props => [];
}

// Lista de libros cargada correctamente.
class BooksLoaded extends BibleState {
  const BooksLoaded({required this.oldTestament, required this.newTestament});

  // Separamos los libros por testamento para mostrarlos
  // en dos secciones en la UI, igual que YouVersion.
  final List<Book> oldTestament;
  final List<Book> newTestament;

  @override
  List<Object?> get props => [oldTestament, newTestament];
}

// Lista de capítulos de un libro cargada.
class ChaptersLoaded extends BibleState {
  const ChaptersLoaded({required this.book, required this.chapterCount});

  final Book book;

  // chapterCount es un int simple porque los capítulos son
  // solo números del 1 al N. No necesitamos objetos Chapter.
  final int chapterCount;

  @override
  List<Object?> get props => [book, chapterCount];
}

// Versículos de un capítulo cargados.
class VersesLoaded extends BibleState {
  const VersesLoaded({
    required this.book,
    required this.chapter,
    required this.verses,
  });

  final Book book;
  final int chapter;
  final List<Verse> verses;

  @override
  List<Object?> get props => [book, chapter, verses];
}

// Error al cargar datos.
class BibleError extends BibleState {
  const BibleError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

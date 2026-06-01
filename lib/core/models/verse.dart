// lib/core/models/verse.dart
//
// Modelo de dominio que representa un versículo de la Biblia.
//
// Es la unidad atómica de todo el sistema: las playlists contienen
// versículos, el motor karaoke resalta versículos, el sintetizador
// de voz lee versículos.

import 'package:equatable/equatable.dart';

class Verse extends Equatable {
  const Verse({
    required this.id,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verseNumber,
    required this.text,
  });

  // Identificador único global del versículo dentro de una versión
  // de la Biblia. El formato estándar en bases de datos bíblicas es:
  // (bookId * 1_000_000) + (chapter * 1_000) + verseNumber
  // Ej: Génesis 1:1 → 1_001_001
  // Esto permite ordenar, comparar y buscar versículos con un solo int.
  final int id;

  // Referencia al libro padre. No guardamos el objeto Book completo
  // para evitar dependencias circulares y mantener el modelo liviano.
  final int bookId;

  // Nombre del libro en el idioma de la versión.
  // Lo desnormalizamos aquí para evitar joins frecuentes al mostrar
  // referencias como "Juan 3:16" en la UI.
  final String bookName;

  // Número de capítulo (1-based).
  final int chapter;

  // Número de versículo dentro del capítulo (1-based).
  final int verseNumber;

  // Texto del versículo en el idioma/versión de la Biblia importada.
  final String text;

  // Referencia legible. Ej: "Juan 3:16"
  // Es un getter computado, no un campo almacenado.
  // En Dart, los getters se calculan en el momento de acceso.
  String get reference => '$bookName $chapter:$verseNumber';

  @override
  List<Object?> get props => [
        id,
        bookId,
        bookName,
        chapter,
        verseNumber,
        text,
      ];

  Verse copyWith({
    int? id,
    int? bookId,
    String? bookName,
    int? chapter,
    int? verseNumber,
    String? text,
  }) {
    return Verse(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      bookName: bookName ?? this.bookName,
      chapter: chapter ?? this.chapter,
      verseNumber: verseNumber ?? this.verseNumber,
      text: text ?? this.text,
    );
  }

  @override
  String toString() => 'Verse($reference)';
}
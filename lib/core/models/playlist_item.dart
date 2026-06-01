// lib/core/models/playlist_item.dart
//
// Modelo que representa un ítem dentro de una playlist.
//
// Una playlist puede contener versículos individuales, capítulos
// completos o libros enteros. Este modelo unifica los tres casos
// con un enum de tipo y los campos necesarios para cada uno.

import 'package:equatable/equatable.dart';

// PlaylistItemType define qué representa este ítem.
// Esto nos permite reproducir desde un versículo individual
// hasta un libro entero con el mismo modelo.
enum PlaylistItemType {
  verse,    // Un versículo individual
  chapter,  // Un capítulo completo
  book,     // Un libro completo
}

class PlaylistItem extends Equatable {
  const PlaylistItem({
    required this.id,
    required this.playlistId,
    required this.type,
    required this.bookId,
    required this.order,
    this.chapter,
    this.verseNumber,
    this.label,
  });

  // Identificador único del ítem dentro de la base de datos.
  final int id;

  // Playlist a la que pertenece este ítem.
  final int playlistId;

  // Tipo de contenido que representa.
  final PlaylistItemType type;

  // Libro al que apunta este ítem (siempre requerido).
  final int bookId;

  // Posición dentro de la playlist (0-based).
  // Permite reordenar ítems sin cambiar sus IDs.
  final int order;

  // Capítulo al que apunta. Requerido si type es chapter o verse.
  // Null si type es book.
  final int? chapter;

  // Número de versículo. Requerido solo si type es verse.
  // Null si type es chapter o book.
  final int? verseNumber;

  // Etiqueta personalizada opcional.
  // Ej: "Mi versículo favorito", "Para el culto del domingo"
  final String? label;

  // Descripción legible del ítem para mostrar en la UI.
  // Retorna diferentes formatos según el tipo.
  String get displayTitle {
    return switch (type) {
      PlaylistItemType.verse   => label ?? 'Libro $bookId $chapter:$verseNumber',
      PlaylistItemType.chapter => label ?? 'Libro $bookId — Cap. $chapter',
      PlaylistItemType.book    => label ?? 'Libro $bookId',
    };
  }

  @override
  List<Object?> get props => [
        id,
        playlistId,
        type,
        bookId,
        order,
        chapter,
        verseNumber,
        label,
      ];

  PlaylistItem copyWith({
    int? id,
    int? playlistId,
    PlaylistItemType? type,
    int? bookId,
    int? order,
    int? chapter,
    int? verseNumber,
    String? label,
  }) {
    return PlaylistItem(
      id: id ?? this.id,
      playlistId: playlistId ?? this.playlistId,
      type: type ?? this.type,
      bookId: bookId ?? this.bookId,
      order: order ?? this.order,
      chapter: chapter ?? this.chapter,
      verseNumber: verseNumber ?? this.verseNumber,
      label: label ?? this.label,
    );
  }

  @override
  String toString() => 'PlaylistItem(type: $type, order: $order)';
}
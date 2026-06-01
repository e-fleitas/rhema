// lib/core/models/playlist.dart
//
// Modelo de dominio que representa una playlist de reproducción.
//
// Una playlist es una colección ordenada de PlaylistItems que el
// usuario puede reproducir de corrido, en aleatorio, o en bucle.
// Es el concepto central de la funcionalidad de audio de Rhema.

import 'package:equatable/equatable.dart';

import 'playlist_item.dart';

// PlaybackMode define cómo se reproduce la playlist.
enum PlaybackMode {
  sequential, // De principio a fin en orden
  shuffle,    // Aleatorio
  loop,       // Repetir en bucle
}

class Playlist extends Equatable {
  const Playlist({
    required this.id,
    required this.name,
    required this.createdAt,
    this.description,
    this.items = const [],
    this.playbackMode = PlaybackMode.sequential,
    this.lastPlayedIndex = 0,
  });

  // Identificador único de la playlist en la base de datos.
  final int id;

  // Nombre de la playlist definido por el usuario.
  // Ej: "Salmos de la mañana", "Estudio de Juan"
  final String name;

  // Descripción opcional de la playlist.
  final String? description;

  // Fecha y hora de creación.
  // Usamos DateTime de Dart, no un String ni un timestamp Unix,
  // para aprovechar las operaciones de fecha del lenguaje.
  final DateTime createdAt;

  // Lista de ítems de la playlist en su orden actual.
  // El valor por defecto es una lista vacía inmutable (const []).
  // En Dart, 'const []' es un objeto singleton, más eficiente que [].
  final List<PlaylistItem> items;

  // Modo de reproducción activo.
  final PlaybackMode playbackMode;

  // Índice del último ítem reproducido.
  // Permite retomar la reproducción donde se dejó.
  final int lastPlayedIndex;

  // Número total de ítems en la playlist.
  int get itemCount => items.length;

  // Indica si la playlist tiene al menos un ítem.
  bool get isEmpty => items.isEmpty;

  // Retorna el ítem actual según lastPlayedIndex.
  // Retorna null si la playlist está vacía.
  PlaylistItem? get currentItem {
    if (isEmpty) return null;
    return items[lastPlayedIndex.clamp(0, items.length - 1)];
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        createdAt,
        items,
        playbackMode,
        lastPlayedIndex,
      ];

  Playlist copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    List<PlaylistItem>? items,
    PlaybackMode? playbackMode,
    int? lastPlayedIndex,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      playbackMode: playbackMode ?? this.playbackMode,
      lastPlayedIndex: lastPlayedIndex ?? this.lastPlayedIndex,
    );
  }

  @override
  String toString() => 'Playlist(id: $id, name: $name, items: ${items.length})';
}
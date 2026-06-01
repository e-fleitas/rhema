// lib/core/models/book.dart
//
// Modelo de dominio que representa un libro de la Biblia.
//
// IMPORTANTE: Este archivo no importa nada de Flutter ni de drift.
// Es Dart puro. Eso lo hace testeable de forma aislada y reutilizable
// en cualquier capa de la arquitectura.

import 'package:equatable/equatable.dart';

// Testament enumera los dos testamentos posibles.
// Usar un enum en lugar de un String evita errores tipográficos
// y hace el código más legible y seguro.
enum Testament {
  old,   // Antiguo Testamento
  new_,  // Nuevo Testamento (new_ con guion bajo porque 'new' es palabra reservada en Dart)
}

// Book representa un libro de la Biblia (Génesis, Mateo, etc.)
//
// Extiende Equatable para que dos instancias de Book con los mismos
// datos sean consideradas iguales (==). Sin Equatable, Dart compara
// por referencia de memoria, lo que rompería el sistema de estados de BLoC.
class Book extends Equatable {
  const Book({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.testament,
    required this.chapterCount,
    required this.order,
  });

  // Identificador único del libro (1-66 en el canon protestante).
  // Usamos int porque es el formato estándar en bases de datos de Biblias.
  final int id;

  // Nombre completo del libro en el idioma de la versión importada.
  // Ej: "Génesis", "Genesis", "Genèse"
  final String name;

  // Abreviatura estándar. Ej: "Gen", "Gn", "Gé"
  final String abbreviation;

  // Testamento al que pertenece.
  final Testament testament;

  // Número de capítulos del libro.
  // Lo almacenamos para evitar COUNT queries frecuentes.
  final int chapterCount;

  // Posición en el canon bíblico (1 = Génesis, 66 = Apocalipsis).
  // Permite ordenar los libros correctamente sin depender del id.
  final int order;

  // props le dice a Equatable qué campos usar para la comparación (==)
  // y para hashCode. Deben incluirse TODOS los campos del modelo.
  @override
  List<Object?> get props => [
        id,
        name,
        abbreviation,
        testament,
        chapterCount,
        order,
      ];

  // copyWith permite crear una copia del objeto con uno o más campos
  // modificados, sin mutar el original. Esencial en arquitecturas
  // inmutables como BLoC.
  Book copyWith({
    int? id,
    String? name,
    String? abbreviation,
    Testament? testament,
    int? chapterCount,
    int? order,
  }) {
    return Book(
      id: id ?? this.id,
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      testament: testament ?? this.testament,
      chapterCount: chapterCount ?? this.chapterCount,
      order: order ?? this.order,
    );
  }

  @override
  String toString() => 'Book(id: $id, name: $name, testament: $testament)';
}
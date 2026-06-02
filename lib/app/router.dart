// lib/app/router.dart
//
// Configuración de rutas de navegación de Rhema.
// Hito 5 fix: BibleCubit vive en _BooksScreenWrapper,
// no en cada ruta individual. Las rutas hijas lo heredan
// via BlocProvider.of() sin crear instancias nuevas.

import 'package:flutter/material.dart';
import '../features/bible_reader/view/books_screen.dart';
import '../features/bible_reader/view/chapters_screen.dart';
import '../features/bible_reader/view/verses_screen.dart';

class AppRouter {
  static const String books = '/';
  static const String chapters = '/chapters';
  static const String verses = '/verses';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRouter.books => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const BooksScreen(),
        ),
      AppRouter.chapters => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ChaptersScreen(),
        ),
      AppRouter.verses => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const VersesScreen(),
        ),
      _ => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const BooksScreen(),
        ),
    };
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/bible_reader/cubit/bible_cubit.dart';
import '../features/bible_reader/view/books_screen.dart';
import '../features/bible_reader/view/chapters_screen.dart';
import '../features/bible_reader/view/verses_screen.dart';

class AppRouter {
  static const String books = '/';
  static const String chapters = '/chapters';
  static const String verses = '/verses';

  // El cubit se pasa explícitamente desde _BooksNavigator.
  // Todas las rutas usan el mismo cubit, lo que garantiza
  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    BibleCubit? cubit,
  }) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    final resolvedCubit = cubit ?? args['cubit'] as BibleCubit?;

    debugPrint('=== ROUTE: ${settings.name} | cubit: ${resolvedCubit != null}');

    Widget buildWithCubit(Widget child) {
      if (resolvedCubit != null) {
        return BlocProvider.value(value: resolvedCubit, child: child);
      }
      return child;
    }

    return switch (settings.name) {
      AppRouter.books => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => buildWithCubit(const BooksScreen()),
      ),
      AppRouter.chapters => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => buildWithCubit(const ChaptersScreen()),
      ),
      AppRouter.verses => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => buildWithCubit(const VersesScreen()),
      ),
      _ => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => buildWithCubit(const BooksScreen()),
      ),
    };
  }
}

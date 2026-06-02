import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/service_locator.dart';
import '../features/bible_reader/cubit/bible_cubit.dart';
import '../features/bible_reader/view/books_screen.dart';
import '../features/bible_reader/view/chapters_screen.dart';
import '../features/bible_reader/view/verses_screen.dart';

class AppRouter {
  static const String books = '/';
  static const String chapters = '/chapters';
  static const String verses = '/verses';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Extraemos el cubit de los argumentos si viene, o lo creamos.
    // Todas las rutas de lectura comparten el mismo cubit.
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    final cubit = args['cubit'] as BibleCubit? ?? sl<BibleCubit>();

    return switch (settings.name) {
      AppRouter.books => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const BooksScreen()),
      ),
      AppRouter.chapters => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const ChaptersScreen()),
      ),
      AppRouter.verses => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const VersesScreen()),
      ),
      _ => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const BooksScreen()),
      ),
    };
  }
}

// lib/features/bible_reader/view/chapters_screen.dart
//
// Pantalla de capítulos de un libro.
//
// Muestra una grilla de números del 1 al N donde N es el
// número de capítulos del libro seleccionado.
// Al tocar un número navega a la pantalla de versículos.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/book.dart';
import '../cubit/bible_cubit.dart';
import '../cubit/bible_state.dart';

class ChaptersScreen extends StatefulWidget {
  const ChaptersScreen({super.key});

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  Book? _book;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _book = args?['book'] as Book?;
      if (_book != null) {
        context.read<BibleCubit>().loadChapters(_book!);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cuando volvemos desde VersesScreen el estado es VersesLoaded.
    // Necesitamos recargar los capítulos para mostrar la grilla.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<BibleCubit>().state;
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final book = args?['book'] as Book?;
      if (book != null && state is! ChaptersLoaded) {
        context.read<BibleCubit>().loadChapters(book);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BibleCubit, BibleState>(
      builder: (context, state) {
        final book = state is ChaptersLoaded ? state.book : null;
        return Scaffold(
          appBar: AppBar(
            title: Text(book?.name ?? ''),
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
          ),
          body: switch (state) {
            BibleInitial() ||
            BibleLoading() => const Center(child: CircularProgressIndicator()),
            ChaptersLoaded(:final book, :final chapterCount) => _ChaptersGrid(
              book: book,
              chapterCount: chapterCount,
            ),
            BibleError(:final message) => Center(child: Text(message)),
            _ => Builder(
              builder: (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                final book = args?['book'] as Book?;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted && book != null) {
                    context.read<BibleCubit>().loadChapters(book);
                  }
                });
                return const Center(child: CircularProgressIndicator());
              },
            ),
          },
        );
      },
    );
  }
}

class _ChaptersGrid extends StatelessWidget {
  const _ChaptersGrid({required this.book, required this.chapterCount});

  final Book book;
  final int chapterCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: chapterCount,
      itemBuilder: (context, index) {
        final chapter = index + 1;
        return Material(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              final cubit = context.read<BibleCubit>();
              cubit.loadVerses(book: book, chapter: chapter);
              Navigator.of(context).pushNamed(
                '/verses',
                arguments: {'cubit': cubit, 'book': book, 'chapter': chapter},
              );
            },
            child: Center(
              child: Text(
                '$chapter',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// lib/features/bible_reader/view/books_screen.dart
//
// Pantalla de lista de libros de la Biblia.
//
// Muestra los 66 libros separados en dos secciones:
// Antiguo Testamento y Nuevo Testamento.
// Al tocar un libro navega a la pantalla de capítulos.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/book.dart';
import '../cubit/bible_cubit.dart';
import '../cubit/bible_state.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  @override
  void initState() {
    super.initState();
    // Disparamos la carga de libros al montar la pantalla.
    // initState no es async, por eso llamamos sin await.
    context.read<BibleCubit>().loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rhema'),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO (Hito 6): abrir búsqueda de versículos
            },
          ),
        ],
      ),
      body: BlocBuilder<BibleCubit, BibleState>(
        builder: (context, state) {
          return switch (state) {
            BibleInitial() ||
            BibleLoading() => const Center(child: CircularProgressIndicator()),
            BooksLoaded(:final oldTestament, :final newTestament) => _BooksList(
              oldTestament: oldTestament,
              newTestament: newTestament,
            ),
            BibleError(:final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<BibleCubit>().loadBooks(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
            // Los estados ChaptersLoaded y VersesLoaded no aplican
            // a esta pantalla. Los ignoramos con un widget vacío.
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _BooksList extends StatelessWidget {
  const _BooksList({required this.oldTestament, required this.newTestament});

  final List<Book> oldTestament;
  final List<Book> newTestament;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const _TestamentHeader(title: 'Antiguo Testamento'),
        _BooksGrid(books: oldTestament),
        const _TestamentHeader(title: 'Nuevo Testamento'),
        _BooksGrid(books: newTestament),
        // Padding inferior para que el último libro
        // no quede pegado al borde de la pantalla.
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

class _TestamentHeader extends StatelessWidget {
  const _TestamentHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _BooksGrid extends StatelessWidget {
  const _BooksGrid({required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return _BookCard(book: book);
        },
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          context.read<BibleCubit>().loadChapters(book);
          Navigator.of(context).pushNamed('/chapters', arguments: book);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.abbreviation.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                book.name,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

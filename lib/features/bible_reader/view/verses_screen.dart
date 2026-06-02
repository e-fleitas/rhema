// lib/features/bible_reader/view/verses_screen.dart
//
// Pantalla de versículos de un capítulo.
//
// Es la pantalla más importante de la app: donde el usuario
// lee la Biblia. Muestra los versículos numerados y resalta
// el versículo activo (base para el karaoke en Hito 7).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/book.dart';
import '../../../core/models/verse.dart';
import '../cubit/bible_cubit.dart';
import '../cubit/bible_state.dart';

class VersesScreen extends StatefulWidget {
  const VersesScreen({super.key});

  @override
  State<VersesScreen> createState() => _VersesScreenState();
}

class _VersesScreenState extends State<VersesScreen> {
  // Índice del versículo actualmente resaltado.
  // -1 significa que ninguno está resaltado.
  int _activeVerseIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        final book = args['book'] as Book;
        final chapter = args['chapter'] as int;
        context.read<BibleCubit>().loadVerses(book: book, chapter: chapter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BibleCubit, BibleState>(
      builder: (context, state) {
        final title = state is VersesLoaded
            ? '${state.book.name} ${state.chapter}'
            : '';

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            actions: [
              // Botón placeholder para el reproductor de audio (Hito 7)
              IconButton(
                icon: const Icon(Icons.play_circle_outline),
                onPressed: () {
                  // TODO (Hito 7): iniciar reproducción del capítulo
                },
              ),
            ],
          ),
          body: switch (state) {
            BibleInitial() ||
            BibleLoading() => const Center(child: CircularProgressIndicator()),
            VersesLoaded(:final verses) => _VersesList(
              verses: verses,
              activeVerseIndex: _activeVerseIndex,
              onVerseTap: (index) {
                setState(() {
                  // Tocar el versículo activo lo deselecciona.
                  _activeVerseIndex = _activeVerseIndex == index ? -1 : index;
                });
              },
            ),
            BibleError(:final message) => Center(child: Text(message)),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

class _VersesList extends StatelessWidget {
  const _VersesList({
    required this.verses,
    required this.activeVerseIndex,
    required this.onVerseTap,
  });

  final List<Verse> verses;
  final int activeVerseIndex;
  final void Function(int index) onVerseTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: verses.length,
      itemBuilder: (context, index) {
        final verse = verses[index];
        final isActive = index == activeVerseIndex;
        return _VerseItem(
          verse: verse,
          isActive: isActive,
          onTap: () => onVerseTap(index),
        );
      },
    );
  }
}

class _VerseItem extends StatelessWidget {
  const _VerseItem({
    required this.verse,
    required this.isActive,
    required this.onTap,
  });

  final Verse verse;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // El resaltado karaoke: fondo de color cuando el versículo está activo.
    // En el Hito 7 esto será controlado por el motor de audio,
    // no por el toque del usuario.
    final backgroundColor = isActive
        ? colorScheme.primaryContainer
        : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: colorScheme.onSurface,
            ),
            children: [
              // Número de versículo en superíndice
              WidgetSpan(
                alignment: PlaceholderAlignment.top,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    '${verse.verseNumber}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              TextSpan(text: verse.text),
            ],
          ),
        ),
      ),
    );
  }
}

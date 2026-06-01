// lib/main.dart
//
// Punto de entrada de la aplicación Rhema.
// Actualizado en Hito 3 para inicializar la base de datos
// y el service locator antes de arrancar la UI.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/di/service_locator.dart';
import 'data/repositories/bible_repository.dart';
import 'core/di/service_locator.dart';
import 'data/services/bible_import_service.dart';

@pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializa la base de datos SQLite y registra todos los
  // servicios en get_it antes de que la UI arranque.
  // Si algo falla aquí, lo veremos en los logs antes del splash.
  await setupServiceLocator();

  runApp(const RhemaApp());
}

class RhemaApp extends StatelessWidget {
  const RhemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rhema',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A3C5E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A3C5E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const _SplashPlaceholder(),
    );
  }
}

class _SplashPlaceholder extends StatefulWidget {
  const _SplashPlaceholder();

  @override
  State<_SplashPlaceholder> createState() => _SplashPlaceholderState();
}

class _SplashPlaceholderState extends State<_SplashPlaceholder> {
  ImportProgress? _progress;
  bool _started = false;

  void _startImport() async {
    setState(() => _started = true);
    sl<BibleImportService>()
        .importFromAssets(
          assetPath: 'bibles/es_rv1909.json',
          language: 'es',
          force: true,
        )
        .listen(
          (p) => setState(() => _progress = p),
          onDone: () async {
            final books = await sl<BibleRepository>().getAllBooks();
            debugPrint('=== LIBROS EN DB: ${books.length} ===');
            debugPrint(
              'Primero: ${books.first.name} | Último: ${books.last.name}',
            );
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final p = _progress;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.menu_book_rounded, size: 72),
              const SizedBox(height: 24),
              if (!_started) ...[
                ElevatedButton(
                  onPressed: _startImport,
                  child: const Text('Importar Biblia'),
                ),
              ] else if (p == null) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Iniciando...'),
              ] else if (p.hasError) ...[
                Text(
                  'Error: ${p.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ] else if (p.isComplete) ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 48),
                const SizedBox(height: 16),
                const Text('¡Importación completa!'),
              ] else ...[
                LinearProgressIndicator(value: p.percentage),
                const SizedBox(height: 16),
                Text('${p.bookName} (${p.currentBook}/${p.totalBooks})'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

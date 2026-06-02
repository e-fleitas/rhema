// lib/main.dart
//
// Punto de entrada de Rhema.
// Hito 5: conecta el router de navegación y detecta
// automáticamente si la Biblia ya fue importada.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/router.dart';
import 'core/di/service_locator.dart';
import 'data/services/bible_import_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/bible_repository.dart';
import 'features/bible_reader/cubit/bible_cubit.dart';

@pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const _AppEntry(),
    );
  }
}

// _AppEntry verifica el estado de la DB al arrancar.
// Si la Biblia ya está importada → va directo a BooksScreen.
// Si no → muestra el flujo de onboarding con importación.
class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  @override
  void initState() {
    super.initState();
    _checkAndNavigate();
  }

  Future<void> _checkAndNavigate() async {
    final status = await sl<BibleImportService>().getStatus();

    if (!mounted) return;

    if (status == ImportStatus.completed) {
      // Biblia ya importada: ir directo a la lista de libros.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const _BooksScreenWrapper()),
      );
    } else {
      // Primera vez: mostrar pantalla de onboarding.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const _OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pantalla de splash mientras verificamos el estado.
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Rhema',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// El Cubit vive aquí, en el ancestro común de todas las
// pantallas de lectura. Las rutas hijas lo leen con
// context.read<BibleCubit>() sin necesidad de crearlo de nuevo.
class _BooksScreenWrapper extends StatelessWidget {
  const _BooksScreenWrapper();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BibleCubit(sl<BibleRepository>()),
      // ignore: prefer_const_constructors
      child: Navigator(
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRouter.books,
      ),
    );
  }
}

// Pantalla de onboarding para primera instalación.
// Importa automáticamente la RV1909 y la KJV al abrir la app.
class _OnboardingScreen extends StatefulWidget {
  const _OnboardingScreen();

  @override
  State<_OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<_OnboardingScreen> {
  ImportProgress? _progress;

  @override
  void initState() {
    super.initState();
    _startImport();
  }

  void _startImport() {
    // Importamos la RV1909 primero, luego la KJV.
    sl<BibleImportService>()
        .importFromAssets(assetPath: 'bibles/es_rv1909.json', language: 'es')
        .listen((p) => setState(() => _progress = p), onDone: _importKjv);
  }

  void _importKjv() {
    sl<BibleImportService>()
        .importFromAssets(
          assetPath: 'bibles/en_kjv.json',
          language: 'en',
          force: true,
        )
        .listen((p) => setState(() => _progress = p), onDone: _goToBooks);
  }

  void _goToBooks() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const _BooksScreenWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _progress;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Preparando tu Biblia',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Solo la primera vez',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              if (p == null) ...[
                const CircularProgressIndicator(),
              ] else if (p.hasError) ...[
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  p.error ?? 'Error desconocido',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.error),
                ),
              ] else ...[
                LinearProgressIndicator(value: p.percentage),
                const SizedBox(height: 16),
                Text(
                  p.isComplete ? 'Completado' : p.bookName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

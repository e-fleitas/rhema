import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/router.dart';
import 'core/di/service_locator.dart';
import 'data/repositories/bible_repository.dart';
import 'data/services/bible_import_service.dart';
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
      home: const _AppEntry(),
    );
  }
}

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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const _BooksScreenWrapper()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const _OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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

// BibleCubit vive aquí y se comparte con todas las pantallas hijas
// via BlocProvider. Las rutas hijas lo acceden con context.read<BibleCubit>().
class _BooksScreenWrapper extends StatelessWidget {
  const _BooksScreenWrapper();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BibleCubit(sl<BibleRepository>()),
      child: const _BooksNavigator(),
    );
  }
}

// Navigator dedicado a la navegación bíblica.
// Vive dentro del BlocProvider, así todas sus rutas
// tienen acceso al mismo BibleCubit.
class _BooksNavigator extends StatelessWidget {
  const _BooksNavigator();

  @override
  Widget build(BuildContext context) {
    // Pasamos el cubit al router via los argumentos de la ruta inicial.
    final cubit = context.read<BibleCubit>();
    return Navigator(
      onGenerateRoute: (settings) =>
          AppRouter.onGenerateRoute(settings, cubit: cubit),
      initialRoute: AppRouter.books,
    );
  }
}

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

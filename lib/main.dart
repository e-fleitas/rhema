// lib/main.dart
//
// Punto de entrada de la aplicación Rhema.
//
// Responsabilidades de este archivo:
//   1. Inicializar servicios globales antes de que la UI arranque.
//   2. Configurar la inyección de dependencias (get_it).
//   3. Montar el widget raíz de la aplicación.
//
// Regla: este archivo debe mantenerse delgado. Ninguna lógica de
// negocio vive aquí. Solo bootstrapping y configuración inicial.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Punto de entrada de Dart. La anotación pragma le dice al compilador
// AOT que nunca elimine esta función por optimización (tree-shaking).
@pragma('vm:entry-point')
void main() async {
  // WidgetsFlutterBinding.ensureInitialized() debe llamarse antes de
  // cualquier código que use plugins de Flutter (base de datos, audio,
  // sistema de archivos). Inicializa el binding entre Dart y el motor
  // nativo de Flutter.
  WidgetsFlutterBinding.ensureInitialized();

  // Forzar orientación vertical. Una app de lectura/audio no necesita
  // modo landscape, y bloquearlo evita reconstrucciones innecesarias
  // de widgets cuando el usuario rota el teléfono accidentalmente.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // TODO (Hito 2): Inicializar la base de datos drift.
  // TODO (Hito 3): Registrar servicios en get_it.
  // TODO (Hito 4): Inicializar audio_service.

  runApp(const RhemaApp());
}

// RhemaApp es el widget raíz de la aplicación.
//
// En Flutter, todo es un widget. Este es el ancestro de todos los
// demás. Su única responsabilidad es configurar el MaterialApp:
// tema, rutas, y el widget inicial que se muestra al usuario.
//
// Es un StatelessWidget porque la app en sí no tiene estado propio.
// El estado vive en los Cubits/BLoCs de cada feature.
class RhemaApp extends StatelessWidget {
  const RhemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Nombre que aparece en el task switcher de Android.
      title: 'Rhema',

      // Oculta el banner rojo de "DEBUG" en la esquina superior derecha.
      debugShowCheckedModeBanner: false,

      // TODO (Hito 5): Reemplazar con el tema completo de Rhema.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A3C5E), // Azul oscuro — color primario provisional
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

      // Respetar la preferencia del sistema (claro/oscuro).
      themeMode: ThemeMode.system,

      // Pantalla inicial provisional. La reemplazaremos con el
      // router de navegación completo en el Hito 5.
      home: const _SplashPlaceholder(),
    );
  }
}

// Pantalla provisional de arranque.
//
// Existe únicamente para que la app compile y corra ahora mismo.
// Será eliminada y reemplazada por el sistema de navegación real
// cuando construyamos las features.
class _SplashPlaceholder extends StatelessWidget {
  const _SplashPlaceholder();

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
            const SizedBox(height: 8),
            Text(
              'Local-first Bible',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
}
  }
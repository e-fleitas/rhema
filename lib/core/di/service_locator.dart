// lib/core/di/service_locator.dart
//
// Inyección de dependencias con get_it.
//
// get_it es un "service locator": un registro global donde
// declaramos cómo construir cada servicio de la app.
//
// Ventaja principal: cuando BibleReaderCubit necesita un
// BibleRepository, no recibe el objeto por constructor desde
// main.dart atravesando 5 widgets. Lo pide directamente aquí.
//
// Uso en cualquier parte del código:
//   final repo = sl<BibleRepository>();

import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/database/app_database.dart';
import '../../data/database/bible_dao.dart';
import '../../data/database/playlist_dao.dart';
import '../../data/importers/json_bible_importer.dart';
import '../../data/repositories/bible_repository.dart';
import '../../data/services/bible_import_service.dart';

// sl es la instancia global del service locator.
// El nombre corto facilita su uso en todo el proyecto.
final GetIt sl = GetIt.instance;

// setupServiceLocator inicializa todos los servicios en orden.
// Debe llamarse en main() antes de runApp().
//
// El orden importa: registrar un servicio que depende de otro
// que aún no está registrado lanza una excepción en runtime.
Future<void> setupServiceLocator() async {
  // ── Capa 1: Base de datos ──────────────────────────────────────────────
  //
  // registerSingleton: crea la instancia inmediatamente y la reutiliza
  // siempre. Correcto para la DB porque solo debe existir una conexión.
  //
  // Primero obtenemos la instancia de Database (conexión real a SQLite).
  final Database database = await AppDatabase.instance.database;
  sl.registerSingleton<Database>(database);

  // ── Capa 2: DAOs ───────────────────────────────────────────────────────
  //
  // Los DAOs reciben la Database. Como Database ya está registrada,
  // podemos pedirla con sl<Database>().
  sl.registerSingleton<BibleDao>(
    BibleDao(sl<Database>()),
  );

  sl.registerSingleton<PlaylistDao>(
    PlaylistDao(sl<Database>()),
  );

  // ── Capa 3: Repositorios ───────────────────────────────────────────────
  sl.registerSingleton<BibleRepository>(
    BibleRepository(sl<BibleDao>()),
  );

  // TODO (Hito 5): registrar PlaylistRepository

  // ── Capa 4: Importador e infraestructura de importación ───────────────
  //
  // JsonBibleImporter: lógica pura de parseo y escritura en la DB.
  // No tiene estado propio: se puede registrar como LazySingleton.
  //
  // registerLazySingleton: la instancia se crea la primera vez que
  // alguien la pide (no al arrancar la app). Útil para objetos pesados
  // que quizás nunca se necesiten en una sesión normal (el usuario
  // que ya importó su Biblia nunca activa el importador).
  sl.registerLazySingleton<JsonBibleImporter>(
    () => JsonBibleImporter(sl<BibleRepository>()),
  );

  // BibleImportService: facade de alto nivel sobre JsonBibleImporter.
  // Es lo que los Cubits consumen; encapsula la lógica de "¿ya importé?".
  //
  // También LazySingleton: solo se instancia si la UI del onboarding
  // o algún Cubit lo solicita. En sesiones normales (Biblia ya importada)
  // el servicio se crea pero getStatus() retorna completed sin DB hit
  // después de la primera consulta gracias al caché en memoria.
  sl.registerLazySingleton<BibleImportService>(
    () => BibleImportService(
      repository: sl<BibleRepository>(),
      importer: sl<JsonBibleImporter>(),
    ),
  );
}


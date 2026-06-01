// lib/data/services/bible_import_service.dart
//
// Servicio de importación de Biblias.
//
// Es el "Archivo 3 de 3" del Hito 4: el puente entre el
// JsonBibleImporter (infraestructura pura) y el resto del sistema.
//
// Responsabilidades:
//   1. Verificar si ya existe una Biblia importada antes de reimportar.
//   2. Exponer un Stream<ImportProgress> limpio para que los Cubits
//      lo consuman sin conocer los detalles del importador.
//   3. Persistir el estado de importación (completada / pendiente)
//      usando shared_preferences o una simple tabla de flags en SQLite.
//      En esta versión usamos la presencia de libros en la DB como
//      indicador, sin dependencias extra.
//   4. Proveer un método de reset para re-importar en desarrollo/tests.
//
// Patrón: Facade sobre JsonBibleImporter.
// El BibleImportService conoce el importador, el repositorio Y el
// contexto de negocio (¿ya está importado? ¿qué idioma?).
// Los Cubits no necesitan saber nada de eso.

import '../importers/json_bible_importer.dart';
import '../repositories/bible_repository.dart';

// Re-exportamos ImportProgress para que los consumidores (Cubits, UI)
// importen solo este archivo y no dependan directamente del importador.
export '../importers/json_bible_importer.dart' show ImportProgress;

// ImportStatus describe el estado actual de la base de datos bíblica.
enum ImportStatus {
  // No se ha importado ninguna Biblia todavía.
  notImported,

  // Hay una importación en curso (stream activo).
  importing,

  // La Biblia ya está en la base de datos lista para usarse.
  completed,
}

class BibleImportService {
  BibleImportService({
    required BibleRepository repository,
    required JsonBibleImporter importer,
  })  : _repository = repository,
        _importer = importer;

  final BibleRepository _repository;
  final JsonBibleImporter _importer;

  // Estado actual del servicio.
  // Privado: los consumidores lo leen con getStatus().
  ImportStatus _status = ImportStatus.notImported;

  // ── API pública ──────────────────────────────────────────────────────────

  // Retorna el estado actual de importación.
  // La primera llamada consulta la DB para detectar si ya hay datos.
  // Las siguientes llamadas usan el estado cacheado en memoria.
  Future<ImportStatus> getStatus() async {
    // Si ya sabemos que está en curso o completado, no consultamos la DB.
    if (_status == ImportStatus.importing ||
        _status == ImportStatus.completed) {
      return _status;
    }

    // Consultamos la DB: si hay al menos un libro, la importación
    // fue completada en una sesión anterior.
    final books = await _repository.getAllBooks();
    if (books.isNotEmpty) {
      _status = ImportStatus.completed;
    }
    return _status;
  }

  // Importa una Biblia desde los assets del APK.
  //
  // Parámetros:
  //   assetPath: ruta relativa a assets/, ej: 'bibles/es_rv1909.json'
  //   language:  'es' | 'en' — determina el nombre de los libros.
  //   force:     si true, reimporta aunque ya haya datos (útil en desarrollo).
  //
  // El Stream emite eventos de progreso y cierra automáticamente al
  // terminar o al encontrar un error. El Cubit debe escucharlo así:
  //
  //   sl<BibleImportService>()
  //     .importFromAssets(assetPath: 'bibles/es_rv1909.json', language: 'es')
  //     .listen(
  //       (progress) => emit(ImportingState(progress)),
  //       onDone: () => emit(ImportCompleteState()),
  //       onError: (e) => emit(ImportErrorState(e.toString())),
  //     );
  Stream<ImportProgress> importFromAssets({
    required String assetPath,
    required String language,
    bool force = false,
  }) async* {
    // Guardamos el status antes del check para poder restaurarlo si falla.
    final previousStatus = _status;

    if (!force && _status == ImportStatus.completed) {
      // Ya importado y no se forzó: emitimos completado de inmediato.
      // Esto evita que la UI quede esperando si relanza el flujo de onboarding.
      yield ImportProgress(
        currentBook: 66,
        totalBooks: 66,
        bookName: '',
        isComplete: true,
      );
      return;
    }

    _status = ImportStatus.importing;

    try {
      yield* _importer.importFromAssets(
        assetPath: assetPath,
        language: language,
      );
      _status = ImportStatus.completed;
    } catch (_) {
      // Si el importer lanza directamente (no via el stream de error),
      // restauramos el estado anterior para que el usuario pueda reintentar.
      _status = previousStatus;
      rethrow;
    }
  }

  // Importa una Biblia desde una ruta absoluta del sistema de archivos.
  // Para cuando el usuario elige un .json desde su carpeta de Descargas.
  Stream<ImportProgress> importFromFile({
    required String filePath,
    required String language,
    bool force = false,
  }) async* {
    final previousStatus = _status;

    if (!force && _status == ImportStatus.completed) {
      yield ImportProgress(
        currentBook: 66,
        totalBooks: 66,
        bookName: '',
        isComplete: true,
      );
      return;
    }

    _status = ImportStatus.importing;

    try {
      yield* _importer.importFromFile(
        filePath: filePath,
        language: language,
      );
      _status = ImportStatus.completed;
    } catch (_) {
      _status = previousStatus;
      rethrow;
    }
  }

  // Resetea el estado del servicio a notImported.
  // NO borra los datos de la DB: eso es responsabilidad de una operación
  // de "limpiar datos" separada. Este método es para tests y desarrollo.
  //
  // Para borrar los datos de verdad y reimportar desde cero:
  //   await repository.deleteAllVerses(); // (método a agregar en Hito 5)
  //   service.resetStatus();
  //   await service.importFromAssets(...).last;
  void resetStatus() {
    _status = ImportStatus.notImported;
  }
}
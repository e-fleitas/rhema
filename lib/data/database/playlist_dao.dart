// lib/data/database/playlist_dao.dart
//
// DAO para operaciones CRUD de playlists y sus ítems.
//
// A diferencia de BibleDao que es mayormente de lectura,
// este DAO maneja el ciclo completo: crear, leer, actualizar
// y eliminar playlists que el usuario construye.

import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

class PlaylistDao {
  PlaylistDao(this._db);

  final Database _db;

  // ── Playlists ────────────────────────────────────────────────────────────

  // Retorna todas las playlists ordenadas por fecha de creación descendente.
  // La más reciente aparece primero, igual que en apps de música.
  Future<List<Map<String, dynamic>>> getAllPlaylists() {
    return _db.query(
      AppDatabase.tablePlaylists,
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getPlaylistById(int id) async {
    final results = await _db.query(
      AppDatabase.tablePlaylists,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  // Crea una nueva playlist y retorna su id generado por SQLite.
  Future<int> insertPlaylist(Map<String, dynamic> playlist) {
    return _db.insert(
      AppDatabase.tablePlaylists,
      playlist,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Actualiza campos de una playlist existente.
  // Solo actualiza los campos presentes en el Map, no todos.
  Future<int> updatePlaylist(int id, Map<String, dynamic> fields) {
    return _db.update(
      AppDatabase.tablePlaylists,
      fields,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Elimina una playlist. Los ítems se eliminan automáticamente
  // por el ON DELETE CASCADE definido en el esquema.
  Future<int> deletePlaylist(int id) {
    return _db.delete(
      AppDatabase.tablePlaylists,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── Ítems de playlist ────────────────────────────────────────────────────

  // Retorna los ítems de una playlist ordenados por su posición.
  Future<List<Map<String, dynamic>>> getItemsForPlaylist(
    int playlistId,
  ) {
    return _db.query(
      AppDatabase.tablePlaylistItems,
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
      orderBy: 'sort_order ASC',
    );
  }

  // Agrega un ítem al final de una playlist.
  // Calcula el sort_order máximo actual y le suma 1.
  Future<int> addItemToPlaylist(
    Map<String, dynamic> item,
  ) async {
    final maxOrderResult = await _db.rawQuery(
      '''
      SELECT MAX(sort_order) as max_order
      FROM ${AppDatabase.tablePlaylistItems}
      WHERE playlist_id = ?
      ''',
      [item['playlist_id']],
    );

    final maxOrder = maxOrderResult.first['max_order'] as int? ?? -1;
    final newItem = Map<String, dynamic>.from(item)
      ..['sort_order'] = maxOrder + 1;

    return _db.insert(
      AppDatabase.tablePlaylistItems,
      newItem,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> deleteItem(int itemId) {
    return _db.delete(
      AppDatabase.tablePlaylistItems,
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  // Reordena los ítems de una playlist.
  // Recibe una lista de ids en el nuevo orden deseado
  // y actualiza el sort_order de cada uno dentro de una transacción.
  Future<void> reorderItems(
    int playlistId,
    List<int> orderedItemIds,
  ) async {
    await _db.transaction((txn) async {
      for (var i = 0; i < orderedItemIds.length; i++) {
        await txn.update(
          AppDatabase.tablePlaylistItems,
          {'sort_order': i},
          where: 'id = ? AND playlist_id = ?',
          whereArgs: [orderedItemIds[i], playlistId],
        );
      }
    });
  }

  // Guarda el índice del último ítem reproducido en una playlist.
  // Se llama cada vez que el reproductor avanza al siguiente ítem.
  Future<void> saveLastPlayedIndex(
    int playlistId,
    int index,
  ) {
    return _db.update(
      AppDatabase.tablePlaylists,
      {'last_played_idx': index},
      where: 'id = ?',
      whereArgs: [playlistId],
    ) as Future<void>;
  }
}
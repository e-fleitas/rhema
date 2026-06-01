// lib/data/importers/bible_metadata.dart
//
// Tabla de metadatos de los 66 libros del canon protestante.
//
// El JSON de las Biblias solo contiene abreviaturas ('gn', 'ex'...).
// Este archivo mapea cada abreviatura a su nombre completo,
// testamento, número de capítulos y posición en el canon.
//
// Es un archivo de solo datos, sin lógica.

const List<Map<String, dynamic>> kBibleMetadata = [
  // ── Antiguo Testamento ──────────────────────────────────────────────────
  {'id': 1,  'abbrev': 'gn',  'name_es': 'Génesis',        'name_en': 'Genesis',        'testament': 'old', 'chapters': 50},
  {'id': 2,  'abbrev': 'ex',  'name_es': 'Éxodo',          'name_en': 'Exodus',         'testament': 'old', 'chapters': 40},
  {'id': 3,  'abbrev': 'lv',  'name_es': 'Levítico',       'name_en': 'Leviticus',      'testament': 'old', 'chapters': 27},
  {'id': 4,  'abbrev': 'nm',  'name_es': 'Números',        'name_en': 'Numbers',        'testament': 'old', 'chapters': 36},
  {'id': 5,  'abbrev': 'dt',  'name_es': 'Deuteronomio',   'name_en': 'Deuteronomy',    'testament': 'old', 'chapters': 34},
  {'id': 6,  'abbrev': 'js',  'name_es': 'Josué',          'name_en': 'Joshua',         'testament': 'old', 'chapters': 24},
  {'id': 7,  'abbrev': 'jud', 'name_es': 'Jueces',         'name_en': 'Judges',         'testament': 'old', 'chapters': 21},
  {'id': 8,  'abbrev': 'rt',  'name_es': 'Rut',            'name_en': 'Ruth',           'testament': 'old', 'chapters': 4},
  {'id': 9,  'abbrev': '1sm', 'name_es': '1 Samuel',       'name_en': '1 Samuel',       'testament': 'old', 'chapters': 31},
  {'id': 10, 'abbrev': '2sm', 'name_es': '2 Samuel',       'name_en': '2 Samuel',       'testament': 'old', 'chapters': 24},
  {'id': 11, 'abbrev': '1kgs','name_es': '1 Reyes',        'name_en': '1 Kings',        'testament': 'old', 'chapters': 22},
  {'id': 12, 'abbrev': '2kgs','name_es': '2 Reyes',        'name_en': '2 Kings',        'testament': 'old', 'chapters': 25},
  {'id': 13, 'abbrev': '1ch', 'name_es': '1 Crónicas',     'name_en': '1 Chronicles',   'testament': 'old', 'chapters': 29},
  {'id': 14, 'abbrev': '2ch', 'name_es': '2 Crónicas',     'name_en': '2 Chronicles',   'testament': 'old', 'chapters': 36},
  {'id': 15, 'abbrev': 'ezr', 'name_es': 'Esdras',         'name_en': 'Ezra',           'testament': 'old', 'chapters': 10},
  {'id': 16, 'abbrev': 'ne',  'name_es': 'Nehemías',       'name_en': 'Nehemiah',       'testament': 'old', 'chapters': 13},
  {'id': 17, 'abbrev': 'est', 'name_es': 'Ester',          'name_en': 'Esther',         'testament': 'old', 'chapters': 10},
  {'id': 18, 'abbrev': 'job', 'name_es': 'Job',            'name_en': 'Job',            'testament': 'old', 'chapters': 42},
  {'id': 19, 'abbrev': 'ps',  'name_es': 'Salmos',         'name_en': 'Psalms',         'testament': 'old', 'chapters': 150},
  {'id': 20, 'abbrev': 'prv', 'name_es': 'Proverbios',     'name_en': 'Proverbs',       'testament': 'old', 'chapters': 31},
  {'id': 21, 'abbrev': 'ec',  'name_es': 'Eclesiastés',    'name_en': 'Ecclesiastes',   'testament': 'old', 'chapters': 12},
  {'id': 22, 'abbrev': 'so',  'name_es': 'Cantares',       'name_en': 'Song of Solomon','testament': 'old', 'chapters': 8},
  {'id': 23, 'abbrev': 'is',  'name_es': 'Isaías',         'name_en': 'Isaiah',         'testament': 'old', 'chapters': 66},
  {'id': 24, 'abbrev': 'jr',  'name_es': 'Jeremías',       'name_en': 'Jeremiah',       'testament': 'old', 'chapters': 52},
  {'id': 25, 'abbrev': 'lm',  'name_es': 'Lamentaciones',  'name_en': 'Lamentations',   'testament': 'old', 'chapters': 5},
  {'id': 26, 'abbrev': 'ez',  'name_es': 'Ezequiel',       'name_en': 'Ezekiel',        'testament': 'old', 'chapters': 48},
  {'id': 27, 'abbrev': 'dn',  'name_es': 'Daniel',         'name_en': 'Daniel',         'testament': 'old', 'chapters': 12},
  {'id': 28, 'abbrev': 'os',  'name_es': 'Oseas',          'name_en': 'Hosea',          'testament': 'old', 'chapters': 14},
  {'id': 29, 'abbrev': 'jl',  'name_es': 'Joel',           'name_en': 'Joel',           'testament': 'old', 'chapters': 3},
  {'id': 30, 'abbrev': 'am',  'name_es': 'Amós',           'name_en': 'Amos',           'testament': 'old', 'chapters': 9},
  {'id': 31, 'abbrev': 'ob',  'name_es': 'Abdías',         'name_en': 'Obadiah',        'testament': 'old', 'chapters': 1},
  {'id': 32, 'abbrev': 'jn',  'name_es': 'Jonás',          'name_en': 'Jonah',          'testament': 'old', 'chapters': 4},
  {'id': 33, 'abbrev': 'mi',  'name_es': 'Miqueas',        'name_en': 'Micah',          'testament': 'old', 'chapters': 7},
  {'id': 34, 'abbrev': 'na',  'name_es': 'Nahúm',          'name_en': 'Nahum',          'testament': 'old', 'chapters': 3},
  {'id': 35, 'abbrev': 'hk',  'name_es': 'Habacuc',        'name_en': 'Habakkuk',       'testament': 'old', 'chapters': 3},
  {'id': 36, 'abbrev': 'zp',  'name_es': 'Sofonías',       'name_en': 'Zephaniah',      'testament': 'old', 'chapters': 3},
  {'id': 37, 'abbrev': 'hg',  'name_es': 'Hageo',          'name_en': 'Haggai',         'testament': 'old', 'chapters': 2},
  {'id': 38, 'abbrev': 'zc',  'name_es': 'Zacarías',       'name_en': 'Zechariah',      'testament': 'old', 'chapters': 14},
  {'id': 39, 'abbrev': 'ml',  'name_es': 'Malaquías',      'name_en': 'Malachi',        'testament': 'old', 'chapters': 4},
  // ── Nuevo Testamento ────────────────────────────────────────────────────
  {'id': 40, 'abbrev': 'mt',  'name_es': 'Mateo',          'name_en': 'Matthew',        'testament': 'new_', 'chapters': 28},
  {'id': 41, 'abbrev': 'mk',  'name_es': 'Marcos',         'name_en': 'Mark',           'testament': 'new_', 'chapters': 16},
  {'id': 42, 'abbrev': 'lk',  'name_es': 'Lucas',          'name_en': 'Luke',           'testament': 'new_', 'chapters': 24},
  {'id': 43, 'abbrev': 'jo',  'name_es': 'Juan',           'name_en': 'John',           'testament': 'new_', 'chapters': 21},
  {'id': 44, 'abbrev': 'act', 'name_es': 'Hechos',         'name_en': 'Acts',           'testament': 'new_', 'chapters': 28},
  {'id': 45, 'abbrev': 'rm',  'name_es': 'Romanos',        'name_en': 'Romans',         'testament': 'new_', 'chapters': 16},
  {'id': 46, 'abbrev': '1co', 'name_es': '1 Corintios',    'name_en': '1 Corinthians',  'testament': 'new_', 'chapters': 16},
  {'id': 47, 'abbrev': '2co', 'name_es': '2 Corintios',    'name_en': '2 Corinthians',  'testament': 'new_', 'chapters': 13},
  {'id': 48, 'abbrev': 'gl',  'name_es': 'Gálatas',        'name_en': 'Galatians',      'testament': 'new_', 'chapters': 6},
  {'id': 49, 'abbrev': 'eph', 'name_es': 'Efesios',        'name_en': 'Ephesians',      'testament': 'new_', 'chapters': 6},
  {'id': 50, 'abbrev': 'ph',  'name_es': 'Filipenses',     'name_en': 'Philippians',    'testament': 'new_', 'chapters': 4},
  {'id': 51, 'abbrev': 'cl',  'name_es': 'Colosenses',     'name_en': 'Colossians',     'testament': 'new_', 'chapters': 4},
  {'id': 52, 'abbrev': '1ts', 'name_es': '1 Tesalonicenses','name_en': '1 Thessalonians','testament': 'new_', 'chapters': 5},
  {'id': 53, 'abbrev': '2ts', 'name_es': '2 Tesalonicenses','name_en': '2 Thessalonians','testament': 'new_', 'chapters': 3},
  {'id': 54, 'abbrev': '1tm', 'name_es': '1 Timoteo',      'name_en': '1 Timothy',      'testament': 'new_', 'chapters': 6},
  {'id': 55, 'abbrev': '2tm', 'name_es': '2 Timoteo',      'name_en': '2 Timothy',      'testament': 'new_', 'chapters': 4},
  {'id': 56, 'abbrev': 'tt',  'name_es': 'Tito',           'name_en': 'Titus',          'testament': 'new_', 'chapters': 3},
  {'id': 57, 'abbrev': 'phm', 'name_es': 'Filemón',        'name_en': 'Philemon',       'testament': 'new_', 'chapters': 1},
  {'id': 58, 'abbrev': 'hb',  'name_es': 'Hebreos',        'name_en': 'Hebrews',        'testament': 'new_', 'chapters': 13},
  {'id': 59, 'abbrev': 'jm',  'name_es': 'Santiago',       'name_en': 'James',          'testament': 'new_', 'chapters': 5},
  {'id': 60, 'abbrev': '1pe', 'name_es': '1 Pedro',        'name_en': '1 Peter',        'testament': 'new_', 'chapters': 5},
  {'id': 61, 'abbrev': '2pe', 'name_es': '2 Pedro',        'name_en': '2 Peter',        'testament': 'new_', 'chapters': 3},
  {'id': 62, 'abbrev': '1jo', 'name_es': '1 Juan',         'name_en': '1 John',         'testament': 'new_', 'chapters': 5},
  {'id': 63, 'abbrev': '2jo', 'name_es': '2 Juan',         'name_en': '2 John',         'testament': 'new_', 'chapters': 1},
  {'id': 64, 'abbrev': '3jo', 'name_es': '3 Juan',         'name_en': '3 John',         'testament': 'new_', 'chapters': 1},
  {'id': 65, 'abbrev': 'jd',  'name_es': 'Judas',          'name_en': 'Jude',           'testament': 'new_', 'chapters': 1},
  {'id': 66, 'abbrev': 'rv',  'name_es': 'Apocalipsis',    'name_en': 'Revelation',     'testament': 'new_', 'chapters': 22},
];

// Mapa de abreviatura → metadatos para búsqueda O(1).
final Map<String, Map<String, dynamic>> kBibleMetadataByAbbrev = {
  for (final book in kBibleMetadata) book['abbrev'] as String: book,
};
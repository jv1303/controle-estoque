import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static const _fileName = 'meu_estoque.db';
  static const _schemaVersion = 1;

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  /// no navegador o sqlite roda em wasm, nos outros casos usa o padrao
  DatabaseFactory get _factory =>
      kIsWeb ? databaseFactoryFfiWeb : databaseFactory;

  Future<Database> _open() async {
    final path = kIsWeb
        ? _fileName
        : p.join(await _factory.getDatabasesPath(), _fileName);

    return _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _schemaVersion,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _createSchema,
      ),
    );
  }

  Future<void> _createSchema(Database db, int version) async {
    final batch = db.batch()
      ..execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL,
          salt TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''')
      ..execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          owner_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          name TEXT NOT NULL,
          category TEXT NOT NULL,
          quantity INTEGER NOT NULL CHECK (quantity >= 0),
          price REAL NOT NULL CHECK (price >= 0),
          updated_at TEXT NOT NULL
        )
      ''');
    await batch.commit(noResult: true);
  }
}

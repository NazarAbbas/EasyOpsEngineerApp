// app_database.dart
import 'dart:async';
import 'package:easy_ops/database/dao/todo_dao.dart';
import 'package:easy_ops/database/entity/db_todo.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart';

@Database(version: 1, entities: [Todo])
abstract class AppDatabase extends FloorDatabase {
  TodoDao get todoDao;

  // 👉 Convenient way to set the DB name (or path) in one place
  static Future<AppDatabase> open({
    String? name, // pass a custom name or full path
    List<Migration> migrations = const [], // optional migrations
    Callback? callback, // optional lifecycle hooks
  }) {
    // default from --dart-define or fallback
    final dbName =
        name ??
        const String.fromEnvironment(
          'DB_NAME',
          defaultValue: 'easy_ops_engeneer.db',
        );

    final builder = $FloorAppDatabase.databaseBuilder(dbName)
      ..addMigrations(migrations);

    if (callback != null) {
      builder.addCallback(callback);
    }

    return builder.build();
  }

  // Optional: in-memory helper
  static Future<AppDatabase> openInMemory() {
    return $FloorAppDatabase.inMemoryDatabaseBuilder().build();
  }
}

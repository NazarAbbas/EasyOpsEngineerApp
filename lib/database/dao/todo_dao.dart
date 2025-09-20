// lib/data/todo_dao.dart
import 'package:easy_ops/database/entity/db_todo.dart';
import 'package:floor/floor.dart';

@dao
abstract class TodoDao {
  @Query('SELECT * FROM todos ORDER BY createdAt DESC')
  Stream<List<Todo>> watchAll();

  @Query('SELECT * FROM todos WHERE id = :id')
  Future<Todo?> findById(int id);

  @insert
  Future<int> insertOne(Todo todo);

  @update
  Future<int> updateOne(Todo todo);

  @delete
  Future<int> deleteOne(Todo todo);

  @Query('DELETE FROM todos')
  Future<void> clear();
}

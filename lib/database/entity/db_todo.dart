// lib/data/todo.dart
import 'package:floor/floor.dart';

@Entity(tableName: 'todos')
class Todo {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String title;

  Todo({this.id, required this.title});

  Todo copyWith({int? id, String? title, bool? done}) =>
      Todo(id: id ?? this.id, title: title ?? this.title);
}

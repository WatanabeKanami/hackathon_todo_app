import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';

class TodoService {
  TodoService(this._prefs);

  static const _storageKey = 'todos';
  final SharedPreferences _prefs;

  Future<List<Todo>> getTodos() async {
    final stored = _prefs.getStringList(_storageKey) ?? <String>[];
    return stored
        .map(
          (value) => Todo.fromJson(jsonDecode(value) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> saveTodos(List<Todo> todos) async {
    final saved = await _prefs.setStringList(
      _storageKey,
      todos.map((todo) => jsonEncode(todo.toJson())).toList(),
    );
    if (!saved) {
      throw StateError('タスクを保存できませんでした');
    }
  }
}

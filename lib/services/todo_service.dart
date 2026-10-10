import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';
import '../models/reward_stamp.dart';

class TodoService {
  TodoService(this._prefs);
  static const _storageKey = 'todos';
  // Tasks and stamps share one atomic write. Legacy data stays intact.
  static const _stateKey = 'todo_state_v2';
  final SharedPreferences _prefs;

  Map<String, dynamic>? _readState() {
    final value = _prefs.getString(_stateKey);
    return value == null ? null : jsonDecode(value) as Map<String, dynamic>;
  }

  Future<List<Todo>> getTodos() async {
    final state = _readState();
    if (state != null) {
      return (state['todos'] as List)
          .map((e) => Todo.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return (_prefs.getStringList(_storageKey) ?? <String>[])
        .map((e) => Todo.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<List<RewardStamp>> getStamps() async {
    final state = _readState();
    return ((state?['stamps'] as List?) ?? [])
        .map((e) => RewardStamp.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> saveTodos(List<Todo> todos) async {
    final previous = {for (final todo in await getTodos()) todo.id: todo};
    final stamps = await getStamps();
    final earnedIds = stamps.map((e) => e.todoId).toSet();
    for (final todo in todos) {
      final old = previous[todo.id];
      if (old != null &&
          !old.isCompleted &&
          todo.isCompleted &&
          todo.hasReward &&
          earnedIds.add(todo.id)) {
        stamps.add(
          RewardStamp(
            todoId: todo.id,
            title: todo.title,
            earnedAt: DateTime.now(),
          ),
        );
      }
    }
    final saved = await _prefs.setString(
      _stateKey,
      jsonEncode({
        'version': 2,
        'todos': todos.map((e) => e.toJson()).toList(),
        'stamps': stamps.map((e) => e.toJson()).toList(),
      }),
    );
    if (!saved) throw StateError('タスクを保存できませんでした');
  }
}

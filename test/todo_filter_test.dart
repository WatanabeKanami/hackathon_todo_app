import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/models/todo_filter.dart';
import 'package:todo_app/services/todo_service.dart';

void main() {
  Todo task({int? minutes = 5, bool completed = false}) => Todo(
    title: '一歩',
    detail: '詳細',
    dueDate: DateTime(2026, 10, 10),
    mood: 'relaxed',
    place: 'home',
    timeOfDay: 'morning',
    theme: 'study',
    difficulty: 'easy',
    estimatedMinutes: minutes,
    hasReward: true,
    isCompleted: completed,
  );
  test('All five categories and independent attributes combine with AND', () {
    final f = TodoFilter();
    final t = task();
    for (final e in {
      'mood': 'relaxed',
      'place': 'home',
      'timeOfDay': 'morning',
      'duration': '5',
      'theme': 'study',
      'difficulty': 'easy',
      'reward': 'yes',
    }.entries) {
      f.toggle(e.key, e.value);
      expect(f.matches(t), isTrue);
    }
    f.toggle('mood', 'tired');
    expect(f.matches(t), isFalse);
    f.toggle('mood', 'tired');
    expect(f.matches(t), isTrue);
    expect(f.matches(task(completed: true)), isFalse);
    f.status = 'completed';
    expect(f.matches(task(completed: true)), isTrue);
    expect(f.matches(t), isFalse);
    f.reset();
    expect(f.selected, isEmpty);
    expect(f.matches(t), isTrue);
    expect(f.matches(task(completed: true)), isTrue);
  });
  test(
    'Duration uses numeric inclusive boundaries and excludes unset values',
    () {
      final f = TodoFilter();
      f.toggle('duration', '5');
      expect(f.matches(task(minutes: 5)), isTrue);
      expect(f.matches(task(minutes: 6)), isFalse);
      f.toggle('duration', '15');
      expect(f.matches(task(minutes: 5)), isTrue);
      expect(f.matches(task(minutes: 15)), isTrue);
      expect(f.matches(task(minutes: 16)), isFalse);
      f.toggle('duration', '30');
      expect(f.matches(task(minutes: 29)), isFalse);
      expect(f.matches(task(minutes: 30)), isTrue);
      expect(f.matches(task(minutes: 60)), isTrue);
      expect(f.matches(task(minutes: null)), isFalse);
    },
  );
  test(
    'Legacy records load safely and completion preserves all attributes',
    () {
      final old = Todo.fromJson({
        'id': 'old',
        'title': '昔のタスク',
        'detail': '詳細',
        'dueDate': '2025-01-01T00:00:00.000',
      });
      expect(old.mood, isNull);
      expect(old.estimatedMinutes, isNull);
      expect(old.hasReward, isFalse);
      final t = task();
      expect(t.copyWith(isCompleted: true).toJson(), {
        ...t.toJson(),
        'isCompleted': true,
      });
      final invalid = Todo.fromJson({
        ...t.toJson(),
        'estimatedMinutes': 'five',
        'mood': 12,
      });
      expect(invalid.estimatedMinutes, isNull);
      expect(invalid.mood, isNull);
    },
  );
  test(
    'Attributes, edits, completion and deletion survive service recreation',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final t = task();
      await TodoService(prefs).saveTodos([t]);
      final loaded = (await TodoService(prefs).getTodos()).single;
      expect(loaded.toJson(), t.toJson());
      final edited = loaded.copyWith(title: '変更', isCompleted: true);
      await TodoService(prefs).saveTodos([edited]);
      expect(
        (await TodoService(prefs).getTodos()).single.toJson(),
        edited.toJson(),
      );
      await TodoService(prefs).saveTodos([]);
      expect(await TodoService(prefs).getTodos(), isEmpty);
    },
  );
}

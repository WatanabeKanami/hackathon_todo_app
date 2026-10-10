import 'todo.dart';

/// Every selected condition is combined with AND. Null means unrestricted.
class TodoFilter {
  String status = 'pending';
  final Map<String, String> selected = {};
  bool get isActive => selected.isNotEmpty;
  void toggle(String category, String value) {
    if (selected[category] == value) {
      selected.remove(category);
    } else {
      selected[category] = value;
    }
  }

  void reset() {
    selected.clear();
    status = 'all';
  }

  bool matches(Todo todo) {
    if (status == 'pending' && todo.isCompleted) return false;
    if (status == 'completed' && !todo.isCompleted) return false;
    final fields = {
      'mood': todo.mood,
      'place': todo.place,
      'timeOfDay': todo.timeOfDay,
      'theme': todo.theme,
      'difficulty': todo.difficulty,
    };
    for (final entry in selected.entries) {
      if (entry.key == 'reward') {
        if (!todo.hasReward) return false;
      } else if (entry.key == 'duration') {
        final minutes = todo.estimatedMinutes;
        if (minutes == null) return false;
        if (entry.value == '5' && minutes > 5) return false;
        if (entry.value == '15' && minutes > 15) return false;
        if (entry.value == '30' && minutes < 30) return false;
      } else if (fields[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }
}

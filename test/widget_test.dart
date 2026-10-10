import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/services/todo_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('ja_JP');
  });

  test('Tasks survive service recreation with all fields intact', () async {
    final prefs = await SharedPreferences.getInstance();
    final todo = Todo(
      title: '買い物',
      detail: '牛乳を買う',
      dueDate: DateTime(2026, 10, 11),
      isCompleted: true,
    );
    await TodoService(prefs).saveTodos([todo]);
    final restored = await TodoService(prefs).getTodos();
    expect(restored.single.toJson(), todo.toJson());
    await TodoService(prefs).saveTodos([]);
    expect(await TodoService(prefs).getTodos(), isEmpty);
  });

  testWidgets('Completed tasks stay saved and hidden after reopening', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final service = TodoService(prefs);
    await service.saveTodos([
      Todo(title: '買い物', detail: '牛乳を買う', dueDate: DateTime(2026, 10, 11)),
    ]);
    await tester.pumpWidget(MyApp(todoService: service));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.radio_button_unchecked));
    await tester.pumpAndSettle();
    expect(find.text('買い物'), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect((await TodoService(prefs).getTodos()).single.isCompleted, isTrue);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(MyApp(todoService: TodoService(prefs)));
    await tester.pumpAndSettle();
    expect(find.text('買い物'), findsNothing);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
    expect((await service.getTodos()).single.isCompleted, isTrue);
  });
}

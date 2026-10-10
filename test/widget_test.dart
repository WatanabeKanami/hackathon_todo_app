import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/services/todo_service.dart';
import 'package:todo_app/widgets/completion_celebration.dart';

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

  testWidgets('Japanese date picker and added task survive reopening', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MyApp(todoService: TodoService(prefs)));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '保存テスト');
    await tester.enterText(fields.at(1), '再起動後も残る');
    await tester.tap(fields.at(2));
    await tester.pumpAndSettle();

    final pickerContext = tester.element(find.byType(DatePickerDialog));
    expect(Localizations.localeOf(pickerContext), const Locale('ja', 'JP'));
    expect(find.text('キャンセル'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.widgetWithText(ElevatedButton, 'タスクを追加'),
      250,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'タスクを追加'));
    await tester.pumpAndSettle();
    expect(find.text('保存テスト'), findsOneWidget);
    final saved = (await TodoService(prefs).getTodos()).single;
    expect(saved.detail, '再起動後も残る');
    expect(saved.isCompleted, isFalse);

    await tester.pumpWidget(const SizedBox());
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MyApp(todoService: TodoService(prefs)));
    await tester.pumpAndSettle();
    expect(find.text('保存テスト'), findsOneWidget);
    expect(
      (await TodoService(prefs).getTodos()).single.toJson(),
      saved.toJson(),
    );
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
    await tester.scrollUntilVisible(
      find.byIcon(Icons.radio_button_unchecked),
      200,
    );
    await tester.tap(find.byIcon(Icons.radio_button_unchecked));
    await tester.pump();
    expect(find.byType(CompletionCelebration), findsOneWidget);
    final celebration = tester.widget<CompletionCelebration>(
      find.byType(CompletionCelebration),
    );
    expect(completionMessages, contains(celebration.message));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('🎉 ${celebration.message}'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1000));
    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(CompletionCelebration),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, inExclusiveRange(0.0, 1.0));
    await tester.pumpAndSettle();
    expect(find.byType(CompletionCelebration), findsNothing);
    expect(find.text('買い物'), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect((await TodoService(prefs).getTodos()).single.isCompleted, isTrue);

    await tester.pumpWidget(const SizedBox());
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MyApp(todoService: TodoService(prefs)));
    await tester.pumpAndSettle();
    expect(find.text('買い物'), findsNothing);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
    expect((await service.getTodos()).single.isCompleted, isTrue);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/services/todo_service.dart';

void main() {
  testWidgets(
    'Sheets combine filters, toggle off, reset and preserve conditions after editing',
    (tester) async {
      tester.view.physicalSize = const Size(500, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      await initializeDateFormatting('ja_JP');
      final service = TodoService(await SharedPreferences.getInstance());
      await service.saveTodos([
        Todo(
          title: '家で勉強',
          detail: '本を読む',
          dueDate: DateTime.now(),
          mood: 'relaxed',
          place: 'home',
          timeOfDay: 'morning',
          theme: 'study',
          difficulty: 'easy',
          estimatedMinutes: 5,
          hasReward: true,
        ),
        Todo(
          title: '学校で勉強',
          detail: '問題を解く',
          dueDate: DateTime.now(),
          mood: 'motivated',
          place: 'school',
          estimatedMinutes: 45,
        ),
      ]);
      await tester.pumpWidget(MyApp(todoService: service));
      await tester.pumpAndSettle();
      await tester.tap(find.text('☁️ 気分'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, '🍵 のんびり'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('一覧を見る'));
      await tester.pumpAndSettle();
      expect(find.text('家で勉強'), findsOneWidget);
      expect(find.text('学校で勉強'), findsNothing);
      await tester.tap(find.text('🏝️ 場所'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, '🏫 学校'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('一覧を見る'));
      await tester.pumpAndSettle();
      expect(find.text('この条件に合うタスクはまだないよ'), findsOneWidget);
      await tester.tap(find.text('🏝️ 場所 •'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, '🏫 学校'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('一覧を見る'));
      await tester.pumpAndSettle();
      expect(find.text('家で勉強'), findsOneWidget);
      await tester.tap(find.byTooltip('タスクの操作'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('編集'));
      await tester.pumpAndSettle();
      expect(find.text('家で勉強'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(0), '家で読書');
      await tester.tap(find.text('🌙 夜'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('変更を保存'));
      await tester.pumpAndSettle();
      expect(find.text('家で読書'), findsOneWidget);
      expect(find.text('学校で勉強'), findsNothing);
      final edited = (await service.getTodos()).first;
      expect(edited.timeOfDay, 'night');
      expect(edited.hasReward, isTrue);
      expect(edited.estimatedMinutes, 5);
      await tester.tap(find.text('リセット'));
      await tester.pumpAndSettle();
      expect(find.text('学校で勉強'), findsOneWidget);
      await tester.tap(find.byTooltip('タスクの操作').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('削除'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, '削除'));
      await tester.pumpAndSettle();
      expect((await service.getTodos()).length, 1);
      expect(find.text('家で読書'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Small phone layout remains usable', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('ja_JP');
    final service = TodoService(await SharedPreferences.getInstance());
    await service.saveTodos([
      Todo(
        title: '小さい画面でも操作できる',
        detail: '詳細も長くなったときに折り返して表示する',
        dueDate: DateTime.now(),
      ),
    ]);
    await tester.pumpWidget(MyApp(todoService: service));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byTooltip('完了にする'), 200);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('タスクを追加'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

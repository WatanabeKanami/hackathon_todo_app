import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/services/todo_service.dart';
import 'package:todo_app/widgets/completion_celebration.dart';

void main() {
  test('Legacy migration, first completion, duplicate prevention, deletion and restart', () async {
    final task = Todo(
      title: '頑張った一歩',
      detail: '詳細',
      dueDate: DateTime.now(),
      hasReward: true,
    );
    SharedPreferences.setMockInitialValues({
      'todos': [jsonEncode(task.toJson())],
    });
    final prefs = await SharedPreferences.getInstance();
    final service = TodoService(prefs);
    expect(await service.getStamps(), isEmpty);
    await service.saveTodos([task.copyWith(isCompleted: true)]);
    expect((await service.getStamps()).single.title, task.title);
    await service.saveTodos([task]);
    await service.saveTodos([task.copyWith(isCompleted: true)]);
    expect((await service.getStamps()).length, 1);
    await service.saveTodos([]);
    final restored = TodoService(prefs);
    expect(await restored.getTodos(), isEmpty);
    expect((await restored.getStamps()).single.todoId, task.id);
    expect(prefs.getStringList('todos'), [jsonEncode(task.toJson())]);
  });
  test(
    'Normal tasks and already completed legacy tasks do not earn stamps',
    () async {
      final normal = Todo(title: '普通', detail: '詳細', dueDate: DateTime.now());
      final old = Todo(
        title: '以前の達成',
        detail: '詳細',
        dueDate: DateTime.now(),
        hasReward: true,
        isCompleted: true,
      );
      SharedPreferences.setMockInitialValues({
        'todos': [jsonEncode(normal.toJson()), jsonEncode(old.toJson())],
      });
      final service = TodoService(await SharedPreferences.getInstance());
      await service.saveTodos([normal.copyWith(isCompleted: true), old]);
      expect(await service.getStamps(), isEmpty);
    },
  );
  testWidgets('Reward praise and stamp album are accessible from the menu', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('ja_JP');
    final service = TodoService(await SharedPreferences.getInstance());
    await service.saveTodos([
      Todo(
        title: 'ごほうびテスト',
        detail: 'ひとつできた',
        dueDate: DateTime.now(),
        hasReward: true,
      ),
    ]);
    await tester.pumpWidget(MyApp(todoService: service));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byTooltip('完了にする'), 200);
    await tester.tap(find.byTooltip('完了にする'));
    await tester.pumpAndSettle();
    expect((await service.getStamps()).length, 1);
    // Trigger a second completion to inspect the longer reward animation.
    await tester.scrollUntilVisible(find.text('完了'), -200);
    await tester.tap(find.widgetWithText(ChoiceChip, '完了'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byTooltip('未完了に戻す'), 200);
    await tester.tap(find.byTooltip('未完了に戻す'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('未完了'), -200);
    await tester.tap(find.widgetWithText(ChoiceChip, '未完了'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byTooltip('完了にする'), 200);
    await tester.tap(find.byTooltip('完了にする'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final celebration = tester.widget<CompletionCelebration>(
      find.byType(CompletionCelebration),
    );
    expect(celebration.isReward, isTrue);
    expect(rewardCompletionMessages, contains(celebration.message));
    await tester.pumpAndSettle();
    expect((await service.getStamps()).length, 1);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('がんばりましたスタンプ'));
    await tester.pumpAndSettle();
    expect(find.text('1個のがんばり'), findsOneWidget);
    expect(find.text('ごほうびテスト'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

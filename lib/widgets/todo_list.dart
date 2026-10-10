import 'dart:math';

import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../models/todo_filter.dart';
import '../models/task_attributes.dart';
import '../services/todo_service.dart';
import '../screens/add_todo_screen.dart';
import 'todo_card.dart';
import 'completion_celebration.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key, required this.todoService, required this.filter});
  final TodoService todoService;
  final TodoFilter filter;
  @override
  State<TodoList> createState() => TodoListState();
}

class TodoListState extends State<TodoList> {
  List<Todo> _todos = [];
  bool _loading = true, _busy = false;
  String? _error, _message;
  int _celebrationId = 0;
  bool _rewardCelebration = false;
  Future<void> reload() async {
    try {
      final todos = await widget.todoService.getTodos();
      if (mounted) {
        setState(() {
          _todos = todos;
          _loading = false;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'タスクを読み込めませんでした';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> _persist(List<Todo> next, {bool celebrate = false}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final reward =
          celebrate &&
          next.any(
            (t) =>
                t.hasReward &&
                t.isCompleted &&
                _todos.any((old) => old.id == t.id && !old.isCompleted),
          );
      await widget.todoService.saveTodos(next);
      if (mounted) {
        setState(() {
          _todos = next;
          if (celebrate) {
            _rewardCelebration = reward;
            final messages = reward
                ? rewardCompletionMessages
                : completionMessages;
            _message = messages[Random().nextInt(messages.length)];
            _celebrationId++;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('保存できませんでした。もう一度お試しください')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit(Todo todo) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddTodoScreen(todoService: widget.todoService, todo: todo),
      ),
    );
    if (changed == true && mounted) await reload();
  }

  Future<void> _delete(Todo todo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('タスクを削除しますか？'),
        content: Text(todo.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _persist(_todos.where((t) => t.id != todo.id).toList());
    }
  }

  void _sheet(String category) {
    final groups = category == 'time'
        ? ['timeOfDay', 'duration']
        : category == 'effort'
        ? ['difficulty', 'reward']
        : [category];
    const titles = {
      'mood': '☁️ 気分で選ぶ',
      'place': '🏝️ 場所で選ぶ',
      'time': '☀️ 時間で選ぶ',
      'theme': '🎨 テーマで選ぶ',
      'effort': '⭐ がんばりで選ぶ',
    };
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[category]!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('もう一度タップで解除。他のカテゴリとも組み合わせできます。'),
                const SizedBox(height: 16),
                for (final group in groups) ...[
                  Text(
                    group == 'duration'
                        ? '所要時間'
                        : group == 'timeOfDay'
                        ? '時間帯'
                        : group == 'reward'
                        ? 'ごほうび'
                        : '条件',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        (group == 'duration'
                                ? const [
                                    TaskOption('5', '⚡ 5分以内', 0xfffff6c9),
                                    TaskOption('15', '⏱️ 15分以内', 0xffdff3ff),
                                    TaskOption('30', '🕰️ 30分以上', 0xffe7e3ff),
                                  ]
                                : group == 'reward'
                                ? const [
                                    TaskOption('yes', '🎁 ごほうび付き', 0xffffe2eb),
                                  ]
                                : taskOptions[group]!)
                            .map(
                              (o) => ChoiceChip(
                                label: Text(o.label),
                                selected: widget.filter.selected[group] == o.id,
                                selectedColor: Color(o.color),
                                onSelected: (_) {
                                  setState(
                                    () => widget.filter.toggle(group, o.id),
                                  );
                                  update(() {});
                                },
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 20),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('一覧を見る'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            TextButton(onPressed: reload, child: const Text('再読み込み')),
          ],
        ),
      );
    }
    final filter = widget.filter;
    final visible = _todos.where(filter.matches).toList();
    final now = DateTime.now();
    final today = _todos
        .where(
          (t) =>
              t.dueDate.year == now.year &&
              t.dueDate.month == now.month &&
              t.dueDate.day == now.day,
        )
        .toList();
    final done = today.where((t) => t.isCompleted).length;
    final greeting = now.hour < 11
        ? 'おはよう！'
        : now.hour < 18
        ? 'こんにちは！'
        : 'こんばんは！';
    const categories = {
      'mood': '☁️ 気分',
      'place': '🏝️ 場所',
      'time': '☀️ 時間',
      'theme': '🎨 テーマ',
      'effort': '⭐ がんばり',
    };
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/pastel_sky.png'),
          fit: BoxFit.cover,
          opacity: 0.65,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffe9f6ff), Color(0xfff7f2ff), Color(0xfffff6fa)],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [Color(0xffd9efff), Color(0xffeee3ff)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$greeting\n今日も少しずつ進もう',
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff34365b),
                                ),
                              ),
                            ),
                            const Text(
                              '☁️\n ✨ 🌷',
                              style: TextStyle(fontSize: 30),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'あなたの一歩が、光になる。',
                          style: TextStyle(color: Color(0xff626580)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '今日が期日のタスク  $done / ${today.length}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TweenAnimationBuilder<double>(
                          tween: Tween(
                            end: today.isEmpty ? 0 : done / today.length,
                          ),
                          duration: const Duration(milliseconds: 400),
                          builder: (context, value, _) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: value,
                              minHeight: 10,
                              backgroundColor: const Color(0xffefedf9),
                              color: const Color(0xff9a92e0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          today.isEmpty ? '今日はあなたのペースで 🌱' : '小さな達成を重ねていこう ✨',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    '今の自分にぴったりのタスク',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff34365b),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.entries.map((e) {
                      final active = e.key == 'time'
                          ? filter.selected.containsKey('timeOfDay') ||
                                filter.selected.containsKey('duration')
                          : e.key == 'effort'
                          ? filter.selected.containsKey('difficulty') ||
                                filter.selected.containsKey('reward')
                          : filter.selected.containsKey(e.key);
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: active
                              ? const [
                                  BoxShadow(
                                    color: Color(0x557e75cb),
                                    blurRadius: 12,
                                  ),
                                ]
                              : [],
                        ),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: active
                                ? const Color(0xffdfd9ff)
                                : Colors.white,
                            foregroundColor: const Color(0xff45416f),
                          ),
                          onPressed: () => _sheet(e.key),
                          child: Text('${e.value}${active ? ' •' : ''}'),
                        ),
                      );
                    }).toList(),
                  ),
                  if (filter.isActive) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: filter.selected.entries
                          .map(
                            (e) => InputChip(
                              label: Text(
                                e.key == 'duration'
                                    ? (e.value == '30'
                                          ? '30分以上'
                                          : '${e.value}分以内')
                                    : e.key == 'reward'
                                    ? '🎁 ごほうび付き'
                                    : optionLabel(e.key, e.value) ?? e.value,
                              ),
                              onDeleted: () =>
                                  setState(() => filter.selected.remove(e.key)),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(filter.reset),
                      child: const Text('リセット'),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children:
                        {'pending': '未完了', 'completed': '完了', 'all': 'すべて'}
                            .entries
                            .map(
                              (e) => ChoiceChip(
                                label: Text(e.value),
                                selected: filter.status == e.key,
                                onSelected: (_) =>
                                    setState(() => filter.status = e.key),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'タスク ${visible.length}件',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (visible.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Column(
                        children: [
                          Text('☁️ ✨ 🌱', style: TextStyle(fontSize: 42)),
                          SizedBox(height: 16),
                          Text('この条件に合うタスクはまだないよ', textAlign: TextAlign.center),
                          SizedBox(height: 8),
                          Text(
                            '条件を変えるか、小さな一歩を追加しよう',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xff626580)),
                          ),
                        ],
                      ),
                    ),
                  for (final todo in visible)
                    TodoCard(
                      key: ValueKey(todo.id),
                      todo: todo,
                      onToggle: _busy
                          ? null
                          : () => _persist(
                              _todos
                                  .map(
                                    (t) => t.id == todo.id
                                        ? t.copyWith(
                                            isCompleted: !t.isCompleted,
                                          )
                                        : t,
                                  )
                                  .toList(),
                              celebrate: !todo.isCompleted,
                            ),
                      onEdit: _busy ? null : () => _edit(todo),
                      onDelete: _busy ? null : () => _delete(todo),
                    ),
                ],
              ),
            ),
          ),
          if (_message != null)
            Positioned.fill(
              child: CompletionCelebration(
                key: ValueKey(_celebrationId),
                message: _message!,
                isReward: _rewardCelebration,
                onFinished: () {
                  if (mounted) setState(() => _message = null);
                },
              ),
            ),
        ],
      ),
    );
  }
}

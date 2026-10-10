import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../models/task_attributes.dart';
import '../services/todo_service.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key, required this.todoService, this.todo});
  final TodoService todoService;
  final Todo? todo;
  @override
  State<AddTodoScreen> createState() => AddTodoScreenState();
}

class AddTodoScreenState extends State<AddTodoScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController(),
      _detail = TextEditingController(),
      _date = TextEditingController(),
      _minutes = TextEditingController();
  final Map<String, String?> _attributes = {};
  DateTime? _due;
  bool _reward = false, _saving = false;
  @override
  void initState() {
    super.initState();
    final t = widget.todo;
    if (t != null) {
      _title.text = t.title;
      _detail.text = t.detail;
      _due = t.dueDate;
      _date.text = '${t.dueDate.year}/${t.dueDate.month}/${t.dueDate.day}';
      _minutes.text = t.estimatedMinutes?.toString() ?? '';
      _reward = t.hasReward;
      _attributes.addAll({
        'mood': t.mood,
        'place': t.place,
        'timeOfDay': t.timeOfDay,
        'theme': t.theme,
        'difficulty': t.difficulty,
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_title, _detail, _date, _minutes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final t = Todo(
        id: widget.todo?.id,
        title: _title.text.trim(),
        detail: _detail.text.trim(),
        dueDate: _due!,
        isCompleted: widget.todo?.isCompleted ?? false,
        mood: _attributes['mood'],
        place: _attributes['place'],
        timeOfDay: _attributes['timeOfDay'],
        theme: _attributes['theme'],
        difficulty: _attributes['difficulty'],
        estimatedMinutes: int.tryParse(_minutes.text),
        hasReward: _reward,
      );
      final todos = await widget.todoService.getTodos();
      if (widget.todo == null) {
        todos.add(t);
      } else {
        final i = todos.indexWhere((e) => e.id == t.id);
        if (i < 0) throw StateError('missing');
        todos[i] = t;
      }
      await widget.todoService.saveTodos(todos);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('保存できませんでした。もう一度お試しください')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const labels = {
      'mood': '☁️ 取り組む気分',
      'place': '🏝️ 場所',
      'timeOfDay': '☀️ 時間帯',
      'theme': '🎨 テーマ',
      'difficulty': '⭐ がんばり',
    };
    return Scaffold(
      appBar: AppBar(title: Text(widget.todo == null ? '新しいタスクを追加' : 'タスクを編集')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  '小さな一歩を、ひとつ。 ✨',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'タスクのタイトル'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'タイトルを入力してください'
                      : v.trim().length > 20
                      ? '20文字以内で入力してください'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _detail,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'タスクの詳細'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? '詳細を入力してください' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _date,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: '期日',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (_) => _due == null ? '期日を選択してください' : null,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _due ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100, 12, 31),
                    );
                    if (picked != null && mounted) {
                      setState(() {
                        _due = picked;
                        _date.text =
                            '${picked.year}/${picked.month}/${picked.day}';
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                for (final category in taskOptions.entries) ...[
                  Text(
                    labels[category.key]!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: category.value
                        .map(
                          (o) => ChoiceChip(
                            label: Text(o.label),
                            selected: _attributes[category.key] == o.id,
                            selectedColor: Color(o.color),
                            onSelected: (_) => setState(() {
                              _attributes[category.key] =
                                  _attributes[category.key] == o.id
                                  ? null
                                  : o.id;
                            }),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _minutes,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '所要時間（分・任意）',
                    hintText: '例：5、15、45',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final n = int.tryParse(v);
                    return n == null || n <= 0 ? '1以上の整数を入力してください' : null;
                  },
                ),
                SwitchListTile(
                  title: const Text('🎁 ごほうび付き'),
                  subtitle: const Text('難易度とは別に設定できます'),
                  value: _reward,
                  onChanged: (v) => setState(() => _reward = v),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: Text(
                    _saving
                        ? '保存中…'
                        : widget.todo == null
                        ? 'タスクを追加'
                        : '変更を保存',
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

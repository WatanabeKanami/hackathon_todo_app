import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/todo.dart';
import '../models/task_attributes.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({
    super.key,
    required this.todo,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });
  final Todo todo;
  final VoidCallback? onToggle, onEdit, onDelete;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: todo.isCompleted ? const Color(0xffedf9f2) : Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xffe7e6f5)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0c7274b6),
          blurRadius: 16,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            tooltip: todo.isCompleted ? '未完了に戻す' : '完了にする',
            onPressed: onToggle,
            icon: Icon(
              todo.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: todo.isCompleted
                  ? const Color(0xff368365)
                  : const Color(0xff9289ce),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff34365b),
                    decoration: todo.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  todo.detail,
                  style: const TextStyle(color: Color(0xff626580)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Text(
                      '📅 ${DateFormat('M月d日(E)', 'ja_JP').format(todo.dueDate)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    for (final e in {
                      'mood': todo.mood,
                      'place': todo.place,
                      'timeOfDay': todo.timeOfDay,
                      'theme': todo.theme,
                      'difficulty': todo.difficulty,
                    }.entries)
                      if (optionLabel(e.key, e.value) != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Color(
                              taskOptions[e.key]!
                                  .firstWhere((o) => o.id == e.value)
                                  .color,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            optionLabel(e.key, e.value)!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                    if (todo.estimatedMinutes != null)
                      Text(
                        '⏱️ ${todo.estimatedMinutes}分',
                        style: const TextStyle(fontSize: 12),
                      ),
                    if (todo.hasReward)
                      const Text('🎁 ごほうび付き', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'タスクの操作',
            onSelected: (v) {
              if (v == 'edit') {
                onEdit?.call();
              } else {
                onDelete?.call();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('編集')),
              PopupMenuItem(value: 'delete', child: Text('削除')),
            ],
          ),
        ],
      ),
    ),
  );
}

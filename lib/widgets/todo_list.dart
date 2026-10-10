import 'dart:math';

import 'package:flutter/material.dart';

import 'completion_celebration.dart';

import '../models/todo.dart'; // 作成したTodoクラス
import '../services/todo_service.dart'; // データ保存サービス
import '../widgets/todo_card.dart'; // 作成したTodoCardウィジェット

class TodoList extends StatefulWidget {
  const TodoList({super.key, required this.todoService});

  final TodoService todoService;

  @override
  State<TodoList> createState() => TodoListState();
}

class TodoListState extends State<TodoList> {
  List<Todo> _todos = [];
  bool _isLoading = true;
  final _random = Random();
  String? _completionMessage;
  int _celebrationId = 0;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  // データ読み込み処理関数を追加
  Future<void> _loadTodos() async {
    final todos = await widget.todoService.getTodos();
    if (!mounted) return;
    setState(() {
      _todos = todos;
      _isLoading = false;
    });
  }

  // 追加画面から呼ばれる追加関数を追加
  void addTodo(Todo newTodo) async {
    setState(() => _todos.add(newTodo));
    await widget.todoService.saveTodos(_todos);
  }

  // チェックボタンから呼ばれる完了状態切り替え関数を追加
  Future<void> _toggleTodo(Todo todo) async {
    setState(() {
      if (!todo.isCompleted) {
        _completionMessage =
            completionMessages[_random.nextInt(completionMessages.length)];
        _celebrationId++;
      }
      _todos = _todos.map((t) {
        if (t.id == todo.id) {
          return t.copyWith(isCompleted: !t.isCompleted);
        }
        return t;
      }).toList();
    });
    await widget.todoService.saveTodos(_todos);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // 読込中はローディングインジケーターを表示
      return const Center(child: CircularProgressIndicator());
    }

    final visibleTodos = _todos.where((todo) => !todo.isCompleted).toList();

    return Stack(
      children: [
        ListView.builder(
          itemCount: visibleTodos.length,
          itemBuilder: (context, index) {
            final todo = visibleTodos[index]; // ←追加
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: TodoCard(
                todo: todo,
                onToggle: () => _toggleTodo(todo), // 完了状態を切り替える処理を追加
              ),
            );
          },
        ),
        if (_completionMessage != null)
          Positioned.fill(
            child: CompletionCelebration(
              key: ValueKey(_celebrationId),
              message: _completionMessage!,
              onFinished: () {
                if (mounted) setState(() => _completionMessage = null);
              },
            ),
          ),
      ],
    );
  }
}

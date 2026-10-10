import 'package:flutter/material.dart';

import '../services/todo_service.dart';
import '../widgets/todo_list.dart';
import 'add_todo_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key, required this.todoService});

  final TodoService todoService;

  @override
  ListScreenState createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen> {
  // TodoListの状態を更新するためのキー
  Key _todoListKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TODOリスト')),
      body: TodoList(key: _todoListKey, todoService: widget.todoService),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 画面遷移し、戻ってきたら結果（新規 Todo）を受け取る
          final updated = await Navigator.push(
            // ←追加　Todoに追加があったらtrueを返す
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddTodoScreen(todoService: widget.todoService),
            ),
          );

          // 追加があったら再描画（TodoList を再取得）  // ←追加
          if (mounted && updated == true) {
            setState(() {
              _todoListKey = UniqueKey(); // 新しいキーで TodoList を再構築
            });
          }
        },
        backgroundColor: const Color.fromARGB(
          255,
          0,
          0,
          255,
        ), // ボタンの背景色（RGBAでも指定できます）
        foregroundColor: Colors.white, // アイコンやテキストなど、ボタン内の要素の色
        child: const Icon(Icons.add), // Flutter標準の「＋」アイコン
      ),
    );
  }
}

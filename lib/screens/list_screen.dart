import 'package:flutter/material.dart';

import '../services/todo_service.dart';
import '../models/todo_filter.dart';
import '../widgets/todo_list.dart';
import 'add_todo_screen.dart';
import 'rewards_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key, required this.todoService});

  final TodoService todoService;

  @override
  ListScreenState createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen> {
  // TodoListの状態を更新するためのキー
  Key _todoListKey = UniqueKey();
  final _filter = TodoFilter();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('✨ かなのTodo')),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'かなのメニュー ✨',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('ホーム'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.workspace_premium_outlined),
                title: const Text('がんばりましたスタンプ'),
                subtitle: const Text('これまでのがんばりを見る'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RewardsScreen(todoService: widget.todoService),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: TodoList(
        key: _todoListKey,
        todoService: widget.todoService,
        filter: _filter,
      ),
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
        tooltip: 'タスクを追加',
        backgroundColor: const Color(0xffded9ff),
        foregroundColor: const Color(0xff34365b), // アイコンやテキストなど、ボタン内の要素の色
        child: const Icon(Icons.add), // Flutter標準の「＋」アイコン
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // 日本語などロケール情報を読み込む
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferencesを使うためのライブラリ
import 'screens/list_screen.dart'; // 作成したListScreenをインポート
import 'services/todo_service.dart'; // 作成したTodoServiceをインポート

void main() async {
  // Flutter のプラグイン初期化。非同期処理を行う場合は必須
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences のインスタンスを作成
  await initializeDateFormatting('ja_JP'); // 日本語のロケール情報を読み込む
  final prefs = await SharedPreferences.getInstance(); // SharedPreferencesのインスタンスを取得

  // 作成した prefs を引数として TodoService のインスタンスを作成
  final todoService = TodoService(prefs);

  runApp(MyApp(
    todoService: todoService,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.todoService});

  final TodoService todoService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      home: ListScreen(todoService: todoService),
    );
  }
}
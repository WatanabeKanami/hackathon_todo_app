import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../services/todo_service.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({
    super.key,
    required this.todoService,
  });

  final TodoService todoService;

  @override
  AddTodoScreenState createState() => AddTodoScreenState();
}

class AddTodoScreenState extends State<AddTodoScreen> {
  // 入力内容を管理するコントローラー
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _dateController =
      TextEditingController(); // 期日表示用

  DateTime? _selectedDate; // 選択された期日

  // フォームの入力検証用
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isFormValid = false; // フォーム入力が完了しているか

  @override
  void initState() {
    super.initState();
    // テキストと期日の入力が変わるたびにチェック
    _titleController.addListener(_updateFormValid);
    _detailController.addListener(_updateFormValid);
    _dateController.addListener(_updateFormValid);
  }

  /// 全入力欄が埋まっているかを判定し、
  /// ボタンの活性状態（押せる/押せない）を更新するメソッド
  void _updateFormValid() {
    setState(() {
      _isFormValid = _titleController.text.isNotEmpty &&
          _detailController.text.isNotEmpty &&
          _selectedDate != null; // 期日が選択されているか
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新しいタスクを追加'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // 入力フォームの枠組み
          key: _formKey,
          child: Column(
            children: [
              // タイトル入力フィールド
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'タスクのタイトル',
                  hintText: '20文字以内で入力してください',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  // 入力チェック
                  if (value == null || value.isEmpty) {
                    return 'タイトルを入力してください';
                  } else if (value.length > 20) {
                    return '20文字以内で入力してください';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16), // 余白

              // 詳細入力フィールド
              TextFormField(
                controller: _detailController,
                decoration: const InputDecoration(
                  labelText: 'タスクの詳細',
                  hintText: '入力してください',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3, // 最大3行まで入力可能
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '詳細を入力してください';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 📅 期日入力フィールド（DatePicker）
              TextFormField(
                controller: _dateController,
                readOnly: true, // キーボードを表示しない
                decoration: const InputDecoration(
                  labelText: '期日',
                  hintText: '年/月/日',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  // 日付選択ダイアログを開く
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    // 選択した日付をコントローラに反映
                    _selectedDate = picked;
                    _dateController.text =
                        '${picked.year}/${picked.month}/${picked.day}';

                    // 期日を選んだあともフォーム状態を再評価
                    _updateFormValid();
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '期日を選択してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 作成ボタン
              ElevatedButton(
                onPressed: _isFormValid ? _saveTodo : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid
                      ? const Color.fromARGB(255, 0, 0, 255)
                      : Colors.grey.shade400,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ), // 入力完了で活性化
                child: Text(
                  'タスクを追加',
                  // テキストの色を変更
                  style: TextStyle(
                    color: _isFormValid ? Colors.white : Colors.grey,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // タスク作成処理
  void _saveTodo() async {
    if (_formKey.currentState!.validate()) {
      // 入力チェック
      // 新しいTodoを作成
      Todo newTodo = Todo(
        title: _titleController.text,
        detail: _detailController.text,
        dueDate: _selectedDate!,
      );

      // 既存リストを取得して追加する処理を追加  // ←追加 
      final todos = await widget.todoService.getTodos();
      todos.add(newTodo);
      await widget.todoService.saveTodos(todos);

      // この画面がまだ非表示にならずに残ってるか確認
      if (!mounted) return;

      // 前の画面へ「更新したよ」とだけ知らせる
      Navigator.pop(context, true); // ←変更
    }
  }

  @override
  void dispose() {
    // 画面が閉じられる時の処理
    _titleController.dispose(); // メモリの解放
    _detailController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初期表示時にもバリデーション
    _updateFormValid();
  }
}
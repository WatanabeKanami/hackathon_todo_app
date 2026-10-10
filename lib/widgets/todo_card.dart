import 'package:flutter/material.dart';
import 'package:intl/intl.dart';    // 日付フォーマット用パッケージ
import '../models/todo.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;                // 表示する Todo データ
  final VoidCallback? onToggle;   // 完了トグル用コールバック（任意）
  const TodoCard({
    super.key,
    required this.todo,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: SizedBox(
        width: double.infinity, // コンポーネントの領域をスマホの横幅に合わせて横幅いっぱいに取る
        height: 150,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── 左端：チェックアイコン（タップでトグル）
            IconButton(
              iconSize: 32,
              icon: Icon(
                todo.isCompleted 
                ? Icons.check_circle 
                : Icons.radio_button_unchecked,
                color: Colors.white,
              ),
              onPressed: onToggle,
            ),
            const SizedBox(width: 8),
            // ── テキスト群
            Expanded( // ↓Expandedを利用し、利用できる水平領域をすべて埋めるようにする
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    todo.detail,
                    maxLines: 1, // 最大1行まで表示
                    overflow: TextOverflow.ellipsis, // 1行を超えた場合は「...」で省略
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    DateFormat('M月d日(E)', 'ja_JP') // 日付フォーマットを指定
                        .format(todo.dueDate), // Todoの期日をフォーマットして表示
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
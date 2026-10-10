import 'package:uuid/uuid.dart'; // 一意なIDを生成するライブラリ

class Todo {
  final String id; // 一意なID（UUID）
  final String title; // タスクのタイトル（例：「レポートを書く」）
  final String detail; // タスクの詳細（例：「心理学のレポート、2000字」）
  final DateTime dueDate; // 期日（例：DateTime(2025, 4, 1)）
  final bool isCompleted; // チェック済みかどうか（true: 完了, false: 未完了）

  Todo({
    String? id, // IDが指定されない場合は自動生成
    required this.title, // タイトルは必須
    required this.detail, // 詳細も必須
    required this.dueDate, // 期日も必須
    this.isCompleted = false, // デフォルトは「未完了」
  }) : id = id ?? const Uuid().v4(); // IDの自動生成

  // 既存のTodoを一部変更したコピーを作成するメソッド
  Todo copyWith({
    String? title,
    String? detail,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Todo(
      id: id, // IDは変更しない
      title: title ?? this.title, // ❗️ 新しいタイトルまたは元のタイトルを設定してみましょう
      detail: detail ?? this.detail, // ❗️ 新しい詳細または元の詳細を設定してみましょう
      dueDate: dueDate ?? this.dueDate, // ❗️ 新しい期日または元の期日を設定してみましょう
      isCompleted: isCompleted ?? this.isCompleted, // ❗️ 新しい状態または元の状態を設定してみましょう
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'detail': detail,
    'dueDate': dueDate.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'] as String,
    title: json['title'] as String,
    detail: json['detail'] as String,
    dueDate: DateTime.parse(json['dueDate'] as String),
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}

class RewardStamp {
  const RewardStamp({
    required this.todoId,
    required this.title,
    required this.earnedAt,
  });
  final String todoId;
  final String title;
  final DateTime earnedAt;
  Map<String, dynamic> toJson() => {
    'todoId': todoId,
    'title': title,
    'earnedAt': earnedAt.toIso8601String(),
  };
  factory RewardStamp.fromJson(Map<String, dynamic> json) => RewardStamp(
    todoId: json['todoId'] as String,
    title: json['title'] as String,
    earnedAt: DateTime.parse(json['earnedAt'] as String),
  );
}

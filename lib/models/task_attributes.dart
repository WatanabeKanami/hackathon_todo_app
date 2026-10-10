class TaskOption {
  const TaskOption(this.id, this.label, this.color);
  final String id;
  final String label;
  final int color;
}

const taskOptions = <String, List<TaskOption>>{
  'mood': [
    TaskOption('motivated', '🔥 やる気がある', 0xffffe2eb),
    TaskOption('relaxed', '🍵 のんびり', 0xffdef5eb),
    TaskOption('tired', '🥱 ちょっと疲れた', 0xffe7e3ff),
    TaskOption('little', '🌱 ちょっとだけ頑張りたい', 0xffe5f5d7),
  ],
  'place': [
    TaskOption('home', '🏠 家', 0xffdef5eb),
    TaskOption('school', '🏫 学校', 0xffdff3ff),
    TaskOption('travel', '🚃 移動中', 0xffffefd4),
    TaskOption('anywhere', '🌍 どこでも', 0xffe7e3ff),
  ],
  'timeOfDay': [
    TaskOption('morning', '🌅 朝', 0xffffefd4),
    TaskOption('afternoon', '☀️ 昼', 0xfffff6c9),
    TaskOption('night', '🌙 夜', 0xffe7e3ff),
  ],
  'theme': [
    TaskOption('study', '📚 勉強', 0xffe7e3ff),
    TaskOption('club', '🎺 部活', 0xffffefd4),
    TaskOption('private', '💗 プライベート', 0xffffe2eb),
    TaskOption('creation', '💻 開発・創作', 0xffdff3ff),
    TaskOption('life', '🌿 生活', 0xffdef5eb),
  ],
  'difficulty': [
    TaskOption('easy', '🌟 すぐできる', 0xfffff6c9),
    TaskOption('medium', '💪 ちょっと頑張る', 0xffdff3ff),
    TaskOption('hard', '🏆 本気で頑張る', 0xffffe2eb),
  ],
};

String? optionLabel(String category, String? id) {
  for (final option in taskOptions[category] ?? <TaskOption>[]) {
    if (option.id == id) return option.label;
  }
  return null;
}

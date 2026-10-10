import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/reward_stamp.dart';
import '../services/todo_service.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key, required this.todoService});
  final TodoService todoService;
  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  late Future<List<RewardStamp>> _stamps;
  @override
  void initState() {
    super.initState();
    _stamps = widget.todoService.getStamps();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('🌟 がんばりましたスタンプ')),
    body: FutureBuilder<List<RewardStamp>>(
      future: _stamps,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('スタンプを読み込めませんでした'),
                TextButton(
                  onPressed: () =>
                      setState(() => _stamps = widget.todoService.getStamps()),
                  child: const Text('再読み込み'),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final stamps = snapshot.data!.reversed.toList();
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xffffe5ee), Color(0xffe6e1ff)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      const Text('🎁', style: TextStyle(fontSize: 44)),
                      Text(
                        '${stamps.length}個のがんばり',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'かなの一歩が、こんなに集まったよ。',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ごほうび付きタスクの初回完了で1個。\nやり直しても、タスクを削除しても、記念は残るよ。',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (stamps.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text('🌱 ✨', style: TextStyle(fontSize: 44)),
                        SizedBox(height: 12),
                        Text('最初のがんばりを、ここで待っているよ', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                for (final stamp in stamps)
                  Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xfffff2da),
                              border: Border.all(
                                color: const Color(0xffb98340),
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '🌟\nがんばり\nました',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xff795525),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stamp.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat('yyyy年M月d日 HH:mm')
                                      .format(stamp.earnedAt.toLocal()),
                                  style: const TextStyle(
                                    color: Color(0xff626580),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text('よく頑張ったね。自分にもごほうびを 💗'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

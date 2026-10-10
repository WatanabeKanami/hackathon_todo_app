import 'dart:math';

import 'package:flutter/material.dart';

const rewardCompletionMessages = [
  'かな、最後まで本当によく頑張ったね！\n今日は自分をたっぷり甘やかそう 💗',
  'その一歩、ちゃんと見ていたよ。\n頑張ったかなに、大きな拍手！ 🌷',
  'お疲れさま、かな！すてきな達成だね。\nひと息ついて、ごほうびを楽しもう 🍵',
];

const completionMessages = [
  'お疲れさま！よく頑張ったね！',
  'やり切ったの、えらすぎる！！',
  '未来の自分が助かるね！',
  '今日の自分、最強じゃん！',
  'ちゃんと前に進めてるよ！',
  'よし！自由時間だー！！',
  '有言実行、かっこいい！',
  'その努力、絶対ムダじゃない！',
  'えらい！自分を褒めてあげて！',
  '終わらせた君は、もう優勝！！🏆',
];

class CompletionCelebration extends StatefulWidget {
  const CompletionCelebration({
    super.key,
    required this.message,
    required this.onFinished,
    this.isReward = false,
  });

  final String message;
  final bool isReward;
  final VoidCallback onFinished;

  @override
  State<CompletionCelebration> createState() => _CompletionCelebrationState();
}

class _CompletionCelebrationState extends State<CompletionCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.isReward ? 3200 : 1800),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onFinished();
        });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final opacity = progress < 0.12
              ? progress / 0.12
              : progress < 0.55
              ? 1.0
              : (1 - progress) / 0.45;
          return Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: CustomPaint(
              painter: _ConfettiPainter(progress),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Semantics(
                    liveRegion: true,
                    child: Material(
                      elevation: 8,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Text(
                          widget.isReward
                              ? '🎁 ${widget.message}\n\n🌟 がんばりました！'
                              : '🎉 ${widget.message}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress);

  final double progress;
  static const _colors = [
    Colors.pink,
    Colors.amber,
    Colors.lightBlue,
    Colors.green,
    Colors.deepPurple,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint();
    for (var i = 0; i < 90; i++) {
      final fromLeft = i.isEven;
      final speedX = size.width * (0.2 + random.nextDouble() * 0.8);
      final speedY = size.height * (0.4 + random.nextDouble() * 0.5);
      final rotation = random.nextDouble() * pi * 2;
      final x =
          (fromLeft ? 0.0 : size.width) +
          (fromLeft ? 1 : -1) * speedX * progress;
      final y =
          size.height * 0.65 -
          speedY * progress +
          size.height * 0.9 * progress * progress;
      paint.color = _colors[i % _colors.length];
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation + progress * pi * 4);
      canvas.drawRect(const Rect.fromLTWH(-3, -5, 6, 10), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

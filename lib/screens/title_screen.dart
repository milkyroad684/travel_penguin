import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/game_controller.dart';
import '../storage/learning_history.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';
import 'map_screen.dart';

/// タイトル画面。ゲーム開始・復習モード・遊び方への入り口。
class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  final _repository = LearningHistoryRepository();
  int _weakCount = 0;
  int _bestScore = 0;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final h = await _repository.load();
    if (!mounted) return;
    setState(() {
      _weakCount = h.weakPrefectureIds.length;
      _bestScore = h.bestScore;
    });
  }

  Future<void> _start({required bool reviewMode}) async {
    final controller = context.read<GameController>();
    await controller.startGame(reviewMode: reviewMode);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
    // ゲームから戻ってきたら最新の履歴を反映する。
    _loadSummary();
  }

  void _showHowToPlay() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('遊び方'),
        content: const Text(
          '① 「県名」カードを1枚えらぶ\n'
          '② その県の「県庁所在地」カードをえらぶ\n'
          '③ 正しければカードが消えてスコアアップ！\n\n'
          '・れんぞくで正解するとコンボでスコアアップ\n'
          '・60びょうで何ポイントとれるかな？\n'
          '・まちがえた県は「ふくしゅうモード」でもう一度でるよ',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('とじる'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🐧', style: TextStyle(fontSize: 96)),
                const SizedBox(height: 8),
                const Text(
                  '旅するペンギン',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '県名と県庁所在地をつなげよう',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: 240,
                  child: ElevatedButton(
                    onPressed: () => _start(reviewMode: false),
                    child: const Text('ゲーム開始'),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: 240,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _weakCount > 0
                          ? AppColors.combo
                          : Colors.grey.shade400,
                    ),
                    onPressed:
                        _weakCount > 0 ? () => _start(reviewMode: true) : null,
                    child: Text(
                      _weakCount > 0 ? '復習モード（苦手 $_weakCount県）' : '復習モード',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: 240,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.correct,
                    ),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MapScreen()),
                      );
                      _loadSummary();
                    },
                    child: const Text('地方べつモード・全国制覇'),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: 240,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: _showHowToPlay,
                    child: const Text('遊び方'),
                  ),
                ),
                const SizedBox(height: 28),
                if (_bestScore > 0)
                  Text(
                    '🏆 ハイスコア $_bestScore',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

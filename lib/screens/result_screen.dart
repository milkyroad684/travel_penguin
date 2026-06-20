import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/prefectures.dart';
import '../game/game_controller.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';
import '../widgets/japan_map.dart';
import '../widgets/penguin_status.dart';
import 'game_screen.dart';

/// 結果画面。タイムアタックと地方べつモードの両方に対応する。
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  Future<void> _replayTimeAttack(BuildContext context,
      {required bool reviewMode}) async {
    final game = context.read<GameController>();
    await game.startGame(reviewMode: reviewMode);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  Future<void> _retryRegion(BuildContext context, String region) async {
    final game = context.read<GameController>();
    await game.startRegionGame(region);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  void _backToTitle(BuildContext context) {
    context.read<GameController>().reset();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameController>();
    final result = game.result;
    final isRegion = result.mode == GameMode.region;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: isRegion
                ? _RegionResult(
                    result: result,
                    level: game.level,
                    onRetry: () => _retryRegion(context, result.region!),
                    onMap: () => Navigator.of(context).pop(),
                    onTitle: () => _backToTitle(context),
                  )
                : _TimeAttackResult(
                    result: result,
                    level: game.level,
                    onReplay: () =>
                        _replayTimeAttack(context, reviewMode: false),
                    onReview: () =>
                        _replayTimeAttack(context, reviewMode: true),
                    onTitle: () => _backToTitle(context),
                  ),
          ),
        ),
      ),
    );
  }
}

/// タイムアタックの結果表示。
class _TimeAttackResult extends StatelessWidget {
  final GameResult result;
  final int level;
  final VoidCallback onReplay;
  final VoidCallback onReview;
  final VoidCallback onTitle;

  const _TimeAttackResult({
    required this.result,
    required this.level,
    required this.onReplay,
    required this.onReview,
    required this.onTitle,
  });

  @override
  Widget build(BuildContext context) {
    final weakNames = result.weakPrefectureIds
        .map((id) => prefectureById[id]?.prefecture ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    return Column(
      children: [
        const Text(
          'けっか',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        PenguinStatus(level: level, glow: true, size: 72),
        const SizedBox(height: 16),
        _ScoreCard(children: [
          _row('スコア', '${result.score}'),
          _row('正解数', '${result.correctCount} 問'),
          _row('最大コンボ', '${result.maxCombo}'),
          _row('正答率', '${result.accuracy}%'),
          _row('獲得けいけんち', '+${result.gainedExp}'),
        ]),
        const SizedBox(height: 16),
        if (weakNames.isNotEmpty) _WeakBox(names: weakNames),
        const SizedBox(height: 24),
        _wideButton('もう一度遊ぶ', onReplay),
        if (weakNames.isNotEmpty) ...[
          const SizedBox(height: 12),
          _wideButton('苦手県を復習', onReview, color: AppColors.combo),
        ],
        const SizedBox(height: 12),
        _wideButton('タイトルへ戻る', onTitle,
            color: Colors.white, textColor: AppColors.primary),
      ],
    );
  }
}

/// 地方べつモードの結果表示。
class _RegionResult extends StatelessWidget {
  final GameResult result;
  final int level;
  final VoidCallback onRetry;
  final VoidCallback onMap;
  final VoidCallback onTitle;

  const _RegionResult({
    required this.result,
    required this.level,
    required this.onRetry,
    required this.onMap,
    required this.onTitle,
  });

  @override
  Widget build(BuildContext context) {
    final region = result.region ?? '';
    final perfect = result.perfect;
    final color = regionColors[region] ?? AppColors.primary;

    return Column(
      children: [
        Text(
          perfect ? '🎉 せいは！🎉' : 'クリア！',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: perfect ? AppColors.combo : AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        PenguinStatus(level: level, glow: perfect, size: 72),
        const SizedBox(height: 12),
        if (perfect)
          Text(
            '$region をノーミスで制覇！\n地図がうまったよ！',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          )
        else
          Text(
            '$region をクリア！\nでも ${result.wrongCount}回 まちがえたよ。\nノーミスをめざして、もう一度ちょうせん！',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        const SizedBox(height: 16),
        // 制覇したらマップに反映された状態を見せる。
        if (perfect)
          Container(
            constraints: const BoxConstraints(maxWidth: 220),
            child: JapanMap(conqueredRegions: {region}),
          ),
        const SizedBox(height: 12),
        _ScoreCard(children: [
          _row('正解数', '${result.correctCount} 問'),
          _row('まちがえ', '${result.wrongCount} 回'),
          _row('最大コンボ', '${result.maxCombo}'),
          _row('獲得けいけんち', '+${result.gainedExp}'),
        ]),
        const SizedBox(height: 20),
        if (!perfect) _wideButton('もう一度ちょうせん', onRetry, color: AppColors.combo),
        if (!perfect) const SizedBox(height: 12),
        _wideButton('マップを見る', onMap),
        const SizedBox(height: 12),
        _wideButton('タイトルへ戻る', onTitle,
            color: Colors.white, textColor: AppColors.primary),
      ],
    );
  }
}

// ---- 共通の小さな部品 ----

Widget _wideButton(String label, VoidCallback onTap,
    {Color? color, Color? textColor}) {
  return SizedBox(
    width: 240,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
      ),
      onPressed: onTap,
      child: Text(label),
    ),
  );
}

Widget _row(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );
}

class _WeakBox extends StatelessWidget {
  final List<String> names;
  const _WeakBox({required this.names});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.wrong.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.wrong.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔁 にがてな県',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.wrong,
            ),
          ),
          const SizedBox(height: 6),
          Text(names.join('、'), style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final List<Widget> children;
  const _ScoreCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

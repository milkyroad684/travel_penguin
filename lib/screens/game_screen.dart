import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/game_controller.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';
import '../widgets/japan_map.dart';
import '../widgets/card_widget.dart';
import '../widgets/penguin_status.dart';
import 'result_screen.dart';

/// ゲーム本体の画面。
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, game, _) {
        // 時間切れ＝結果画面へ自動遷移（ビルド中の遷移を避ける）。
        if (game.status == GameStatus.finished && !_navigated) {
          _navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ResultScreen()),
            );
          });
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _Header(game: game),
                const Divider(height: 1),
                Expanded(child: _Board(game: game)),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 上部のステータス表示（時間・スコア・コンボ・ペンギン）。
class _Header extends StatelessWidget {
  final GameController game;
  const _Header({required this.game});

  @override
  Widget build(BuildContext context) {
    final isRegion = game.mode == GameMode.region;
    final timeColor = game.timeLeft <= 10 ? AppColors.wrong : AppColors.primary;
    final regionColor =
        regionColors[game.region] ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          PenguinStatus(level: game.level, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isRegion) ...[
                      Icon(Icons.flag, color: regionColor, size: 22),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${game.region}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: regionColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'そろえた ${game.pairsMatched}/${game.pairsTotal}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      Icon(Icons.timer, color: timeColor, size: 22),
                      const SizedBox(width: 4),
                      Text(
                        '${game.timeLeft}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: timeColor,
                        ),
                      ),
                      const Text(' 秒', style: TextStyle(fontSize: 14)),
                      const Spacer(),
                      Text(
                        'スコア ${game.score}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedOpacity(
                  opacity: game.combo >= 2 ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Text(
                    '${game.combo} COMBO!',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.combo,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// カード盤面。画面幅で左右2列／上下2段を切り替える。
class _Board extends StatelessWidget {
  final GameController game;
  const _Board({required this.game});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 600;
        final prefColumn = _CardColumn(
          title: '県名',
          cards: game.prefectureCards,
          game: game,
        );
        final capColumn = _CardColumn(
          title: '県庁所在地',
          cards: game.capitalCards,
          game: game,
        );

        if (wide) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: prefColumn),
                const SizedBox(width: 12),
                Expanded(child: capColumn),
              ],
            ),
          );
        }
        // 狭い画面：上下2段。それぞれ独立してスクロールできる。
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(child: prefColumn),
              const SizedBox(height: 8),
              Expanded(child: capColumn),
            ],
          ),
        );
      },
    );
  }
}

/// カード1列ぶん（見出し＋カードのグリッド）。
class _CardColumn extends StatelessWidget {
  final String title;
  final List<GameCard> cards;
  final GameController game;

  const _CardColumn({
    required this.title,
    required this.cards,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2.6,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (final card in cards)
                if (!card.matched)
                  CardWidget(
                    card: card,
                    selected: game.selectedCardId == card.id,
                    wrong: game.wrongShakeCardId == card.id,
                    onTap: () => game.onCardTap(card.id),
                  )
                else
                  const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }
}

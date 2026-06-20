/// ゲームの進行状態。
enum GameStatus { ready, playing, finished }

/// ゲームの遊び方。
/// - timeAttack: 60秒のタイムアタック（通常／復習）
/// - region: 地方べつモード（時間制限なし、その地方の全県をそろえる）
enum GameMode { timeAttack, region }

/// カードの種類（県名か、県庁所在地か）。
enum CardType { prefecture, capital }

/// 盤面に並ぶ1枚のカード。
class GameCard {
  /// 一意なカードID（"pref-13" / "cap-13" のような形）。
  final String id;

  /// どの都道府県のペアか（prefectures.dart の id）。
  final int pairId;

  /// カードに表示する文字。
  final String label;

  final CardType type;

  /// 正解して消えたかどうか。
  bool matched;

  GameCard({
    required this.id,
    required this.pairId,
    required this.label,
    required this.type,
    this.matched = false,
  });
}

/// プレイ結果（結果画面に渡す）。
class GameResult {
  final GameMode mode;

  /// 地方べつモードのときの地方名（タイムアタックでは null）。
  final String? region;

  /// 地方べつモードで、ノーミスで全問そろえたか（地方を制覇したか）。
  final bool perfect;

  /// 地方の全県をそろえ終えたか（クリアしたか）。
  final bool cleared;

  final int score;
  final int correctCount;
  final int wrongCount;
  final int maxCombo;
  final List<int> weakPrefectureIds;
  final List<int> masteredPrefectureIds;
  final int gainedExp;

  const GameResult({
    required this.mode,
    this.region,
    this.perfect = false,
    this.cleared = false,
    required this.score,
    required this.correctCount,
    required this.wrongCount,
    required this.maxCombo,
    required this.weakPrefectureIds,
    required this.masteredPrefectureIds,
    required this.gainedExp,
  });

  /// 正答率（0〜100）。出題がなければ0。
  int get accuracy {
    final total = correctCount + wrongCount;
    if (total == 0) return 0;
    return ((correctCount / total) * 100).round();
  }
}

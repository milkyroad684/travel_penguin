import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 端末に保存する学習履歴。handoff.txt §11 に準拠。
class LearningHistory {
  int totalExp;
  Set<int> masteredPrefectureIds;
  Set<int> weakPrefectureIds;
  int playCount;
  int bestScore;
  int bestCombo;

  /// ノーミスで制覇した地方名の集合（全国制覇マップで色が埋まる）。
  Set<String> conqueredRegions;

  LearningHistory({
    this.totalExp = 0,
    Set<int>? masteredPrefectureIds,
    Set<int>? weakPrefectureIds,
    this.playCount = 0,
    this.bestScore = 0,
    this.bestCombo = 0,
    Set<String>? conqueredRegions,
  })  : masteredPrefectureIds = masteredPrefectureIds ?? <int>{},
        weakPrefectureIds = weakPrefectureIds ?? <int>{},
        conqueredRegions = conqueredRegions ?? <String>{};

  Map<String, dynamic> toJson() => {
        'totalExp': totalExp,
        'masteredPrefectureIds': masteredPrefectureIds.toList(),
        'weakPrefectureIds': weakPrefectureIds.toList(),
        'playCount': playCount,
        'bestScore': bestScore,
        'bestCombo': bestCombo,
        'conqueredRegions': conqueredRegions.toList(),
      };

  factory LearningHistory.fromJson(Map<String, dynamic> json) {
    Set<int> toIntSet(dynamic v) =>
        (v as List?)?.map((e) => e as int).toSet() ?? <int>{};
    Set<String> toStringSet(dynamic v) =>
        (v as List?)?.map((e) => e as String).toSet() ?? <String>{};
    return LearningHistory(
      totalExp: (json['totalExp'] as int?) ?? 0,
      masteredPrefectureIds: toIntSet(json['masteredPrefectureIds']),
      weakPrefectureIds: toIntSet(json['weakPrefectureIds']),
      playCount: (json['playCount'] as int?) ?? 0,
      bestScore: (json['bestScore'] as int?) ?? 0,
      bestCombo: (json['bestCombo'] as int?) ?? 0,
      conqueredRegions: toStringSet(json['conqueredRegions']),
    );
  }
}

/// SharedPreferences への読み書きを担当するリポジトリ。
class LearningHistoryRepository {
  static const String _key = 'traveling_penguin_learning_history';

  Future<LearningHistory> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return LearningHistory();
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return LearningHistory.fromJson(map);
    } catch (_) {
      // 壊れたデータは初期値に戻す（クラッシュさせない）。
      return LearningHistory();
    }
  }

  Future<void> save(LearningHistory history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(history.toJson()));
  }
}

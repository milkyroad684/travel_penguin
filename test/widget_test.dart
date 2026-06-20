import 'package:flutter_test/flutter_test.dart';

import 'package:travel_penguin/data/prefectures.dart';
import 'package:travel_penguin/utils/scoring.dart';

void main() {
  group('都道府県データ', () {
    test('47件ある', () {
      expect(prefectures.length, 47);
    });

    test('idが1〜47で重複なし', () {
      final ids = prefectures.map((p) => p.id).toSet();
      expect(ids.length, 47);
      expect(ids.reduce((a, b) => a < b ? a : b), 1);
      expect(ids.reduce((a, b) => a > b ? a : b), 47);
    });

    test('県名・県庁所在地が空でない', () {
      for (final p in prefectures) {
        expect(p.prefecture.isNotEmpty, true);
        expect(p.capital.isNotEmpty, true);
      }
    });
  });

  group('地方区分', () {
    test('地方は7つ', () {
      expect(regions.length, 7);
    });

    test('全県がいずれかの地方に属し、合計47になる', () {
      var total = 0;
      for (final region in regions) {
        final count = prefectures.where((p) => p.region == region).length;
        expect(count, greaterThan(0), reason: '$region に県がない');
        total += count;
      }
      expect(total, 47);
    });

    test('各県の地方名は7区分のどれか', () {
      for (final p in prefectures) {
        expect(regions.contains(p.region), true, reason: '${p.prefecture}');
      }
    });
  });

  group('スコア計算', () {
    test('コンボ0で100点、コンボが上がると+20ずつ', () {
      expect(scoreForCombo(0), 100);
      expect(scoreForCombo(1), 120);
      expect(scoreForCombo(3), 160);
    });

    test('経験値はコンボ0で10、+2ずつ', () {
      expect(expForCombo(0), 10);
      expect(expForCombo(5), 20);
    });

    test('レベルは100経験値ごとに上がる', () {
      expect(levelFromExp(0), 1);
      expect(levelFromExp(99), 1);
      expect(levelFromExp(100), 2);
      expect(levelFromExp(450), 5);
    });
  });
}

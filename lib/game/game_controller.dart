import 'dart:async';
import 'package:flutter/foundation.dart';

import '../data/prefectures.dart';
import '../models/game_models.dart';
import '../storage/learning_history.dart';
import '../utils/scoring.dart';

/// ゲーム全体の進行を管理するコントローラ。
/// 画面はこの状態を見て表示し、タップ操作をここに伝える。
class GameController extends ChangeNotifier {
  GameController(this._repository);

  final LearningHistoryRepository _repository;

  // ---- 設定値 ----
  static const int gameSeconds = 60;
  static const int roundPairs = 8; // タイムアタック1ラウンドのペア数（handoff: 8〜12組）

  // ---- 状態 ----
  GameMode mode = GameMode.timeAttack;
  GameStatus status = GameStatus.ready;

  /// 地方べつモードのときの地方名（タイムアタックでは null）。
  String? region;

  int timeLeft = gameSeconds;
  int score = 0;
  int combo = 0;
  int maxCombo = 0;
  int correctCount = 0;
  int wrongCount = 0;
  int gainedExp = 0;
  String? selectedCardId;

  /// 直前に「不正解で揺らす」カードID（演出用、一瞬だけ立つ）。
  String? wrongShakeCardId;

  List<GameCard> cards = [];

  final Set<int> _masteredThisGame = {};
  final Set<int> _weakThisGame = {};

  bool _reviewMode = false;

  /// 地方べつモードで、この地方の全県をそろえ終えたか。
  bool _clearedRegion = false;

  /// 地方べつモードで、ノーミスで制覇したか。
  bool _conqueredRegion = false;

  /// 出題する都道府県IDの山札（タイムアタックで順番に消費する）。
  final List<int> _deck = [];
  int _deckPos = 0;

  Timer? _timer;

  /// 保存済みの累計経験値（レベル表示に使う）。
  int savedTotalExp = 0;

  /// 共通の初期化。
  Future<LearningHistory> _resetState() async {
    final history = await _repository.load();
    savedTotalExp = history.totalExp;

    status = GameStatus.playing;
    timeLeft = gameSeconds;
    score = 0;
    combo = 0;
    maxCombo = 0;
    correctCount = 0;
    wrongCount = 0;
    gainedExp = 0;
    selectedCardId = null;
    wrongShakeCardId = null;
    _clearedRegion = false;
    _conqueredRegion = false;
    _masteredThisGame.clear();
    _weakThisGame.clear();
    return history;
  }

  /// タイムアタック開始。[reviewMode] が true のときは苦手県を優先出題する。
  Future<void> startGame({required bool reviewMode}) async {
    mode = GameMode.timeAttack;
    region = null;
    _reviewMode = reviewMode;
    final history = await _resetState();

    _buildDeck(history);
    _dealNextRound();
    _startTimer();
    notifyListeners();
  }

  /// 地方べつモード開始。時間制限なし。その地方の全県をそろえる。
  Future<void> startRegionGame(String regionName) async {
    mode = GameMode.region;
    region = regionName;
    _reviewMode = false;
    await _resetState();
    timeLeft = 0; // 表示しないが念のため

    _dealRegion(regionName);
    notifyListeners();
  }

  /// この地方の全県を一度に配る（時間制限なし）。
  void _dealRegion(String regionName) {
    final ids = prefectures
        .where((p) => p.region == regionName)
        .map((p) => p.id)
        .toList();
    _buildCards(ids);
  }

  /// タイムアタックの出題順（山札）を作る。
  void _buildDeck(LearningHistory history) {
    _deck.clear();
    _deckPos = 0;

    if (_reviewMode && history.weakPrefectureIds.isNotEmpty) {
      // 復習モード：苦手県を優先。少なければ他の県で補う。
      final weak = history.weakPrefectureIds.toList()..shuffle();
      _deck.addAll(weak);
      if (_deck.length < roundPairs) {
        final others = prefectures
            .map((p) => p.id)
            .where((id) => !history.weakPrefectureIds.contains(id))
            .toList()
          ..shuffle();
        _deck.addAll(others);
      }
    } else {
      // 通常モード：全47都道府県をシャッフル。
      _deck.addAll(prefectures.map((p) => p.id).toList()..shuffle());
    }
  }

  /// タイムアタックの次のラウンドを配る。山札が尽きたら最初から繰り返す。
  void _dealNextRound() {
    if (_deck.isEmpty) return;

    final ids = <int>[];
    for (int i = 0; i < roundPairs; i++) {
      if (_deckPos >= _deck.length) {
        _deckPos = 0; // 60秒の間は周回させ続ける
        _deck.shuffle();
      }
      ids.add(_deck[_deckPos]);
      _deckPos++;
    }
    _buildCards(ids);
  }

  /// 指定した都道府県IDから県名カード・県庁所在地カードを作って盤面に並べる。
  void _buildCards(List<int> ids) {
    final prefectureCards = <GameCard>[];
    final capitalCards = <GameCard>[];
    for (final id in ids) {
      final p = prefectureById[id]!;
      prefectureCards.add(GameCard(
        id: 'pref-$id',
        pairId: id,
        label: p.prefecture,
        type: CardType.prefecture,
      ));
      capitalCards.add(GameCard(
        id: 'cap-$id',
        pairId: id,
        label: p.capital,
        type: CardType.capital,
      ));
    }
    // 県名列と県庁所在地列で並びがそろわないようにそれぞれシャッフル。
    prefectureCards.shuffle();
    capitalCards.shuffle();

    cards = [...prefectureCards, ...capitalCards];
    selectedCardId = null;
  }

  /// 県名カードだけを取り出す（表示用）。
  List<GameCard> get prefectureCards =>
      cards.where((c) => c.type == CardType.prefecture).toList();

  /// 県庁所在地カードだけを取り出す（表示用）。
  List<GameCard> get capitalCards =>
      cards.where((c) => c.type == CardType.capital).toList();

  int get level => levelFromExp(savedTotalExp + gainedExp);

  /// 地方べつモードの進捗（そろえた数 / 全体）。
  int get pairsTotal => cards.length ~/ 2;
  int get pairsMatched => cards.where((c) => c.matched).length ~/ 2;

  /// カードがタップされたときの処理。
  void onCardTap(String cardId) {
    if (status != GameStatus.playing) return;

    final tapped = cards.firstWhere((c) => c.id == cardId);
    if (tapped.matched) return;

    // 1枚目の選択
    if (selectedCardId == null) {
      selectedCardId = cardId;
      notifyListeners();
      return;
    }

    // 同じカードをもう一度押したら選択解除
    if (selectedCardId == cardId) {
      selectedCardId = null;
      notifyListeners();
      return;
    }

    final first = cards.firstWhere((c) => c.id == selectedCardId);

    // 同じ種類同士なら「選び直し」として扱う（ペナルティなし）
    if (first.type == tapped.type) {
      selectedCardId = cardId;
      notifyListeners();
      return;
    }

    // ここまで来たら種類が違う＝ペア判定する
    if (first.pairId == tapped.pairId) {
      _handleCorrect(first, tapped);
    } else {
      _handleWrong(first, tapped);
    }
  }

  void _handleCorrect(GameCard a, GameCard b) {
    a.matched = true;
    b.matched = true;
    selectedCardId = null;

    score += scoreForCombo(combo);
    gainedExp += expForCombo(combo);
    combo += 1;
    if (combo > maxCombo) maxCombo = combo;
    correctCount += 1;

    _masteredThisGame.add(a.pairId);
    _weakThisGame.remove(a.pairId);

    notifyListeners();

    // 盤面が全部消えたとき
    if (cards.every((c) => c.matched)) {
      if (mode == GameMode.region) {
        _finishRegion();
      } else {
        _dealNextRound();
        notifyListeners();
      }
    }
  }

  void _handleWrong(GameCard a, GameCard b) {
    combo = 0;
    wrongCount += 1;

    // 不正解になった「県名側」を苦手県として記録する。
    final prefCard = a.type == CardType.prefecture ? a : b;
    _weakThisGame.add(prefCard.pairId);

    // 揺らす演出のため、押した2枚目を一瞬マークする。
    wrongShakeCardId = b.id;
    selectedCardId = null;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (wrongShakeCardId == b.id) {
        wrongShakeCardId = null;
        notifyListeners();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      timeLeft -= 1;
      if (timeLeft <= 0) {
        timeLeft = 0;
        _finishTimeAttack();
      }
      notifyListeners();
    });
  }

  Future<void> _finishTimeAttack() async {
    _timer?.cancel();
    _timer = null;
    status = GameStatus.finished;

    final history = await _repository.load();
    history.totalExp += gainedExp;
    history.playCount += 1;
    history.masteredPrefectureIds.addAll(_masteredThisGame);
    history.weakPrefectureIds.addAll(_weakThisGame);
    history.weakPrefectureIds.removeAll(_masteredThisGame);
    if (score > history.bestScore) history.bestScore = score;
    if (maxCombo > history.bestCombo) history.bestCombo = maxCombo;
    await _repository.save(history);

    notifyListeners();
  }

  Future<void> _finishRegion() async {
    status = GameStatus.finished;
    _clearedRegion = true;
    _conqueredRegion = wrongCount == 0; // 一度も間違えなければ制覇

    final history = await _repository.load();
    history.totalExp += gainedExp;
    history.playCount += 1;
    history.masteredPrefectureIds.addAll(_masteredThisGame);
    history.weakPrefectureIds.addAll(_weakThisGame);
    history.weakPrefectureIds.removeAll(_masteredThisGame);
    if (score > history.bestScore) history.bestScore = score;
    if (maxCombo > history.bestCombo) history.bestCombo = maxCombo;
    if (_conqueredRegion && region != null) {
      history.conqueredRegions.add(region!);
    }
    await _repository.save(history);

    notifyListeners();
  }

  /// 結果画面に渡すためのまとめ。
  GameResult get result => GameResult(
        mode: mode,
        region: region,
        perfect: _conqueredRegion,
        cleared: _clearedRegion,
        score: score,
        correctCount: correctCount,
        wrongCount: wrongCount,
        maxCombo: maxCombo,
        weakPrefectureIds: _weakThisGame.toList(),
        masteredPrefectureIds: _masteredThisGame.toList(),
        gainedExp: gainedExp,
      );

  /// タイトルに戻るなどで状態を初期化する。
  void reset() {
    _timer?.cancel();
    _timer = null;
    status = GameStatus.ready;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// スコアと経験値の計算ルール。handoff.txt §9・§10 に準拠。

/// 正解1回で加算するスコア。コンボが続くほど高くなる。
/// 例: 1コンボ目=100, 2コンボ目=120, ...
int scoreForCombo(int combo) => 100 + combo * 20;

/// 正解1回で加算する経験値。
int expForCombo(int combo) => 10 + combo * 2;

/// 累計経験値からペンギンのレベルを求める。
int levelFromExp(int totalExp) => (totalExp ~/ 100) + 1;

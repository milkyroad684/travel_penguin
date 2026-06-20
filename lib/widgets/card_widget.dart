import 'package:flutter/material.dart';

import '../models/game_models.dart';
import '../theme/app_theme.dart';

/// 盤面の1枚のカード。選択中・不正解時の見た目を切り替える。
class CardWidget extends StatelessWidget {
  final GameCard card;
  final bool selected;
  final bool wrong;
  final VoidCallback onTap;

  const CardWidget({
    super.key,
    required this.card,
    required this.selected,
    required this.wrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = card.type == CardType.prefecture
        ? AppColors.cardPrefecture
        : AppColors.cardCapital;

    Color bg = baseColor;
    Color border = Colors.black12;
    if (selected) {
      bg = AppColors.cardSelected;
      border = AppColors.primary;
    }
    if (wrong) {
      bg = AppColors.wrong.withValues(alpha: 0.18);
      border = AppColors.wrong;
    }

    // 不正解時は少し横にずらして「揺れ」を表現する。
    final offset = wrong ? const Offset(6, 0) : Offset.zero;

    return AnimatedSlide(
      offset: offset.scale(1 / 100, 0),
      duration: const Duration(milliseconds: 80),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                card.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

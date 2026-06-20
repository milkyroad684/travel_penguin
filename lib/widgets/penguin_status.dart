import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'penguin_painter.dart';

/// リュックを背負った旅ペンギンと現在のレベルを表示する。
/// [glow] が true のとき（レベルアップ等）は周囲をキラキラさせる。
class PenguinStatus extends StatelessWidget {
  final int level;
  final bool glow;
  final double size;

  const PenguinStatus({
    super.key,
    required this.level,
    this.glow = false,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: glow ? AppColors.penguinAura : Colors.transparent,
            boxShadow: glow
                ? [
                    BoxShadow(
                      color: AppColors.penguinAura.withValues(alpha: 0.8),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: TravelPenguin(size: size),
        ),
        const SizedBox(height: 2),
        Text(
          'Lv.$level たびペンギン',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

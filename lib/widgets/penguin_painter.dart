import 'package:flutter/material.dart';

/// リュックを背負った旅するペンギン「ペンタゴン」を描くウィジェット。
/// 画像素材を使わず CustomPainter で描くので、どのレベルでも同じ姿になる。
class TravelPenguin extends StatelessWidget {
  final double size;

  const TravelPenguin({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PenguinPainter()),
    );
  }
}

class _PenguinPainter extends CustomPainter {
  // 色
  static const _body = Color(0xFF37474F); // 濃いスレートグレー
  static const _belly = Colors.white;
  static const _beak = Color(0xFFFFA726); // オレンジ
  static const _foot = Color(0xFFFB8C00);
  static const _bag = Color(0xFFEF5350); // リュック本体（赤）
  static const _bagDark = Color(0xFFC62828); // リュックの濃い部分
  static const _strap = Color(0xFFB71C1C); // 肩ひも

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    Offset o(double x, double y) => Offset(x * s, y * s);
    Rect centerRect(double cx, double cy, double w, double h) =>
        Rect.fromCenter(center: o(cx, cy), width: w * s, height: h * s);

    final fill = Paint()..style = PaintingStyle.fill;

    // --- リュック（体の後ろ。先に描いて体で半分隠す）---
    fill.color = _bag;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        centerRect(0.27, 0.52, 0.30, 0.40),
        Radius.circular(0.06 * s),
      ),
      fill,
    );
    // リュックの外ポケット
    fill.color = _bagDark;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        centerRect(0.22, 0.58, 0.16, 0.18),
        Radius.circular(0.04 * s),
      ),
      fill,
    );

    // --- 体（大きな黒い楕円）---
    fill.color = _body;
    canvas.drawOval(centerRect(0.52, 0.56, 0.64, 0.80), fill);

    // --- おなか（白）---
    fill.color = _belly;
    canvas.drawOval(centerRect(0.54, 0.62, 0.42, 0.58), fill);

    // --- 右のヒレ ---
    fill.color = _body;
    canvas.save();
    canvas.translate(o(0.84, 0.58).dx, o(0.84, 0.58).dy);
    canvas.rotate(0.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 0.10 * s, height: 0.30 * s),
      fill,
    );
    canvas.restore();

    // --- 肩ひも（おなかを斜めに横切る）---
    final strapPaint = Paint()
      ..color = _strap
      ..strokeWidth = 0.055 * s
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(o(0.40, 0.34), o(0.50, 0.78), strapPaint);
    canvas.drawLine(o(0.60, 0.34), o(0.52, 0.78), strapPaint);

    // --- 目（白目＋黒目）---
    fill.color = _belly;
    canvas.drawCircle(o(0.45, 0.40), 0.085 * s, fill);
    canvas.drawCircle(o(0.61, 0.40), 0.085 * s, fill);
    fill.color = const Color(0xFF1B1B1B);
    canvas.drawCircle(o(0.46, 0.41), 0.045 * s, fill);
    canvas.drawCircle(o(0.60, 0.41), 0.045 * s, fill);
    // 目のハイライト
    fill.color = _belly;
    canvas.drawCircle(o(0.475, 0.395), 0.016 * s, fill);
    canvas.drawCircle(o(0.615, 0.395), 0.016 * s, fill);

    // --- くちばし（オレンジの三角）---
    fill.color = _beak;
    final beak = Path()
      ..moveTo(o(0.49, 0.46).dx, o(0.49, 0.46).dy)
      ..lineTo(o(0.59, 0.46).dx, o(0.59, 0.46).dy)
      ..lineTo(o(0.54, 0.53).dx, o(0.54, 0.53).dy)
      ..close();
    canvas.drawPath(beak, fill);

    // --- 足（オレンジ）---
    fill.color = _foot;
    canvas.drawOval(centerRect(0.44, 0.95, 0.18, 0.08), fill);
    canvas.drawOval(centerRect(0.62, 0.95, 0.18, 0.08), fill);
  }

  @override
  bool shouldRepaint(covariant _PenguinPainter oldDelegate) => false;
}

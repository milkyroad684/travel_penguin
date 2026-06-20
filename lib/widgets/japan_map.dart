import 'package:flutter/material.dart';

/// 日本列島を簡略化した形で描き、制覇した地方を色で塗るウィジェット。
/// 実際の地図ほど正確ではないが、北海道〜九州が斜めに並ぶ日本の配置を表す。
class JapanMap extends StatelessWidget {
  /// 制覇済み（ノーミスでクリア）の地方名の集合。
  final Set<String> conqueredRegions;

  const JapanMap({super.key, required this.conqueredRegions});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _viewBox.width / _viewBox.height,
      child: CustomPaint(
        painter: _JapanMapPainter(conqueredRegions),
      ),
    );
  }
}

/// 描画の基準となる座標範囲（この中で各地方の形を定義する）。
const Size _viewBox = Size(200, 260);

/// 各地方の色（制覇したときに塗る色）。
const Map<String, Color> regionColors = {
  '北海道・東北': Color(0xFF42A5F5),
  '関東': Color(0xFFAB47BC),
  '中部': Color(0xFF26A69A),
  '近畿': Color(0xFFFF7043),
  '中国': Color(0xFF66BB6A),
  '四国': Color(0xFFFFCA28),
  '九州・沖縄': Color(0xFFEC407A),
};

/// 地方ごとの形（複数の島＝複数ポリゴンで構成）。
final Map<String, List<List<Offset>>> _regionShapes = {
  '北海道・東北': [
    // 北海道
    [
      Offset(150, 8),
      Offset(186, 18),
      Offset(190, 42),
      Offset(168, 56),
      Offset(140, 50),
      Offset(134, 24),
    ],
    // 東北
    [
      Offset(138, 60),
      Offset(166, 62),
      Offset(160, 116),
      Offset(134, 120),
      Offset(126, 90),
      Offset(132, 66),
    ],
  ],
  '関東': [
    [
      Offset(160, 120),
      Offset(184, 126),
      Offset(182, 150),
      Offset(154, 154),
      Offset(148, 132),
    ],
  ],
  '中部': [
    [
      Offset(104, 112),
      Offset(150, 124),
      Offset(150, 146),
      Offset(120, 160),
      Offset(96, 148),
      Offset(94, 124),
    ],
  ],
  '近畿': [
    [
      Offset(84, 148),
      Offset(118, 154),
      Offset(112, 182),
      Offset(86, 184),
      Offset(76, 162),
    ],
  ],
  '中国': [
    [
      Offset(38, 156),
      Offset(86, 160),
      Offset(86, 180),
      Offset(46, 186),
      Offset(32, 172),
    ],
  ],
  '四国': [
    [
      Offset(58, 192),
      Offset(96, 190),
      Offset(94, 210),
      Offset(60, 212),
      Offset(52, 202),
    ],
  ],
  '九州・沖縄': [
    // 九州
    [
      Offset(20, 180),
      Offset(52, 184),
      Offset(54, 216),
      Offset(30, 232),
      Offset(14, 210),
      Offset(18, 190),
    ],
    // 沖縄（小さな島）
    [
      Offset(10, 244),
      Offset(22, 244),
      Offset(22, 256),
      Offset(10, 256),
    ],
  ],
};

class _JapanMapPainter extends CustomPainter {
  final Set<String> conquered;
  _JapanMapPainter(this.conquered);

  static const _notConquered = Color(0xFFCFD8DC); // 未制覇は薄いグレー

  @override
  void paint(Canvas canvas, Size size) {
    // viewBox を実サイズにフィットさせる（縦横比は AspectRatio で保証済み）。
    final scale = size.width / _viewBox.width;
    canvas.save();
    canvas.scale(scale);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white;

    regionColors.forEach((name, color) {
      final shapes = _regionShapes[name]!;
      final isDone = conquered.contains(name);
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..color = isDone ? color : _notConquered;

      for (final polygon in shapes) {
        final path = _polygonPath(polygon);
        canvas.drawPath(path, fill);
        canvas.drawPath(path, border);
      }
    });

    canvas.restore();
  }

  Path _polygonPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _JapanMapPainter oldDelegate) =>
      oldDelegate.conquered != conquered;
}

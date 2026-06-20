import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/prefectures.dart';
import '../game/game_controller.dart';
import '../storage/learning_history.dart';
import '../theme/app_theme.dart';
import '../widgets/japan_map.dart';
import 'game_screen.dart';

/// 全国制覇マップ＝地方べつモードの入口。
/// 日本列島のマップで制覇状況を見せ、地方ボタンからその地方の挑戦を始める。
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _repository = LearningHistoryRepository();
  Set<String> _conquered = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final h = await _repository.load();
    if (!mounted) return;
    setState(() {
      _conquered = h.conqueredRegions;
      _loading = false;
    });
  }

  /// その地方に含まれる県の数。
  int _countOf(String region) =>
      prefectures.where((p) => p.region == region).length;

  Future<void> _startRegion(String region) async {
    final controller = context.read<GameController>();
    await controller.startRegionGame(region);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
    // 挑戦から戻ったら制覇状況を更新する。
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final conqueredCount = _conquered.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('全国制覇マップ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '制覇した地方： $conqueredCount / ${regions.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ノーミスで全問そろえると、その地方が地図にうかび上がるよ！',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // 日本列島マップ
                  Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    padding: const EdgeInsets.all(8),
                    child: JapanMap(conqueredRegions: _conquered),
                  ),
                  if (conqueredCount == regions.length)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '🎉 全国制覇おめでとう！🎉',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.combo,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 4),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '地方をえらんで挑戦',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final region in regions)
                    _RegionTile(
                      region: region,
                      count: _countOf(region),
                      conquered: _conquered.contains(region),
                      color: regionColors[region] ?? AppColors.primary,
                      onTap: () => _startRegion(region),
                    ),
                ],
              ),
            ),
    );
  }
}

/// 地方1つぶんのボタン行。
class _RegionTile extends StatelessWidget {
  final String region;
  final int count;
  final bool conquered;
  final Color color;
  final VoidCallback onTap;

  const _RegionTile({
    required this.region,
    required this.count,
    required this.conquered,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: conquered ? color : const Color(0xFFCFD8DC),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    region,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '$count県',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(width: 10),
                if (conquered)
                  const Icon(Icons.check_circle, color: AppColors.correct)
                else
                  const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

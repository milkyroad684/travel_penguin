import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'game/game_controller.dart';
import 'screens/title_screen.dart';
import 'storage/learning_history.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TravelPenguinApp());
}

class TravelPenguinApp extends StatelessWidget {
  const TravelPenguinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController(LearningHistoryRepository()),
      child: MaterialApp(
        title: '旅するペンギン',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const TitleScreen(),
      ),
    );
  }
}

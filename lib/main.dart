import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import 'game/goal_zone_game.dart';
import 'game/overlays/main_menu.dart';
import 'game/overlays/game_hud.dart';
import 'game/overlays/pause_menu.dart';
import 'game/overlays/game_over.dart';
import 'game/overlays/win.dart';
import 'models/difficulty.dart';

void main() {
  runApp(const GameApp());
}

class GameApp extends StatefulWidget {
  const GameApp({Key? key}) : super(key: key);

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late GoalZoneGame _game;

  @override
  void initState() {
    super.initState();
    // Başlangıçta kolay, ama MainMenu overlay’i açık olacak
    _game = GoalZoneGame(Difficulty.easy);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoalZone',
      home: Scaffold(
        body: GameWidget<GoalZoneGame>(
          game: _game,
          overlayBuilderMap: {
            'MainMenu': (context, game) {
              return MainMenu(
                onSelect: (d) {
                  // Seçilen zorluk ile oyunu resetle ve başlat
                  game.resetGame(newDifficulty: d);
                  game.overlays
                    ..remove('MainMenu')
                    ..add('GameHud');
                },
              );
            },
            'GameHud': (context, game) => GameHud(game: game),
            'PauseMenu': (context, game) {
              return PauseMenu(
                onResume: () {
                  game.overlays
                    ..remove('PauseMenu')
                    ..add('GameHud');
                  game.resumeEngine();
                },
                onMainMenu: () => game.resetGame(),
              );
            },
            'GameOver': (context, game) => GameOver(game: game),
            'Win': (context, game) => Win(game: game),
          },
          // Uygulama açıldığında yalnızca MainMenu aktif olsun
          initialActiveOverlays: const ['MainMenu'],
        ),
      ),
    );
  }
}

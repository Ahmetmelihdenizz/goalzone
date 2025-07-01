import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame/collisions.dart';
import '../models/difficulty.dart';
import '../services/theme.dart';
import 'components/ball.dart';
import 'components/paddle.dart';
import 'components/goal_area.dart';
import 'components/goal_sensor.dart';
import 'components/particle_effects.dart';
import 'package:flutter/material.dart';

enum Side { top, right, bottom, left }

class GoalZoneGame extends FlameGame with HasCollisionDetection {
  Difficulty difficulty;
  GoalZoneGame(this.difficulty);

  static const double wallThickness = 16.0;
  static final ui.Paint wallPaint = ui.Paint()..color = AppColors.wall;

  late Side playerSide;
  int playerScore = 0;
  int botScore = 0;
  List<Ball> balls = [];

  ui.Rect get innerRect => ui.Rect.fromLTWH(
    wallThickness,
    wallThickness,
    size.x - 2 * wallThickness,
    size.y - 2 * wallThickness,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (kDebugMode) {
      add(
        FpsTextComponent(
          position: Vector2(10, 10),
          anchor: Anchor.topLeft,
          textRenderer: TextPaint(
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      );
    }
    _addWalls();

    playerSide = Side.values[Random().nextInt(Side.values.length)];

    for (final side in Side.values) {
      add(GoalArea(side));
      add(Paddle(side: side, isPlayer: side == playerSide));
    }
    _spawnGoalSensors();
    _spawnBalls();
    overlays.add('MainMenu');
  }

  void _addWalls() {
    final w = size.x, h = size.y, t = wallThickness;
    final start = (w - GoalArea.areaLength) / 2;
    final end = start + GoalArea.areaLength;
    addAll([
      _Wall(ui.Rect.fromLTWH(0, 0, start, t)),
      _Wall(ui.Rect.fromLTWH(end, 0, w - end, t)),
      _Wall(ui.Rect.fromLTWH(0, h - t, start, t)),
      _Wall(ui.Rect.fromLTWH(end, h - t, w - end, t)),
      _Wall(ui.Rect.fromLTWH(0, 0, t, h)),
      _Wall(ui.Rect.fromLTWH(w - t, 0, t, h)),
    ]);
  }

  void _spawnGoalSensors() {
    final w = size.x, h = size.y, t = wallThickness;
    addAll(
      Side.values.map((side) {
        final pos =
            side == Side.top || side == Side.bottom
                ? Vector2(
                  w / 2,
                  side == Side.top
                      ? t + GoalArea.areaThickness / 2
                      : h - t - GoalArea.areaThickness / 2,
                )
                : Vector2(
                  side == Side.left
                      ? t + GoalArea.areaThickness / 2
                      : w - t - GoalArea.areaThickness / 2,
                  h / 2,
                );
        return GoalSensor(position: pos, side: side);
      }),
    );
  }

  void _spawnBalls() {
    // Önce eski topları sil
    children.whereType<Ball>().forEach((b) => b.removeFromParent());
    balls.clear();
    int ballCount = (difficulty == Difficulty.hard) ? 2 : 1;
    for (int i = 0; i < ballCount; i++) {
      final ball = Ball(initialSpeed: difficulty.ballSpeed);
      balls.add(ball);
      add(ball);
    }
  }

  void _cleanUpGame() {
    children.whereType<Ball>().forEach((b) => b.removeFromParent());
    balls.clear();
    children.whereType<Sparkle>().forEach((e) => e.removeFromParent());
    children.whereType<BigExplosion>().forEach((e) => e.removeFromParent());
    children.whereType<TimerComponent>().forEach((t) => t.removeFromParent());
  }

  void onGoal(Side goalSide, Ball scoredBall) {
    add(BigExplosion(scoredBall.position.clone()));
    scoredBall.removeFromParent();
    balls.remove(scoredBall);

    if (goalSide == playerSide) {
      playerScore++;
    } else {
      botScore++;
    }
    overlays
      ..remove('GameHud')
      ..add('GameHud');

    if (playerScore >= 5) {
      _cleanUpGame();
      pauseEngine();
      overlays.add('GameOver');
    } else if (botScore >= 5) {
      _cleanUpGame();
      pauseEngine();
      overlays.add('Win');
    } else {
      children.whereType<GoalSensor>().forEach((s) => s.reset());
      // Her zaman toplam ballCount kadar top olsun:
      int targetCount = (difficulty == Difficulty.hard) ? 2 : 1;
      while (balls.length < targetCount) {
        final newBall = Ball(initialSpeed: difficulty.ballSpeed);
        balls.add(newBall);
        add(newBall);
      }
    }
  }

  void resetGame({Difficulty? newDifficulty}) {
    if (newDifficulty != null) {
      difficulty = newDifficulty;
    }
    playerScore = 0;
    botScore = 0;
    children.whereType<GoalSensor>().forEach((s) => s.reset());
    _cleanUpGame();
    _spawnBalls();

    overlays
      ..remove('GameOver')
      ..remove('Win')
      ..remove('GameHud')
      ..add('MainMenu');
    resumeEngine();
  }
}

class _Wall extends PositionComponent with CollisionCallbacks {
  _Wall(ui.Rect rect)
    : super(
        position: Vector2(rect.left, rect.top),
        size: Vector2(rect.width, rect.height),
        anchor: Anchor.topLeft,
      ) {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void render(ui.Canvas canvas) {
    canvas.drawRect(size.toRect(), GoalZoneGame.wallPaint);
  }
}

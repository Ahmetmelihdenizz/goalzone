import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/difficulty.dart';
import '../services/theme.dart';
import 'components/ball.dart';
import 'components/paddle.dart';
import 'components/goal_area.dart';
import 'components/goal_sensor.dart';
import 'components/particle_effects.dart';

enum Side { top, right, bottom, left }

class GoalZoneGame extends FlameGame with HasCollisionDetection {
  GoalZoneGame(this.difficulty);

  Difficulty difficulty;

  static const double wallThickness = 16.0;
  static final ui.Paint wallPaint = ui.Paint()..color = AppColors.wall;

  late Side playerSide;
  int playerScore = 0;
  int botScore = 0;
  final List<Ball> balls = [];

  /// İç dikdörtgen (duvarların içi)
  ui.Rect get innerRect => ui.Rect.fromLTWH(
    wallThickness,
    wallThickness,
    size.x - 2 * wallThickness,
    size.y - 2 * wallThickness,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // FPS sayaçları sadece debug’da
    if (kDebugMode) {
      add(
        FpsTextComponent(
          position: Vector2(10, 10),
          anchor: Anchor.topLeft,
          textRenderer: TextPaint(
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      );
    }

    _addWalls();

    // Oyuncu hangi kenarda?
    playerSide = Side.values[Random().nextInt(Side.values.length)];

    // Kale bölgeleri + paddle’lar
    for (final side in Side.values) {
      add(GoalArea(side));
      add(Paddle(side: side, isPlayer: side == playerSide));
    }

    _spawnGoalSensors();
    _spawnBalls();
    overlays.add('MainMenu');
  }

  /* ------------------------------------------------------------------ */
  /* --------------------------  DUVARLAR  ---------------------------- */
  /* ------------------------------------------------------------------ */
  void _addWalls() {
    final w = size.x, h = size.y, t = wallThickness;

    // Kale boşluklarının başlangıç / bitiş koordinatları
    final gapHStart = (w - GoalArea.areaLength) / 2;
    final gapHEnd = gapHStart + GoalArea.areaLength;
    final gapVStart = (h - GoalArea.areaLength) / 2;
    final gapVEnd = gapVStart + GoalArea.areaLength;

    addAll([
      // ÜST duvar (iki parça)
      _Wall(ui.Rect.fromLTWH(0, 0, gapHStart, t)),
      _Wall(ui.Rect.fromLTWH(gapHEnd, 0, w - gapHEnd, t)),

      // ALT duvar (iki parça)
      _Wall(ui.Rect.fromLTWH(0, h - t, gapHStart, t)),
      _Wall(ui.Rect.fromLTWH(gapHEnd, h - t, w - gapHEnd, t)),

      // SOL duvar (iki parça)
      _Wall(ui.Rect.fromLTWH(0, 0, t, gapVStart)),
      _Wall(ui.Rect.fromLTWH(0, gapVEnd, t, h - gapVEnd)),

      // SAĞ duvar (iki parça)
      _Wall(ui.Rect.fromLTWH(w - t, 0, t, gapVStart)),
      _Wall(ui.Rect.fromLTWH(w - t, gapVEnd, t, h - gapVEnd)),
    ]);
  }

  /* ------------------------------------------------------------------ */
  /* ----------------------  GOL SENSÖRLERİ  --------------------------- */
  /* ------------------------------------------------------------------ */
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

  /* ------------------------------------------------------------------ */
  /* ---------------------------  TOPLAR  ------------------------------ */
  /* ------------------------------------------------------------------ */
  void _spawnBalls() {
    // Eski topları temizle
    children.whereType<Ball>().forEach((b) => b.removeFromParent());
    balls.clear();

    final ballCount = difficulty == Difficulty.hard ? 2 : 1;

    for (var i = 0; i < ballCount; i++) {
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

  /* ------------------------------------------------------------------ */
  /* ----------------------------  GOL  ------------------------------- */
  /* ------------------------------------------------------------------ */
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

    // Kazanan 5 gol
    if (playerScore >= 5) {
      _cleanUpGame();
      pauseEngine();
      overlays.add('GameOver');
    } else if (botScore >= 5) {
      _cleanUpGame();
      pauseEngine();
      overlays.add('Win');
    } else {
      // Yeni top ekle
      children.whereType<GoalSensor>().forEach((s) => s.reset());
      final targetCount = difficulty == Difficulty.hard ? 2 : 1;
      while (balls.length < targetCount) {
        final newBall = Ball(initialSpeed: difficulty.ballSpeed);
        balls.add(newBall);
        add(newBall);
      }
    }
  }

  /* ------------------------------------------------------------------ */
  /* -------------------------  RESET GAME  --------------------------- */
  /* ------------------------------------------------------------------ */
  void resetGame({Difficulty? newDifficulty}) {
    if (newDifficulty != null) difficulty = newDifficulty;

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

/* -------------------------------------------------------------------- */
/* ----------------------------  WALL  -------------------------------- */
/* -------------------------------------------------------------------- */
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

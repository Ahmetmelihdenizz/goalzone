import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import '../../services/theme.dart';
import '../../models/difficulty.dart';
import '../goal_zone_game.dart';
import '../side_extensions.dart';

class Paddle extends PositionComponent
    with HasGameRef<GoalZoneGame>, DragCallbacks, CollisionCallbacks {
  Paddle({required this.side, required this.isPlayer});
  final Side side;
  final bool isPlayer;
  static final Vector2 _rawSize = Vector2(180, 19);

  @override
  Future<void> onLoad() async {
    size = _rawSize;
    anchor = Anchor.center;
    position = _initialPosition();
    if (side == Side.left || side == Side.right) angle = pi / 2;
    final paint =
        Paint()..color = isPlayer ? AppColors.primary : AppColors.secondary;
    add(RectangleComponent(size: size, paint: paint));
    add(RectangleHitbox());
  }

  Vector2 _initialPosition() {
    final w = gameRef.size.x, h = gameRef.size.y;
    const margin = 32.0;
    switch (side) {
      case Side.top:
        return Vector2(w / 2, margin + size.y / 2);
      case Side.bottom:
        return Vector2(w / 2, h - margin - size.y / 2);
      case Side.left:
        return Vector2(margin + size.y / 2, h / 2);
      case Side.right:
        return Vector2(w - margin - size.y / 2, h / 2);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!isPlayer) return;
    final delta = event.localDelta;
    if (side.isHorizontal) {
      position.x += delta.x;
    } else {
      position.y += delta.x;
    }
    _clampWithinBounds();
  }

  void _clampWithinBounds() {
    final halfLength = size.x / 2, halfThickness = size.y / 2;
    if (side.isHorizontal) {
      position.x = position.x.clamp(halfLength, gameRef.size.x - halfLength);
      position.y = position.y.clamp(
        halfThickness,
        gameRef.size.y - halfThickness,
      );
    } else {
      position.x = position.x.clamp(
        halfThickness,
        gameRef.size.x - halfThickness,
      );
      position.y = position.y.clamp(halfLength, gameRef.size.y - halfLength);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isPlayer || gameRef.balls.isEmpty) return;

    final followedBall = gameRef.balls.first;
    final target = side.isHorizontal ? followedBall.x : followedBall.y;
    final current = side.isHorizontal ? x : y;
    final dir = (target - current).sign;
    final speed = switch (gameRef.difficulty) {
      Difficulty.easy => 200,
      Difficulty.medium => 300,
      Difficulty.hard => 400,
    };
    final delta = dir * speed * dt;
    if (side.isHorizontal) {
      position.x += delta;
    } else {
      position.y += delta;
    }
    _clampWithinBounds();
  }
}

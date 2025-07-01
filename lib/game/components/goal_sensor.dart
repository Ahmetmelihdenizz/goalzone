import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../goal_zone_game.dart';
import 'ball.dart';
import 'goal_area.dart'; // GoalArea'yı tanımlayan dosya!
import '../side_extensions.dart'; // isHorizontal extension'ı burada!

class GoalSensor extends PositionComponent
    with HasGameRef<GoalZoneGame>, CollisionCallbacks {
  GoalSensor({required Vector2 position, required this.side})
    : super(
        position: position,
        size:
            side.isHorizontal
                ? Vector2(GoalArea.areaLength, GoalArea.areaThickness)
                : Vector2(GoalArea.areaThickness, GoalArea.areaLength),
        anchor: Anchor.center,
      );

  final Side side;
  bool _triggered = false;

  void reset() {
    _triggered = false;
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (!_triggered && other is Ball) {
      _triggered = true;
      gameRef.onGoal(side, other);
    }
    super.onCollision(points, other);
  }
}

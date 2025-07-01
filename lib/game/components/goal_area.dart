// lib/game/components/goal_area.dart

import 'dart:ui' as ui;
import 'package:flame/components.dart';
import '../goal_zone_game.dart';
import '../side_extensions.dart'; // isHorizontal extension!
import '../../services/theme.dart';

class GoalArea extends PositionComponent with HasGameRef<GoalZoneGame> {
  static const double areaLength = 200.0;
  static const double areaThickness = 10.0;

  final Side side;
  GoalArea(this.side);

  @override
  Future<void> onLoad() async {
    size =
        side.isHorizontal
            ? Vector2(areaLength, areaThickness)
            : Vector2(areaThickness, areaLength);
    anchor = Anchor.center;
    position = _initialPosition();
  }

  Vector2 _initialPosition() {
    final w = gameRef.size.x;
    final h = gameRef.size.y;
    const m = 16.0;
    switch (side) {
      case Side.top:
        return Vector2(w / 2, m + areaThickness / 2);
      case Side.bottom:
        return Vector2(w / 2, h - m - areaThickness / 2);
      case Side.left:
        return Vector2(m + areaThickness / 2, h / 2);
      case Side.right:
        return Vector2(w - m - areaThickness / 2, h / 2);
    }
  }

  @override
  void render(ui.Canvas canvas) {
    final paint = ui.Paint()..color = AppColors.areaFill;
    canvas.drawRect(size.toRect(), paint);
  }
}

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../goal_zone_game.dart';
import '../side_extensions.dart';
import 'goal_area.dart';

String _sideName(Side side) {
  switch (side) {
    case Side.top:
      return 'KUZEY';
    case Side.bottom:
      return 'GÜNEY';
    case Side.left:
      return 'BATI';
    case Side.right:
      return 'DOĞU';
  }
}

class PaddleLabel extends TextComponent with HasGameRef<GoalZoneGame> {
  final Side side;
  final bool isPlayer;

  PaddleLabel({required this.side, required this.isPlayer})
    : super(
        text: isPlayer ? 'OYUNCU' : 'BOT ${_sideName(side)}',
        textRenderer: TextPaint(
          style: TextStyle(
            color: isPlayer ? Colors.redAccent : Colors.blueAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = _initialPosition();
  }

  Vector2 _initialPosition() {
    final area = gameRef.children.whereType<GoalArea>().firstWhere(
      (a) => a.side == side,
    );
    if (side.isHorizontal) {
      return Vector2(area.position.x, area.position.y + area.size.y / 2 + 20);
    } else {
      return Vector2(area.position.x + area.size.x / 2 + 40, area.position.y);
    }
  }
}

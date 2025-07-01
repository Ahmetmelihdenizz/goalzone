import 'dart:ui' as ui;
import 'package:flame/components.dart';

/// Köşe ring görseli
class GoalRing extends CircleComponent {
  GoalRing({
    required Vector2 position,
    required ui.Color strokeColor,
    double radius = 24.0,
  }) : super(
         position: position,
         radius: radius,
         paint:
             ui.Paint()
               ..style = ui.PaintingStyle.stroke
               ..strokeWidth = 4
               ..color = strokeColor,
       );
}

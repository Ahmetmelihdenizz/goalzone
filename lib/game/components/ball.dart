import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import '../goal_zone_game.dart';
import 'goal_area.dart'; //  <-- Kalenin ölçülerine erişmek için
import '../side_extensions.dart';
import '../../models/difficulty.dart';
import '../../services/theme.dart';
import 'particle_effects.dart';
import 'paddle.dart';

class Ball extends CircleComponent
    with HasGameRef<GoalZoneGame>, CollisionCallbacks {
  Ball({required this.initialSpeed})
    : super(radius: 12, paint: Paint()..color = AppColors.primary);

  /* ---------------------------------------------------- */
  /* -----------------  Özellikler  ---------------------- */
  /* ---------------------------------------------------- */
  final double initialSpeed;
  late Vector2 velocity;

  int _hitCount = 0;
  double _sparkleCooldown = 0.0;

  static const double _sparkleDelay = 0.1;
  static const int maxHits = 2;
  static const double boostFactor = 1.05;
  static const double maxSpeed = 500.0;
  static const double bounceAngleDeg = 60.0;
  static final _rng = math.Random();

  /* ---------------------------------------------------- */
  /* ------------------  Yaşam Döngüsü  ------------------ */
  /* ---------------------------------------------------- */
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final ir = gameRef.innerRect;
    position = Vector2(ir.center.dx, ir.center.dy);
    _launch();
    add(CircleHitbox()..collisionType = CollisionType.active);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Soğuma süresi
    _sparkleCooldown = math.max(0, _sparkleCooldown - dt);

    // Pozisyon güncelle
    position += velocity * dt;

    _handleWallBounce();
  }

  /* ---------------------------------------------------- */
  /* --------------  Duvar / Kale Kontrolü  -------------- */
  /* ---------------------------------------------------- */
  void _handleWallBounce() {
    final t = GoalZoneGame.wallThickness;

    final minX = t + radius;
    final maxX = gameRef.size.x - t - radius;
    final minY = t + radius;
    final maxY = gameRef.size.y - t - radius;

    // Kale boşlukları
    final gapHStart = (gameRef.size.x - GoalArea.areaLength) / 2;
    final gapHEnd = gapHStart + GoalArea.areaLength;
    final gapVStart = (gameRef.size.y - GoalArea.areaLength) / 2;
    final gapVEnd = gapVStart + GoalArea.areaLength;

    var bounced = false;

    // SOL / SAĞ
    if (position.x <= minX) {
      final inGap = position.y > gapVStart && position.y < gapVEnd;
      if (!inGap) {
        position.x = minX;
        velocity.x = velocity.x.abs();
        bounced = true;
      }
    } else if (position.x >= maxX) {
      final inGap = position.y > gapVStart && position.y < gapVEnd;
      if (!inGap) {
        position.x = maxX;
        velocity.x = -velocity.x.abs();
        bounced = true;
      }
    }

    // ÜST / ALT
    if (position.y <= minY) {
      final inGap = position.x > gapHStart && position.x < gapHEnd;
      if (!inGap) {
        position.y = minY;
        velocity.y = velocity.y.abs();
        bounced = true;
      }
    } else if (position.y >= maxY) {
      final inGap = position.x > gapHStart && position.x < gapHEnd;
      if (!inGap) {
        position.y = maxY;
        velocity.y = -velocity.y.abs();
        bounced = true;
      }
    }

    // Parıltı efekti
    if (bounced && _sparkleCooldown == 0) {
      _sparkleCooldown = _sparkleDelay;
      gameRef.add(Sparkle(position.clone()));
    }
  }

  /* ---------------------------------------------------- */
  /* --------------  Paddle Çarpışması  ------------------ */
  /* ---------------------------------------------------- */
  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);

    // Sadece Paddle’a çarptığında
    if (other is! Paddle) return;

    if (_sparkleCooldown == 0) {
      _sparkleCooldown = _sparkleDelay;
      gameRef.add(Sparkle(position.clone()));
    }

    // Medium / Easy modlarda top hızlanır
    if (gameRef.difficulty != Difficulty.hard) {
      _hitCount++;
      if (_hitCount <= maxHits) {
        final double newSpeed = math.min(
          velocity.length * boostFactor,
          maxSpeed,
        );
        velocity = velocity.normalized() * newSpeed;
      } else if (velocity.length > maxSpeed) {
        velocity = velocity.normalized() * maxSpeed;
      }
    }

    // 60° açıyla sektir
    final rad = bounceAngleDeg * math.pi / 180;
    final sp = velocity.length;

    if (other.side.isHorizontal) {
      final dirY = other.side == Side.top ? 1 : -1;
      final signX = _rng.nextBool() ? 1 : -1;
      velocity = Vector2(math.cos(rad) * sp * signX, math.sin(rad) * sp * dirY);
    } else {
      final dirX = other.side == Side.left ? 1 : -1;
      final signY = _rng.nextBool() ? 1 : -1;
      velocity = Vector2(math.sin(rad) * sp * dirX, math.cos(rad) * sp * signY);
    }
  }

  /* ---------------------------------------------------- */
  /* --------------------  Başlatma  --------------------- */
  /* ---------------------------------------------------- */
  void _launch() {
    final ang = (_rng.nextDouble() * math.pi / 3) + math.pi / 6;
    velocity =
        Vector2(math.cos(ang), math.sin(ang)) * initialSpeed
          ..multiply(
            Vector2(_rng.nextBool() ? 1 : -1, _rng.nextBool() ? 1 : -1),
          );
  }
}

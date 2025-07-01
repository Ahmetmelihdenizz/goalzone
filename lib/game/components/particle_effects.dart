import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import '../../services/theme.dart';

class Sparkle extends ParticleSystemComponent with HasGameRef {
  static const _lifespan = 0.21;
  Sparkle(Vector2 pos)
    : super(
        position: pos,
        particle: Particle.generate(
          count: 10,
          lifespan: _lifespan,
          generator:
              (_) => AcceleratedParticle(
                acceleration: Vector2(0, 400),
                speed: Vector2.random()..scale(150),
                child: CircleParticle(
                  radius: 2,
                  paint: Paint()..color = AppColors.sparkle1,
                ),
              ),
        ),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      TimerComponent(
        period: _lifespan,
        removeOnFinish: true,
        repeat: false,
        onTick: () => removeFromParent(),
      ),
    );
  }
}

class BigExplosion extends ParticleSystemComponent with HasGameRef {
  static const _lifespan = 0.2;
  BigExplosion(Vector2 pos)
    : super(
        position: pos,
        particle: Particle.generate(
          count: 30,
          lifespan: _lifespan,
          generator:
              (_) => AcceleratedParticle(
                acceleration: Vector2(0, 200),
                speed: Vector2.random()..scale(250),
                child: CircleParticle(
                  radius: 3,
                  paint: Paint()..color = AppColors.sparkle2,
                ),
              ),
        ),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      TimerComponent(
        period: _lifespan,
        removeOnFinish: true,
        repeat: false,
        onTick: () => removeFromParent(),
      ),
    );
  }
}

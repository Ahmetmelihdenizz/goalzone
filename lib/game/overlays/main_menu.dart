import 'package:flutter/material.dart';
import '../../models/difficulty.dart';
import '../../services/theme.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key, required this.onSelect});
  final void Function(Difficulty) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/menu_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.background.withOpacity(0.90),
              AppColors.background.withOpacity(0.70),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık
              Text(
                'GOALZONE',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),
              // Düğmeler
              for (final level in Difficulty.values) ...[
                _DifficultyButton(level, onSelect),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  const _DifficultyButton(this.level, this.onTap, {Key? key}) : super(key: key);

  final Difficulty level;
  final void Function(Difficulty) onTap;

  Color get _fillColor {
    switch (level) {
      case Difficulty.easy:
        return const Color(0xFF4CAF50); // yeşil
      case Difficulty.medium:
        return const Color(0xFFFFA200); // turuncu
      case Difficulty.hard:
        return const Color(0xFFFF001E); // kırmızı
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onTap(level),
      style: ElevatedButton.styleFrom(
        backgroundColor: _fillColor,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 60),
        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        shadowColor: _fillColor.withOpacity(0.4),
      ),
      child: Text(level.label),
    );
  }
}

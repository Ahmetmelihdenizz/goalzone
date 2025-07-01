enum Difficulty { easy, medium, hard }

extension DifficultyProps on Difficulty {
  /// Menüde ve HUD’da gösterilecek metin
  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'BASİT';
      case Difficulty.medium:
        return 'ORTA';
      case Difficulty.hard:
        return 'ZOR';
    }
  }

  /// Topun başlangıç hızı (px/s)
  double get ballSpeed {
    switch (this) {
      case Difficulty.easy:
        return 250;
      case Difficulty.medium:
        return 350;
      case Difficulty.hard:
        return 500;
    }
  }
}

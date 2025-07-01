import 'package:flutter/material.dart';
import '../goal_zone_game.dart';

class GameHud extends StatelessWidget {
  const GameHud({Key? key, required this.game}) : super(key: key);
  final GoalZoneGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Senin paddle'ının skoru (OYUNCU)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BOTLARIN SKORU',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${game.playerScore}',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Zorluk seviyesi
            Text(
              game.difficulty.name.toUpperCase(),
              style: const TextStyle(fontSize: 22, color: Colors.white70),
            ),
            // Bot skorları
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'OYUNCU SKORU',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${game.botScore}',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

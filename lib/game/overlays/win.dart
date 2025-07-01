import 'package:flutter/material.dart';
import '../goal_zone_game.dart';

class Win extends StatelessWidget {
  const Win({Key? key, required this.game}) : super(key: key);
  final GoalZoneGame game;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Kazandınız!',
            style: TextStyle(fontSize: 48, color: Colors.green),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: game.resetGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // eski primary
              foregroundColor: Colors.white, // eski onPrimary
            ),
            child: const Text('Anasayfaya Dön'),
          ),
        ],
      ),
    );
  }
}

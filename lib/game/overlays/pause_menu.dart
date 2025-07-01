import 'package:flutter/material.dart';

/// Oyun duraklatıldığında gösterilecek menü.
class PauseMenu extends StatelessWidget {
  const PauseMenu({Key? key, required this.onResume, required this.onMainMenu})
    : super(key: key);

  final VoidCallback onResume;
  final VoidCallback onMainMenu;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Oyun Duraklatıldı',
            style: TextStyle(fontSize: 32, color: Colors.white),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onResume, child: const Text('Devam Et')),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onMainMenu,
            child: const Text('Anasayfaya Dön'),
          ),
        ],
      ),
    );
  }
}

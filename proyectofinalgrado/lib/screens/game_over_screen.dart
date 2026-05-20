import 'dart:io';
import 'package:flutter/material.dart';
import 'play_screen.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 29, 20, 13),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontFamily: 'Inconsolata',
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE8706A),
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 60),
            _MenuButton(
              label: 'Menú principal',
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const PlayScreen()),
                (_) => false,
              ),
            ),
            const SizedBox(height: 16),
            _MenuButton(
              label: 'Salir',
              onTap: () => exit(0),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(120, 255, 255, 255)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inconsolata',
            fontSize: 16,
            color: Color.fromARGB(200, 255, 255, 255),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

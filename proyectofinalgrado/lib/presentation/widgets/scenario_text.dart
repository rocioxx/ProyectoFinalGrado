import 'package:flutter/material.dart';
import '../../domain/entities/carta.dart';
import '../../domain/entities/game_state.dart';

class ScenarioText extends StatelessWidget {
  const ScenarioText({
    super.key,
    required this.carta,
    required this.gameState,
    required this.dragX,
    required this.threshold,
  });

  final Carta carta;
  final GameState gameState;
  final double dragX;
  final double threshold;

  @override
  Widget build(BuildContext context) {
    final progress = (dragX.abs() / (threshold * 0.5)).clamp(0.0, 1.0);
    final isLeft = dragX < 0;
    final choiceText = isLeft ? carta.opcionIzquierda : carta.opcionDerecha;
    const choiceColor = Color(0xFF6BCB77);

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 1.0 - progress,
          child: Text(
            carta.textoFor(gameState),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inconsolata',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(221, 255, 255, 255),
            ),
          ),
        ),
        if (dragX.abs() > 0.5)
          Opacity(
            opacity: progress,
            child: Text(
              choiceText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inconsolata',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: choiceColor,
              ),
            ),
          ),
      ],
    );
  }
}

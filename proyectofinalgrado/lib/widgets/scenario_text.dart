import 'package:flutter/material.dart';
import '../models/carta.dart';

class ScenarioText extends StatelessWidget {
  const ScenarioText({
    super.key,
    required this.carta,
    required this.dragX,
    required this.threshold,
  });

  final Carta carta;
  final double dragX; // valor actual de _x (0 cuando no se arrastra)
  final double threshold; // mínimo para considerar swipe válido

  @override
  Widget build(BuildContext context) {
    // 0.0 en reposo → 1.0 al llegar al umbral
    final progress = (dragX.abs() / (threshold * 0.5)).clamp(0.0, 1.0);
    final isLeft = dragX < 0;

    final choiceText = isLeft
        ? carta.opcionIzquierda
        : carta.opcionDerecha;
    final choiceColor = isLeft
        ? const Color(0xFF6BCB77)
        : const Color(0xFF6BCB77);

    return Stack(
      alignment: Alignment.center,
      children: [
        //desaparece la pregunta
        Opacity(
          opacity: 1.0 - progress,
          child: Text(
            carta.texto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inconsolata',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(221, 255, 255, 255),
            ),
          ),
        ),

        //aparece la opcion elegida
        if (dragX.abs() > 0.5)
          Opacity(
            opacity: progress,
            child: Text(
              choiceText,
              textAlign: TextAlign.center,
              style: TextStyle(
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

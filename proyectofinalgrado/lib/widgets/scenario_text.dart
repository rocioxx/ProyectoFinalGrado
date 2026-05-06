import 'package:flutter/material.dart';
import '../models/scenario.dart';

class ScenarioText extends StatelessWidget {
  const ScenarioText({
    super.key,
    required this.scenario,
    required this.dragX,
    required this.threshold,
  });

  final Scenario scenario;
  final double dragX; // valor actual de _x (0 cuando no se arrastra)
  final double threshold; // mínimo para considerar swipe válido

  @override
  Widget build(BuildContext context) {
    // 0.0 en reposo → 1.0 al llegar al umbral
    final progress = (dragX.abs() / (threshold * 0.5)).clamp(0.0, 1.0);
    final isLeft = dragX < 0;

    final choiceText = isLeft
        ? scenario.opcionIzquierda
        : scenario.opcionDerecha;
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
            scenario.texto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Lora',
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
                fontFamily: 'Lora',
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

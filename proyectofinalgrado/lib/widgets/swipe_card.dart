import 'package:flutter/material.dart';

// Widget visual de la carta.
// Es StatelessWidget porque no tiene estado propio: solo pinta el diseño.
// La lógica de movimiento y animación vive en CardScreen.
class SwipeCard extends StatelessWidget {
  const SwipeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // esquinas redondeadas
        boxShadow: const [
          // Sombra suave para dar sensación de profundidad
          BoxShadow(color: Colors.black26, blurRadius: 10),
        ],
      ),
    );
  }
}

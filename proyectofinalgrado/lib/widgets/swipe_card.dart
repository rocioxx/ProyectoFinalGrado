import 'package:flutter/material.dart';

// Widget visual de la carta.
// Es StatelessWidget porque no tiene estado propio: solo pinta el diseño.
// La lógica de movimiento y animación vive en CardScreen.
class SwipeCard extends StatelessWidget {
  const SwipeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350, //ancho de la carta
      height: 400, //alto de la carta
      decoration: BoxDecoration(
        color: Colors.white, //color blanco
        borderRadius: BorderRadius.circular(16), // esquinas redondeadas
        boxShadow: const [
          // Sombra suave para dar sensación de profundidad
          BoxShadow(color: Colors.black, blurRadius: 10),
        ],
      ),
    );
  }
}

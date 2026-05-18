import 'game_state.dart';
import 'consecuencia.dart';

typedef EfectoCarta = Consecuencia Function(GameState estado);

class Carta {
  const Carta({
    required this.texto,
    required this.opcionIzquierda,
    required this.opcionDerecha,
    required this.efectoIzquierda,
    required this.efectoDerecha,
    this.condicion, // null = siempre disponible en el pool
  });

  final String texto;
  final String opcionIzquierda;
  final String opcionDerecha;
  final EfectoCarta efectoIzquierda;
  final EfectoCarta efectoDerecha;

  // Si está definida, la carta solo entra al pool cuando devuelve true.
  // Permite cartas que solo aparecen bajo ciertas condiciones (flags, objetos...).
  final bool Function(GameState)? condicion;
}

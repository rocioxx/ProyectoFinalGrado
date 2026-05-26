import 'consecuencia.dart';
import 'game_state.dart';

typedef EfectoCarta = Consecuencia Function(GameState estado);

class Carta {
  const Carta({
    required this.texto,
    required this.opcionIzquierda,
    required this.opcionDerecha,
    required this.efectoIzquierda,
    required this.efectoDerecha,
    this.condicion,
    this.imagen,
  });

  final String texto;
  final String opcionIzquierda;
  final String opcionDerecha;
  final EfectoCarta efectoIzquierda;
  final EfectoCarta efectoDerecha;
  final bool Function(GameState)? condicion;
  final String? imagen;
}

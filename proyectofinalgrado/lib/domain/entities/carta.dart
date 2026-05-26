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
    this.textoBuilder,
    this.nota,
    this.efectoTextoIzquierda,
    this.efectoTextoDerecha,
    this.saltable = true,
  });

  final String texto;
  final String opcionIzquierda;
  final String opcionDerecha;
  final EfectoCarta efectoIzquierda;
  final EfectoCarta efectoDerecha;
  final bool Function(GameState)? condicion;
  final String? imagen;
  final String Function(GameState)? textoBuilder;
  final String Function(GameState)? nota;
  final String? efectoTextoIzquierda;
  final String? efectoTextoDerecha;
  final bool saltable;

  String textoFor(GameState s) => textoBuilder?.call(s) ?? texto;
}

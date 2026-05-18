import '../models/carta.dart';
import '../models/consecuencia.dart';
import '../models/game_state.dart';

/// Ejecuta la decisión del jugador: resuelve qué Consecuencia corresponde,
/// aplica los deltas con clamp(0–100), lanza el callback de flags y guarda
/// el texto de resolución en el estado.
///
/// Devuelve la [Consecuencia] resultante para que la UI pueda mostrar su texto.
Consecuencia aplicarDecision(
  GameState estado,
  Carta carta,
  bool eligioIzquierda,
) {
  // El callback de la carta "observa" el estado y decide qué consecuencia dar
  final consecuencia = eligioIzquierda
      ? carta.efectoIzquierda(estado)
      : carta.efectoDerecha(estado);

  // Aplicamos los deltas numéricos con clamp para no desbordar las barras
  estado.vida = (estado.vida + consecuencia.deltaVida).clamp(0.0, 100.0);
  estado.suerte = (estado.suerte + consecuencia.deltaSuerte).clamp(0.0, 100.0);
  estado.tiempo = (estado.tiempo + consecuencia.deltaTiempo).clamp(0.0, 100.0);
  estado.poder = (estado.poder + consecuencia.deltaPoder).clamp(0.0, 100.0);

  // El callback de flags/inventario se lanza DESPUÉS de los deltas, para que
  // pueda sobreescribir valores si es necesario (p.ej. vida = 100 al curarse)
  consecuencia.onApply?.call(estado);

  estado.textoResolucion = consecuencia.texto;
  return consecuencia;
}

import 'dart:math';
import '../models/carta.dart';
import '../models/game_state.dart';
import 'cartas_data.dart';

final _rng = Random();

/// Devuelve la carta del siguiente turno:
/// - Si hay una carta pendiente (encadenada por una decisión anterior) → esa.
/// - Si no → elige al azar entre las cartas disponibles según condicion.
Carta nextCarta(GameState estado) {
  if (estado.cartaPendiente != null) {
    final carta = estado.cartaPendiente as Carta;
    estado.cartaPendiente = null;
    return carta;
  }

  final pool = todasLasCartas
      .where((c) => c.condicion == null || c.condicion!(estado))
      .toList();

  return pool[_rng.nextInt(pool.length)];
}

import '../../domain/entities/carta.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/repositories/i_game_repository.dart';
import '../datasources/card_datasource.dart';

class GameRepositoryImpl implements IGameRepository {
  @override
  Carta drawCard(GameState state) => nextCarta(state);

  @override
  void applyDecision(GameState state, Carta carta, bool eligioIzquierda) {
    final consecuencia = eligioIzquierda
        ? carta.efectoIzquierda(state)
        : carta.efectoDerecha(state);

    state.vida = (state.vida + consecuencia.deltaVida).clamp(0.0, 100.0);
    state.suerte = (state.suerte + consecuencia.deltaSuerte).clamp(0.0, 100.0);
    state.tiempo = (state.tiempo + consecuencia.deltaTiempo).clamp(0.0, 100.0);
    state.poder = (state.poder + consecuencia.deltaPoder).clamp(0.0, 100.0);

    consecuencia.onApply?.call(state);
    state.textoResolucion = consecuencia.texto;
  }
}

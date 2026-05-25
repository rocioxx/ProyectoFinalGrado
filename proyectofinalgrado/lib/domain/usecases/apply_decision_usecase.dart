import '../entities/carta.dart';
import '../entities/game_state.dart';
import '../repositories/i_game_repository.dart';

class ApplyDecisionUseCase {
  const ApplyDecisionUseCase(this._repo);
  final IGameRepository _repo;

  void call(GameState state, Carta carta, bool eligioIzquierda) =>
      _repo.applyDecision(state, carta, eligioIzquierda);
}

import '../entities/carta.dart';
import '../entities/game_state.dart';
import '../repositories/i_game_repository.dart';

class DrawCardUseCase {
  const DrawCardUseCase(this._repo);
  final IGameRepository _repo;

  Carta call(GameState state) => _repo.drawCard(state);
}

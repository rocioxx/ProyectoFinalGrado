import '../entities/carta.dart';
import '../repositories/i_game_repository.dart';

class SkipCardUseCase {
  const SkipCardUseCase(this._repo);
  final IGameRepository _repo;

  Carta call() => _repo.cartaEnemigoRandom();
}

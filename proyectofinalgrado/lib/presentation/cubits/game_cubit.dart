import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/analytics/analytics_service.dart';
import '../../domain/entities/carta.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/usecases/apply_decision_usecase.dart';
import '../../domain/usecases/draw_card_usecase.dart';
import '../../domain/usecases/skip_card_usecase.dart';
import 'game_ui_state.dart';

class GameCubit extends Cubit<GameUiState> {
  GameCubit._({
    required DrawCardUseCase drawCard,
    required ApplyDecisionUseCase applyDecision,
    required SkipCardUseCase skipCard,
    required AnalyticsService analytics,
    required GameState gameState,
    required Carta initialCard,
  })  : _drawCard = drawCard,
        _applyDecision = applyDecision,
        _skipCard = skipCard,
        _analytics = analytics,
        _gameState = gameState,
        super(GamePlaying(cartaActual: initialCard, gameState: gameState));

  factory GameCubit({
    required DrawCardUseCase drawCard,
    required ApplyDecisionUseCase applyDecision,
    required SkipCardUseCase skipCard,
  }) {
    final sessionId = AnalyticsService.generateSessionId();
    final abGroup = AnalyticsService.assignAbGroup();
    final analytics = AnalyticsService(sessionId: sessionId, abGroup: abGroup);

    final state = GameState(abGroup: abGroup);
    analytics.gameStarted();

    return GameCubit._(
      drawCard: drawCard,
      applyDecision: applyDecision,
      skipCard: skipCard,
      analytics: analytics,
      gameState: state,
      initialCard: drawCard(state),
    );
  }

  final DrawCardUseCase _drawCard;
  final ApplyDecisionUseCase _applyDecision;
  final SkipCardUseCase _skipCard;
  final AnalyticsService _analytics;
  final GameState _gameState;
  final DateTime _inicio = DateTime.now();
  int _cartasJugadas = 0;
  int _ruletasUsadas = 0;

  int get _duracionSegundos => DateTime.now().difference(_inicio).inSeconds;

  void skipCard() {
    _ruletasUsadas++;
    _analytics.ruletaUsed();
    _gameState.cartaPendiente = null;
    _gameState.enemyVida = null;
    _gameState.enemyMaxVida = null;
    emit(GamePlaying(
      cartaActual: _skipCard(),
      gameState: _gameState,
    ));
  }

  Future<void> applyDecision(Carta carta, bool eligioIzquierda) async {
    _cartasJugadas++;

    // Fire-and-forget: no bloquear la UI por cada swipe
    _analytics.cardSwiped(
      carta: carta.texto.split('\n').first,
      direccion: eligioIzquierda ? 'izquierda' : 'derecha',
    );

    final enemyVidaAntes = _gameState.enemyVida;
    _applyDecision(_gameState, carta, eligioIzquierda);

    if (enemyVidaAntes == null && _gameState.enemyVida != null) {
      _analytics.combatStarted(carta.texto.split('\n').first);
    }

    if (_gameState.victoria) {
      // Emitir primero para que la UI reaccione, luego esperar confirmación de Supabase
      emit(GameVictoryState(gameState: _gameState));
      await _analytics.gameWon({
        'vida': _gameState.vida,
        'poder': _gameState.poder,
        'suerte': _gameState.suerte,
        'tiempo': _gameState.tiempo,
        'duracion_segundos': _duracionSegundos,
        'cartas_jugadas': _cartasJugadas,
        'ruletas_usadas': _ruletasUsadas,
      });
      return;
    }
    if (_gameState.vida <= 0 ||
        _gameState.suerte <= 0 ||
        _gameState.tiempo <= 0 ||
        _gameState.poder <= 0) {
      emit(GameOverState(gameState: _gameState));
      await _analytics.gameOver(
        statMuerta: _gameState.vida <= 0
            ? 'vida'
            : _gameState.suerte <= 0
                ? 'suerte'
                : _gameState.tiempo <= 0
                    ? 'tiempo'
                    : 'poder',
        stats: {
          'vida': _gameState.vida,
          'poder': _gameState.poder,
          'suerte': _gameState.suerte,
          'tiempo': _gameState.tiempo,
          'duracion_segundos': _duracionSegundos,
          'cartas_jugadas': _cartasJugadas,
          'ruletas_usadas': _ruletasUsadas,
        },
      );
      return;
    }
    emit(GamePlaying(
      cartaActual: _drawCard(_gameState),
      gameState: _gameState,
    ));
  }
}

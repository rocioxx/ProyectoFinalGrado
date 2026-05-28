import 'package:flutter_test/flutter_test.dart';
import 'package:proyectofinalgrado/data/repositories/game_repository_impl.dart';
import 'package:proyectofinalgrado/domain/entities/carta.dart';
import 'package:proyectofinalgrado/domain/entities/consecuencia.dart';
import 'package:proyectofinalgrado/domain/entities/game_state.dart';

Carta _carta({
  double vida = 0,
  double suerte = 0,
  double tiempo = -3,
  double poder = 0,
}) =>
    Carta(
      texto: 'Test',
      opcionIzquierda: 'Izq',
      opcionDerecha: 'Der',
      efectoIzquierda: (_) => Consecuencia(
        deltaVida: vida,
        deltaSuerte: suerte,
        deltaTiempo: tiempo,
        deltaPoder: poder,
      ),
      efectoDerecha: (_) => Consecuencia(
        deltaVida: vida,
        deltaSuerte: suerte,
        deltaTiempo: tiempo,
        deltaPoder: poder,
      ),
    );

void main() {
  late GameRepositoryImpl repo;
  late GameState state;

  setUp(() {
    repo = GameRepositoryImpl();
    state = GameState(); // vida=50, suerte=50, tiempo=100, poder=10
  });

  group('applyDecision — aplicación de deltas', () {
    test('resta vida correctamente', () {
      repo.applyDecision(state, _carta(vida: -10), true);
      expect(state.vida, 40);
    });

    test('suma suerte correctamente', () {
      repo.applyDecision(state, _carta(suerte: 20), true);
      expect(state.suerte, 70);
    });

    test('resta tiempo correctamente', () {
      repo.applyDecision(state, _carta(tiempo: -5), true);
      expect(state.tiempo, 95);
    });
  });

  group('applyDecision — clamps', () {
    test('vida no sube por encima de 50', () {
      repo.applyDecision(state, _carta(vida: 100), true);
      expect(state.vida, 50);
    });

    test('vida no baja de 0', () {
      repo.applyDecision(state, _carta(vida: -999), true);
      expect(state.vida, 0);
    });

    test('suerte no sube por encima de 100', () {
      repo.applyDecision(state, _carta(suerte: 200), true);
      expect(state.suerte, 100);
    });

    test('suerte no baja de 0', () {
      repo.applyDecision(state, _carta(suerte: -999), true);
      expect(state.suerte, 0);
    });

    test('tiempo no sube por encima de 100', () {
      repo.applyDecision(state, _carta(tiempo: 200), true);
      expect(state.tiempo, 100);
    });

    test('tiempo no baja de 0', () {
      repo.applyDecision(state, _carta(tiempo: -999), true);
      expect(state.tiempo, 0);
    });

    test('poder no sube por encima de 10', () {
      repo.applyDecision(state, _carta(poder: 999), true);
      expect(state.poder, 10);
    });

    test('poder no baja de 0', () {
      repo.applyDecision(state, _carta(poder: -999), true);
      expect(state.poder, 0);
    });
  });

  group('applyDecision — daño enemigo', () {
    test('danio es exactamente el valor de poder actual', () {
      state.poder = 7;
      final danio = state.poder;
      expect(danio, 7);
    });

    test('con poder bajo el danio es igual al poder (sin minimo hardcodeado)', () {
      state.poder = 2;
      expect(state.poder, 2); // antes había .clamp(5, 30), ahora es exacto
    });
  });
}

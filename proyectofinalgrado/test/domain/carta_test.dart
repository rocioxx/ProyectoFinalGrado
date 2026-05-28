import 'package:flutter_test/flutter_test.dart';
import 'package:proyectofinalgrado/domain/entities/carta.dart';
import 'package:proyectofinalgrado/domain/entities/consecuencia.dart';
import 'package:proyectofinalgrado/domain/entities/game_state.dart';

Carta _cartaTest({
  double deltaVidaIzq = 0,
  double deltaVidaDer = 0,
  double deltaSuerteIzq = 0,
  double deltaSuerteDer = 0,
  double deltaTiempoIzq = -3,
  double deltaTiempoDer = -3,
  double deltaPoderIzq = 0,
  double deltaPoderDer = 0,
}) =>
    Carta(
      texto: 'Carta de prueba',
      opcionIzquierda: 'Izquierda',
      opcionDerecha: 'Derecha',
      efectoIzquierda: (_) => Consecuencia(
        deltaVida: deltaVidaIzq,
        deltaSuerte: deltaSuerteIzq,
        deltaTiempo: deltaTiempoIzq,
        deltaPoder: deltaPoderIzq,
      ),
      efectoDerecha: (_) => Consecuencia(
        deltaVida: deltaVidaDer,
        deltaSuerte: deltaSuerteDer,
        deltaTiempo: deltaTiempoDer,
        deltaPoder: deltaPoderDer,
      ),
    );

void main() {
  group('Carta — efectos', () {
    final state = GameState();

    test('efectoIzquierda devuelve Consecuencia con deltaVida correcto', () {
      final carta = _cartaTest(deltaVidaIzq: -10);
      final c = carta.efectoIzquierda(state);
      expect(c.deltaVida, -10);
    });

    test('efectoDerecha devuelve Consecuencia con deltaSuerte correcto', () {
      final carta = _cartaTest(deltaSuerteDer: 15);
      final c = carta.efectoDerecha(state);
      expect(c.deltaSuerte, 15);
    });

    test('saltable es true por defecto', () {
      expect(_cartaTest().saltable, true);
    });

    test('carta no saltable respeta el flag', () {
      final carta = Carta(
        texto: 'Combate',
        opcionIzquierda: 'Atacar',
        opcionDerecha: 'Atacar',
        efectoIzquierda: (_) => const Consecuencia(),
        efectoDerecha: (_) => const Consecuencia(),
        saltable: false,
      );
      expect(carta.saltable, false);
    });

    test('textoFor usa textoBuilder si existe', () {
      final carta = Carta(
        texto: 'Texto base',
        opcionIzquierda: 'Sí',
        opcionDerecha: 'No',
        efectoIzquierda: (_) => const Consecuencia(),
        efectoDerecha: (_) => const Consecuencia(),
        textoBuilder: (s) => 'Vida: ${s.vida.toInt()}',
      );
      expect(carta.textoFor(state), 'Vida: 50');
    });

    test('textoFor usa texto base si no hay textoBuilder', () {
      final carta = _cartaTest();
      expect(carta.textoFor(state), 'Carta de prueba');
    });
  });
}

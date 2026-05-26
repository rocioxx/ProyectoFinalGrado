import 'dart:math';
import '../../domain/entities/carta.dart';
import '../../domain/entities/consecuencia.dart';
import '../../domain/entities/game_state.dart';

final _rng = Random();

// ── Helpers de navegación ─────────────────────────────────────────────────────

void _ir(GameState s, Carta c) => s.cartaPendiente = c;

// ── Helpers de probabilidad ───────────────────────────────────────────────────

bool _victoria(GameState s, {double base = 0.45}) =>
    _rng.nextDouble() <
    (base + s.poder * 0.003 + s.suerte * 0.002).clamp(0.0, 0.90);

bool _conSuerte(GameState s, double base) =>
    _rng.nextDouble() < (base + (s.suerte - 50) * 0.003).clamp(0.0, 1.0);

// ── Enemigos aleatorios ───────────────────────────────────────────────────────

final _esqueleto = Carta(
  imagen: 'lib/fotos/esqueleto.jpg',
  texto: 'Un esqueleto te corta el paso.',
  opcionIzquierda: 'Huir',
  opcionDerecha: 'Luchar',
  efectoIzquierda: (_) => const Consecuencia(deltaVida: -5, deltaTiempo: -8),
  efectoDerecha: (s) => _victoria(s, base: 0.55)
      ? const Consecuencia(deltaPoder: 8, deltaTiempo: -5)
      : const Consecuencia(deltaVida: -10, deltaTiempo: -10),
);

final _goblin = Carta(
  imagen: 'lib/fotos/goblin.jpg',
  texto: 'Un goblin con escudo te intercepta.',
  opcionIzquierda: 'Negociar',
  opcionDerecha: 'Luchar',
  efectoIzquierda: (_) => const Consecuencia(deltaTiempo: -10),
  efectoDerecha: (s) => _victoria(s, base: 0.40)
      ? const Consecuencia(deltaPoder: 12, deltaTiempo: -5)
      : const Consecuencia(deltaVida: -2, deltaTiempo: -10),
);

final _slime = Carta(
  imagen: 'lib/fotos/slime.jpg',
  texto: 'Un slime bloquea el pasillo.',
  opcionIzquierda: 'Rodearlo',
  opcionDerecha: 'Atacarlo',
  efectoIzquierda: (_) => const Consecuencia(deltaTiempo: -8),
  efectoDerecha: (s) => _victoria(s, base: 0.50)
      ? const Consecuencia(deltaVida: 5, deltaTiempo: -5)
      : const Consecuencia(deltaPoder: -5, deltaTiempo: -10),
);

final _arana = Carta(
  imagen: 'lib/fotos/araña.jpg',
  texto: 'Una araña gigante desciende del techo.',
  opcionIzquierda: 'Intentar huir',
  opcionDerecha: 'Luchar',
  efectoIzquierda: (_) => const Consecuencia(deltaVida: -2, deltaTiempo: -8),
  efectoDerecha: (s) => _victoria(s, base: 0.60)
      ? const Consecuencia(deltaSuerte: 5, deltaTiempo: -5)
      : const Consecuencia(deltaVida: -2, deltaTiempo: -10),
);

final _poolEnemigos = [_esqueleto, _goblin, _slime, _arana];

// Copia texto, opciones e imagen del enemigo original, luego encadena a siguiente
Carta _encuentroEnemigo(Carta siguiente) {
  final e = _poolEnemigos[_rng.nextInt(_poolEnemigos.length)];
  return Carta(
    imagen: e.imagen,
    texto: e.texto,
    opcionIzquierda: e.opcionIzquierda,
    opcionDerecha: e.opcionDerecha,
    efectoIzquierda: (s) {
      final c = e.efectoIzquierda(s);
      _ir(s, siguiente);
      return c;
    },
    efectoDerecha: (s) {
      final c = e.efectoDerecha(s);
      _ir(s, siguiente);
      return c;
    },
  );
}

// ── Historia de la mazmorra ───────────────────────────────────────────────────

final Carta _cartaCombateNigromante = Carta(
  texto: 'El nigromante alza su baston.\nDebes acabar con el.',
  opcionIzquierda: 'Golpe normal',
  opcionDerecha: 'Golpe critico (requiere mucha suerte)',
  efectoIzquierda: (s) {
    if (_victoria(s, base: 0.40)) {
      return Consecuencia(
        deltaTiempo: -5,
        onApply: (st) => st.victoria = true,
      );
    }
    return Consecuencia(
      deltaVida: -5,
      deltaTiempo: -10,
      onApply: (st) => _ir(st, _cartaCombateNigromante),
    );
  },
  efectoDerecha: (s) {
    if (s.suerte >= 70 && _conSuerte(s, 0.3)) {
      return Consecuencia(
        deltaSuerte: 5,
        deltaTiempo: -5,
        onApply: (st) => st.victoria = true,
      );
    }
    return Consecuencia(
      deltaVida: -10,
      deltaTiempo: -10,
      onApply: (st) => _ir(st, _cartaCombateNigromante),
    );
  },
);

final _cartaNigromanteHabla = Carta(
  texto: 'El nigromante rie y te empuja.\nNo hay salida.',
  opcionIzquierda: 'Resistir',
  opcionDerecha: 'Reaccionar',
  efectoIzquierda: (s) => Consecuencia(
    deltaTiempo: -3,
    onApply: (st) => _ir(st, _cartaCombateNigromante),
  ),
  efectoDerecha: (s) => Consecuencia(
    deltaTiempo: -3,
    onApply: (st) => _ir(st, _cartaCombateNigromante),
  ),
);

final _cartaNigromante = Carta(
  texto: 'Ante ti esta el nigromante.\nSeñor de esta mazmorra.',
  opcionIzquierda: 'No pelear',
  opcionDerecha: 'Luchar',
  efectoIzquierda: (s) => Consecuencia(
    deltaTiempo: -3,
    onApply: (st) => _ir(st, _cartaNigromanteHabla),
  ),
  efectoDerecha: (s) => Consecuencia(
    deltaTiempo: -3,
    onApply: (st) => _ir(st, _cartaCombateNigromante),
  ),
);

final _cartaPuertaFinal = Carta(
  imagen: 'lib/fotos/puerta principio.jpg',
  texto: 'Una gran puerta bloquea el camino.\nAl otro lado se oye algo.',
  opcionIzquierda: 'Intentar abrirla',
  opcionDerecha: 'Darle una patada',
  efectoIzquierda: (s) => Consecuencia(
    deltaTiempo: -3,
    onApply: (st) => _ir(st, _cartaNigromante),
  ),
  efectoDerecha: (s) => Consecuencia(
    deltaTiempo: -3,
    onApply: (st) => _ir(st, _cartaNigromante),
  ),
);

final _cartaCantimplora = Carta(
  imagen: 'lib/fotos/cantimplora.jpg',
  texto: 'Encuentras una cantimplora en el suelo.\nParece intacta.',
  opcionIzquierda: 'Beber',
  opcionDerecha: 'Cogerla y beber',
  efectoIzquierda: (s) {
    final buena = _conSuerte(s, 0.5);
    return Consecuencia(
      deltaVida: buena ? 10 : -10,
      deltaTiempo: buena ? -3 : -5,
      onApply: (st) =>
          _ir(st, _encuentroEnemigo(_encuentroEnemigo(_cartaPuertaFinal))),
    );
  },
  efectoDerecha: (s) {
    final buena = _conSuerte(s, 0.5);
    return Consecuencia(
      deltaVida: buena ? 10 : -10,
      deltaTiempo: buena ? -3 : -5,
      onApply: (st) =>
          _ir(st, _encuentroEnemigo(_encuentroEnemigo(_cartaPuertaFinal))),
    );
  },
);

final Carta _cartaPasilloOscuro = Carta(
  imagen: 'lib/fotos/pasillooscuro.jpg',
  texto: 'El pasillo esta completamente oscuro.\nNo ves nada.',
  opcionIzquierda: 'Ir a la izquierda',
  opcionDerecha: 'Ir a la derecha',
  efectoIzquierda: (s) => Consecuencia(
    deltaTiempo: -5,
    onApply: (st) => _ir(st, _cartaPasilloOscuro),
  ),
  efectoDerecha: (s) => Consecuencia(
    deltaSuerte: 10,
    deltaPoder: 5,
    deltaTiempo: -3,
    onApply: (st) => _ir(st, _cartaCantimplora),
  ),
);

final _cartaMimico = Carta(
  imagen: 'lib/fotos/mimico.jpg',
  texto: 'El cofre tiene dientes.\nEs un mimico.',
  opcionIzquierda: 'Intentar huir',
  opcionDerecha: 'Luchar',
  efectoIzquierda: (s) => Consecuencia(
    deltaVida: -10,
    deltaTiempo: -10,
    onApply: (st) => _ir(st, _cartaPasilloOscuro),
  ),
  efectoDerecha: (s) {
    if (_victoria(s, base: 0.50)) {
      return Consecuencia(
        deltaSuerte: 15,
        deltaPoder: 10,
        deltaTiempo: -5,
        onApply: (st) => _ir(st, _encuentroEnemigo(_cartaPasilloOscuro)),
      );
    }
    return Consecuencia(
      deltaVida: -20,
      deltaTiempo: -10,
      onApply: (st) => _ir(st, _cartaPasilloOscuro),
    );
  },
);

final _cartaCofre = Carta(
  imagen: 'lib/fotos/cofre cerrado.jpg',
  texto: 'Hay un cofre en el pasillo.\nParece cerrado.',
  opcionIzquierda: 'Ignorarlo',
  opcionDerecha: 'Abrirlo',
  efectoIzquierda: (s) => Consecuencia(
    deltaTiempo: -5,
    onApply: (st) => _ir(st, _encuentroEnemigo(_cartaPasilloOscuro)),
  ),
  efectoDerecha: (s) {
    if (_conSuerte(s, 0.5)) {
      return Consecuencia(
        deltaVida: 20,
        deltaTiempo: -3,
        onApply: (st) => _ir(st, _encuentroEnemigo(_cartaPasilloOscuro)),
      );
    }
    return Consecuencia(
      deltaTiempo: -5,
      onApply: (st) => _ir(st, _cartaMimico),
    );
  },
);

final _cartaCombateAventurero = Carta(
  imagen: 'lib/fotos/pasillo mazmorra.jpg',
  texto: 'El aventurero se gira y ataca.\nNo esperabas esto.',
  opcionIzquierda: 'Huir',
  opcionDerecha: 'Luchar',
  efectoIzquierda: (s) => Consecuencia(
    deltaVida: -5,
    deltaTiempo: -8,
    onApply: (st) => _ir(st, _cartaPasilloOscuro),
  ),
  efectoDerecha: (s) {
    if (_victoria(s, base: 0.55)) {
      return Consecuencia(
        deltaPoder: 10,
        deltaTiempo: -5,
        onApply: (st) => _ir(st, _encuentroEnemigo(_cartaPasilloOscuro)),
      );
    }
    return Consecuencia(
      deltaVida: -15,
      deltaTiempo: -10,
      onApply: (st) => _ir(st, _cartaPasilloOscuro),
    );
  },
);

final _cartaAventurero = Carta(
  imagen: 'lib/fotos/pasillo mazmorra.jpg',
  texto: 'Un aventurero herido pide ayuda.\nParece en apuros.',
  opcionIzquierda: 'No ayudar',
  opcionDerecha: 'Ayudar',
  efectoIzquierda: (s) => Consecuencia(
    deltaTiempo: -3,
    onApply: (st) => _ir(st, _cartaCofre),
  ),
  efectoDerecha: (s) => Consecuencia(
    deltaTiempo: -3,
    onApply: (st) => _ir(st, _cartaCombateAventurero),
  ),
);

final _cartaPrimerPasillo = Carta(
  imagen: 'lib/fotos/pasillo mazmorra.jpg',
  texto: 'Dos pasillos se abren ante ti.\nEl aire huele a humedad.',
  opcionIzquierda: 'Pasillo izquierdo',
  opcionDerecha: 'Pasillo derecho',
  efectoIzquierda: (s) => Consecuencia(
    deltaTiempo: -3,
    onApply: (st) => _ir(st, _cartaCofre),
  ),
  efectoDerecha: (s) => Consecuencia(
    deltaTiempo: -3,
    onApply: (st) => _ir(st, _cartaAventurero),
  ),
);

// ── Carta de entrada (única, siempre la primera) ──────────────────────────────

final _cartaEntrada = Carta(
  imagen: 'lib/fotos/puerta principio.jpg',
  texto: 'Entras a la mazmorra.\nLa puerta se cierra detras de ti.',
  opcionIzquierda: 'Entrar por la izquierda',
  opcionDerecha: 'Entrar por la derecha',
  efectoIzquierda: (s) => Consecuencia(
    deltaTiempo: -3,
    onApply: (st) => _ir(st, _cartaPrimerPasillo),
  ),
  efectoDerecha: (s) => Consecuencia(
    deltaTiempo: -3,
    onApply: (st) => _ir(st, _cartaPrimerPasillo),
  ),
);

// ── API pública ───────────────────────────────────────────────────────────────

Carta drawRandomEnemy() =>
    _poolEnemigos[_rng.nextInt(_poolEnemigos.length)];

Carta nextCarta(GameState estado) {
  if (!estado.iniciada) {
    estado.iniciada = true;
    return _cartaEntrada;
  }
  if (estado.cartaPendiente != null) {
    final c = estado.cartaPendiente! as Carta;
    estado.cartaPendiente = null;
    return c;
  }
  return drawRandomEnemy();
}

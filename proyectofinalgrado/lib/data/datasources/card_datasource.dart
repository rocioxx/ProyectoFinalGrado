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

// ── Carta narrativa de victoria ───────────────────────────────────────────────

Carta _victoriaEnemigo({required String texto, required Carta siguiente}) =>
    Carta(
      texto: texto,
      opcionIzquierda: 'Continuar',
      opcionDerecha: 'Continuar',
      efectoIzquierda: (s) =>
          Consecuencia(deltaTiempo: -3, onApply: (st) => _ir(st, siguiente)),
      efectoDerecha: (s) =>
          Consecuencia(deltaTiempo: -3, onApply: (st) => _ir(st, siguiente)),
    );

// ── Sistema de combate por rondas ─────────────────────────────────────────────

Carta _rondaCombate({
  required String nombre,
  required String imagen,
  required double enemyDano,
  required Carta onVictoria,
}) =>
    Carta(
      imagen: imagen,
      saltable: false,
      texto: '',
      textoBuilder: (s) =>
          '$nombre\nVida: ${s.enemyVida!.toInt()} / ${s.enemyMaxVida!.toInt()}',
      opcionIzquierda: 'Ataque rapido',
      opcionDerecha: 'Ataque fuerte',
      efectoIzquierda: (s) {
        final danio = (8 + s.poder * 0.3).clamp(5.0, 20.0);
        s.enemyVida = (s.enemyVida! - danio).clamp(0.0, s.enemyMaxVida!);
        if (s.enemyVida! <= 0) {
          s.enemyVida = null;
          s.enemyMaxVida = null;
          s.defeatedEnemies++;
          return Consecuencia(
            deltaPoder: 5,
            deltaTiempo: -5,
            onApply: (st) => _ir(st, onVictoria),
          );
        }
        return Consecuencia(
          deltaVida: -(enemyDano * 0.6),
          deltaTiempo: -5,
          onApply: (st) => _ir(
            st,
            _rondaCombate(
              nombre: nombre,
              imagen: imagen,
              enemyDano: enemyDano,
              onVictoria: onVictoria,
            ),
          ),
        );
      },
      efectoDerecha: (s) {
        final danio =
            (14 + s.poder * 0.5 + (s.suerte - 50) * 0.2).clamp(8.0, 30.0);
        s.enemyVida = (s.enemyVida! - danio).clamp(0.0, s.enemyMaxVida!);
        if (s.enemyVida! <= 0) {
          s.enemyVida = null;
          s.enemyMaxVida = null;
          s.defeatedEnemies++;
          return Consecuencia(
            deltaPoder: 8,
            deltaTiempo: -5,
            onApply: (st) => _ir(st, onVictoria),
          );
        }
        return Consecuencia(
          deltaVida: -enemyDano,
          deltaTiempo: -8,
          onApply: (st) => _ir(
            st,
            _rondaCombate(
              nombre: nombre,
              imagen: imagen,
              enemyDano: enemyDano,
              onVictoria: onVictoria,
            ),
          ),
        );
      },
    );

Carta _iniciarCombate({
  required String nombre,
  required String imagen,
  required double vida,
  required double dano,
  required Carta onVictoria,
}) =>
    Carta(
      imagen: imagen,
      texto: '$nombre aparece ante ti.\nPreparate para combatir.',
      opcionIzquierda: 'Atacar primero',
      opcionDerecha: 'Esperar y defenderte',
      efectoIzquierda: (s) {
        s.enemyVida = vida;
        s.enemyMaxVida = vida;
        final danioInicial = (10 + s.poder * 0.3).clamp(5.0, 25.0);
        s.enemyVida = (s.enemyVida! - danioInicial).clamp(0.0, vida);
        if (s.enemyVida! <= 0) {
          s.enemyVida = null;
          s.enemyMaxVida = null;
          s.defeatedEnemies++;
          return Consecuencia(
            deltaPoder: 5,
            deltaTiempo: -3,
            onApply: (st) => _ir(st, onVictoria),
          );
        }
        return Consecuencia(
          deltaTiempo: -3,
          onApply: (st) => _ir(
            st,
            _rondaCombate(
              nombre: nombre,
              imagen: imagen,
              enemyDano: dano,
              onVictoria: onVictoria,
            ),
          ),
        );
      },
      efectoDerecha: (s) {
        s.enemyVida = vida;
        s.enemyMaxVida = vida;
        return Consecuencia(
          deltaVida: -(dano * 0.8),
          deltaTiempo: -5,
          onApply: (st) => _ir(
            st,
            _rondaCombate(
              nombre: nombre,
              imagen: imagen,
              enemyDano: dano,
              onVictoria: onVictoria,
            ),
          ),
        );
      },
    );

Carta _encuentroEnemigoCombate(Carta siguiente) {
  final datos = [
    (
      nombre: 'Un esqueleto',
      imagen: 'lib/fotos/esqueleto.jpg',
      vida: 25.0,
      dano: 8.0,
      victoria: 'Los huesos del esqueleto se desmoronan.\nEl camino queda libre.',
    ),
    (
      nombre: 'Un goblin',
      imagen: 'lib/fotos/goblin.jpg',
      vida: 35.0,
      dano: 6.0,
      victoria: 'El goblin chilla y se desploma.\nHas salido victorioso.',
    ),
    (
      nombre: 'Un slime',
      imagen: 'lib/fotos/slime.jpg',
      vida: 20.0,
      dano: 5.0,
      victoria: 'El slime se disuelve en el suelo.\nYa no bloquea el paso.',
    ),
    (
      nombre: 'Una arana',
      imagen: 'lib/fotos/araña.jpg',
      vida: 30.0,
      dano: 7.0,
      victoria: 'La arana cae retorciendose.\nSu veneno ya no te alcanzara.',
    ),
  ];
  final e = datos[_rng.nextInt(datos.length)];
  final cartaVictoria =
      _victoriaEnemigo(texto: e.victoria, siguiente: siguiente);
  return _iniciarCombate(
    nombre: e.nombre,
    imagen: e.imagen,
    vida: e.vida,
    dano: e.dano,
    onVictoria: cartaVictoria,
  );
}

// ── Enemigos simples para la ruleta ──────────────────────────────────────────

final _esqueleto = Carta(
  imagen: 'lib/fotos/esqueleto.jpg',
  texto: 'Un esqueleto te corta el paso.',
  opcionIzquierda: 'Huir',
  opcionDerecha: 'Luchar',
  efectoIzquierda: (_) => const Consecuencia(deltaVida: -5, deltaTiempo: -10),
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
      : const Consecuencia(deltaVida: -12, deltaTiempo: -10),
);

final _slime = Carta(
  imagen: 'lib/fotos/slime.jpg',
  texto: 'Un slime bloquea el pasillo.',
  opcionIzquierda: 'Rodearlo',
  opcionDerecha: 'Atacarlo',
  efectoIzquierda: (_) => const Consecuencia(deltaTiempo: -10),
  efectoDerecha: (s) => _victoria(s, base: 0.50)
      ? const Consecuencia(deltaVida: 5, deltaTiempo: -5)
      : const Consecuencia(deltaPoder: -5, deltaTiempo: -10),
);

final _arana = Carta(
  imagen: 'lib/fotos/araña.jpg',
  texto: 'Una araña gigante desciende del techo.',
  opcionIzquierda: 'Intentar huir',
  opcionDerecha: 'Luchar',
  efectoIzquierda: (_) => const Consecuencia(deltaVida: -2, deltaTiempo: -10),
  efectoDerecha: (s) => _victoria(s, base: 0.60)
      ? const Consecuencia(deltaSuerte: 5, deltaTiempo: -5)
      : const Consecuencia(deltaVida: -12, deltaTiempo: -10),
);

final _poolEnemigos = [_esqueleto, _goblin, _slime, _arana];

// ── Historia de la mazmorra ───────────────────────────────────────────────────

final _cartaVictoriaNigromante = Carta(
  imagen: 'lib/fotos/nigromante.png',
  saltable: false,
  texto: 'El nigromante cae al suelo.\nLa mazmorra tiembla. Has ganado.',
  opcionIzquierda: 'Salir',
  opcionDerecha: 'Salir',
  efectoIzquierda: (s) => Consecuencia(onApply: (st) => st.victoria = true),
  efectoDerecha: (s) => Consecuencia(onApply: (st) => st.victoria = true),
);

late final Carta _cartaCombateNigromante;

final _cartaInicioNigromante = Carta(
  imagen: 'lib/fotos/nigromante.png',
  saltable: false,
  texto: 'El nigromante alza su baston.\nDebes acabar con el.',
  opcionIzquierda: 'Prepararse',
  opcionDerecha: 'Atacar de inmediato',
  efectoIzquierda: (s) {
    s.enemyVida = 60;
    s.enemyMaxVida = 60;
    return Consecuencia(
      deltaTiempo: -3,
      onApply: (st) => _ir(st, _cartaCombateNigromante),
    );
  },
  efectoDerecha: (s) {
    s.enemyVida = 60;
    s.enemyMaxVida = 60;
    s.enemyVida = (s.enemyVida! - 15).clamp(0.0, 60.0);
    return Consecuencia(
      deltaVida: -5,
      deltaTiempo: -3,
      onApply: (st) => _ir(st, _cartaCombateNigromante),
    );
  },
);

final _cartaNigromanteHabla = Carta(
  imagen: 'lib/fotos/nigromante.png',
  saltable: false,
  texto: 'El nigromante rie y te empuja.\nNo hay salida.',
  opcionIzquierda: 'Resistir',
  opcionDerecha: 'Reaccionar',
  efectoIzquierda: (s) => Consecuencia(
    deltaTiempo: -3,
    onApply: (st) => _ir(st, _cartaInicioNigromante),
  ),
  efectoDerecha: (s) => Consecuencia(
    deltaTiempo: -3,
    onApply: (st) => _ir(st, _cartaInicioNigromante),
  ),
);

final _cartaNigromante = Carta(
  imagen: 'lib/fotos/nigromante.png',
  saltable: false,
  texto: 'Ante ti esta el nigromante.\nSenor de esta mazmorra.',
  opcionIzquierda: 'No pelear',
  opcionDerecha: 'Luchar',
  efectoIzquierda: (s) => Consecuencia(
    deltaTiempo: -3,
    onApply: (st) => _ir(st, _cartaNigromanteHabla),
  ),
  efectoDerecha: (s) => Consecuencia(
    deltaTiempo: -3,
    onApply: (st) => _ir(st, _cartaInicioNigromante),
  ),
);

final _cartaPuertaFinal = Carta(
  imagen: 'lib/fotos/puerta final.png',
  texto: 'Una gran puerta bloquea el camino.\nAl otro lado se oye algo.',
  opcionIzquierda: 'Intentar abrirla',
  opcionDerecha: 'Darle una patada',
  efectoIzquierda: (s) {
    s.puertaFinalAlcanzada = true;
    return Consecuencia(
      deltaTiempo: -3,
      onApply: (st) => _ir(st, _cartaNigromante),
    );
  },
  efectoDerecha: (s) {
    s.puertaFinalAlcanzada = true;
    return Consecuencia(
      deltaTiempo: -3,
      onApply: (st) => _ir(st, _cartaNigromante),
    );
  },
);

final _cartaCantimplora = Carta(
  imagen: 'lib/fotos/cantimplora.jpg',
  texto: 'Encuentras una cantimplora en el suelo.\nParece intacta.',
  opcionIzquierda: 'Beber',
  opcionDerecha: 'Cogerla y beber',
  efectoIzquierda: (s) {
    s.cantimploraEncontrada = true;
    final buena = _conSuerte(s, 0.5);
    return Consecuencia(
      deltaVida: buena ? 15 : -10,
      deltaTiempo: buena ? -3 : -8,
      onApply: (st) => _ir(
        st,
        _encuentroEnemigoCombate(_encuentroEnemigoCombate(_cartaPuertaFinal)),
      ),
    );
  },
  efectoDerecha: (s) {
    s.cantimploraEncontrada = true;
    final buena = _conSuerte(s, 0.5);
    return Consecuencia(
      deltaVida: buena ? 15 : -10,
      deltaTiempo: buena ? -3 : -8,
      onApply: (st) => _ir(
        st,
        _encuentroEnemigoCombate(_encuentroEnemigoCombate(_cartaPuertaFinal)),
      ),
    );
  },
);

late final Carta _cartaParedOscura;

final Carta _cartaPasilloOscuro = Carta(
  imagen: 'lib/fotos/pasillooscuro.jpg',
  texto: 'El pasillo esta completamente oscuro.\nNo ves nada.',
  opcionIzquierda: 'Ir a la izquierda',
  opcionDerecha: 'Ir a la derecha',
  efectoIzquierda: (s) => Consecuencia(
    deltaVida: -3,
    deltaTiempo: -5,
    onApply: (st) => _ir(st, _cartaParedOscura),
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
        onApply: (st) =>
            _ir(st, _encuentroEnemigoCombate(_cartaPasilloOscuro)),
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
    onApply: (st) => _ir(st, _encuentroEnemigoCombate(_cartaPasilloOscuro)),
  ),
  efectoDerecha: (s) {
    if (_conSuerte(s, 0.5)) {
      return Consecuencia(
        deltaVida: 20,
        deltaTiempo: -3,
        onApply: (st) =>
            _ir(st, _encuentroEnemigoCombate(_cartaPasilloOscuro)),
      );
    }
    return Consecuencia(
      deltaTiempo: -5,
      onApply: (st) => _ir(st, _cartaMimico),
    );
  },
);

final _cartaCombateAventurero = Carta(
  imagen: 'lib/fotos/aventurero.png',
  texto: 'El aventurero se gira y ataca.\nNo esperabas esto.',
  opcionIzquierda: 'Huir',
  opcionDerecha: 'Luchar',
  efectoIzquierda: (s) => Consecuencia(
    deltaVida: -5,
    deltaTiempo: -10,
    onApply: (st) => _ir(st, _cartaPasilloOscuro),
  ),
  efectoDerecha: (s) {
    if (_victoria(s, base: 0.55)) {
      return Consecuencia(
        deltaPoder: 10,
        deltaTiempo: -5,
        onApply: (st) =>
            _ir(st, _encuentroEnemigoCombate(_cartaPasilloOscuro)),
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
  imagen: 'lib/fotos/aventurero.png',
  texto: 'Un aventurero herido pide ayuda.\nParece en apuros.',
  opcionIzquierda: 'No ayudar',
  opcionDerecha: 'Ayudar',
  efectoIzquierda: (s) {
    s.aventureroEncontrado = true;
    return Consecuencia(
      deltaTiempo: -3,
      onApply: (st) => _ir(st, _cartaCofre),
    );
  },
  efectoDerecha: (s) {
    s.aventureroEncontrado = true;
    return Consecuencia(
      deltaTiempo: -3,
      onApply: (st) => _ir(st, _cartaCombateAventurero),
    );
  },
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

final _cartaEntrada = Carta(
  imagen: 'lib/fotos/puerta principio.jpg',
  saltable: false,
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

// ── Inicialización de referencias tardías ─────────────────────────────────────

void _initLateRefs() {
  _cartaParedOscura = Carta(
    imagen: 'lib/fotos/pasillooscuro.jpg',
    texto: 'Chocas contra la pared.\nAlgo se mueve en la oscuridad.',
    opcionIzquierda: 'Retroceder',
    opcionDerecha: 'Seguir hacia el ruido',
    efectoIzquierda: (s) => Consecuencia(
      deltaVida: -3,
      deltaTiempo: -5,
      onApply: (st) => _ir(st, _cartaPasilloOscuro),
    ),
    efectoDerecha: (s) => Consecuencia(
      deltaVida: -5,
      deltaTiempo: -5,
      onApply: (st) => _ir(st, _encuentroEnemigoCombate(_cartaCantimplora)),
    ),
  );

  _cartaCombateNigromante = Carta(
    imagen: 'lib/fotos/nigromante.png',
    saltable: false,
    texto: '',
    textoBuilder: (s) =>
        'El nigromante combate.\nVida: ${s.enemyVida!.toInt()} / ${s.enemyMaxVida!.toInt()}',
    nota: (s) {
      final pct =
          ((0.35 + (s.suerte - 50) * 0.004) * 100).clamp(0, 100).toInt();
      return 'Desliza a la IZQUIERDA → Golpe normal\n'
          'Ataque seguro. Haces dano moderado y el nigromante te golpea poco.\n'
          '\n'
          'Desliza a la DERECHA → Golpe critico\n'
          'Arriesgado. Con tu suerte (${s.suerte.toInt()}) tienes $pct% de acertar.\n'
          'Si aciertas: haces el doble de dano.\n'
          'Si fallas: el nigromante te golpea muy fuerte.';
    },
    opcionIzquierda: 'Golpe normal',
    opcionDerecha: 'Golpe critico',
    efectoIzquierda: (s) {
      final danio = (10 + s.poder * 0.4).clamp(5.0, 25.0);
      s.enemyVida = (s.enemyVida! - danio).clamp(0.0, s.enemyMaxVida!);
      if (s.enemyVida! <= 0) {
        s.enemyVida = null;
        s.enemyMaxVida = null;
        return Consecuencia(
          deltaTiempo: -5,
          onApply: (st) => _ir(st, _cartaVictoriaNigromante),
        );
      }
      return Consecuencia(
        deltaVida: -8,
        deltaTiempo: -5,
        onApply: (st) => _ir(st, _cartaCombateNigromante),
      );
    },
    efectoDerecha: (s) {
      final exito = _conSuerte(s, 0.35 + (s.suerte - 50) * 0.004);
      if (exito) {
        final danio = (22 + s.poder * 0.6).clamp(15.0, 45.0);
        s.enemyVida = (s.enemyVida! - danio).clamp(0.0, s.enemyMaxVida!);
        if (s.enemyVida! <= 0) {
          s.enemyVida = null;
          s.enemyMaxVida = null;
          return Consecuencia(
            deltaTiempo: -5,
            onApply: (st) => _ir(st, _cartaVictoriaNigromante),
          );
        }
        return Consecuencia(
          deltaVida: -5,
          deltaTiempo: -5,
          onApply: (st) => _ir(st, _cartaCombateNigromante),
        );
      }
      return Consecuencia(
        deltaVida: -15,
        deltaTiempo: -5,
        onApply: (st) => _ir(st, _cartaCombateNigromante),
      );
    },
  );
}

bool _refsInited = false;

void _ensureInited() {
  if (_refsInited) return;
  _refsInited = true;
  _initLateRefs();
}

// ── API pública ───────────────────────────────────────────────────────────────

Carta drawRandomEnemy() => _poolEnemigos[_rng.nextInt(_poolEnemigos.length)];

Carta nextCarta(GameState estado) {
  _ensureInited();
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

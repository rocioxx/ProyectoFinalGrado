import 'dart:math';
import '../../domain/entities/carta.dart';
import '../../domain/entities/consecuencia.dart';
import '../../domain/entities/game_state.dart';

final _rng = Random();

// ── Helpers de navegación ─────────────────────────────────────────────────────

void _ir(GameState s, Carta c) => s.cartaPendiente = c;

// ── Helpers de probabilidad ───────────────────────────────────────────────────

bool _conSuerte(GameState s, double base) =>
    _rng.nextDouble() < (base + (s.suerte - 50) * 0.008).clamp(0.0, 1.0);

// ── Carta narrativa de victoria ───────────────────────────────────────────────

Carta _victoriaEnemigo({
  required String texto,
  required Carta siguiente,
  double deltaSuerte = 0,
}) => Carta(
  texto: texto,
  opcionIzquierda: 'Continuar',
  opcionDerecha: 'Continuar',
  efectoIzquierda: (s) => Consecuencia(
    deltaTiempo: -3,
    deltaSuerte: deltaSuerte,
    onApply: (st) => _ir(st, siguiente),
  ),
  efectoDerecha: (s) => Consecuencia(
    deltaTiempo: -3,
    deltaSuerte: deltaSuerte,
    onApply: (st) => _ir(st, siguiente),
  ),
);

// ── Sistema de combate por rondas ─────────────────────────────────────────────

// ── Sistema de combate unificado (Esquivar / Atacar) ─────────────────────────

Carta _rondaCombate({
  required String nombre,
  required String imagen,
  required double enemyDano,
  required Carta onVictoria,
  bool dodgeFailed = false,
}) => Carta(
  imagen: imagen,
  saltable: false,
  texto: '',
  textoBuilder: (_) => dodgeFailed ? 'No has podido esquivarlo.' : nombre,
  opcionIzquierda: 'Esquivar',
  opcionDerecha: 'Atacar',
  efectoIzquierda: (s) {
    if (_conSuerte(s, 0.5)) {
      return Consecuencia(
        deltaTiempo: -3,
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
    }
    return Consecuencia(
      deltaVida: -enemyDano,
      deltaTiempo: -5,
      onApply: (st) => _ir(
        st,
        _rondaCombate(
          nombre: nombre,
          imagen: imagen,
          enemyDano: enemyDano,
          onVictoria: onVictoria,
          dodgeFailed: true,
        ),
      ),
    );
  },
  efectoDerecha: (s) {
    final danio = (s.poder * 1.0).clamp(5.0, 30.0);
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
      deltaVida: -enemyDano,
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
);

Carta _iniciarCombate({
  required String nombre,
  required String imagen,
  required double vida,
  required double dano,
  required Carta onVictoria,
}) => Carta(
  imagen: imagen,
  texto: '$nombre aparece ante ti.\nPreparate para combatir.',
  opcionIzquierda: 'Esquivar',
  opcionDerecha: 'Atacar',
  efectoIzquierda: (s) {
    s.enemyVida = vida;
    s.enemyMaxVida = vida;
    if (_conSuerte(s, 0.5)) {
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
    }
    return Consecuencia(
      deltaVida: -dano,
      deltaTiempo: -5,
      onApply: (st) => _ir(
        st,
        _rondaCombate(
          nombre: nombre,
          imagen: imagen,
          enemyDano: dano,
          onVictoria: onVictoria,
          dodgeFailed: true,
        ),
      ),
    );
  },
  efectoDerecha: (s) {
    s.enemyVida = vida;
    s.enemyMaxVida = vida;
    final danio = (s.poder * 1.0).clamp(5.0, 30.0);
    s.enemyVida = (s.enemyVida! - danio).clamp(0.0, vida);
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
      deltaVida: -dano,
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

// ── Encuentro aleatorio con enemigo ───────────────────────────────────────────

Carta _encuentroEnemigoCombate(GameState s, Carta siguiente) {
  const datos = [
    (
      nombre: 'Un esqueleto',
      imagen: 'lib/fotos/esqueleto.jpg',
      vida: 25.0,
      dano: 8.0,
      suerte: 0.0,
      victoria:
          'Los huesos del esqueleto se desmoronan.\nEl camino queda libre.',
    ),
    (
      nombre: 'Un goblin',
      imagen: 'lib/fotos/goblin.jpg',
      vida: 35.0,
      dano: 6.0,
      suerte: 0.0,
      victoria: 'El goblin chilla y se desploma.\nHas salido victorioso.',
    ),
    (
      nombre: 'Un slime',
      imagen: 'lib/fotos/slime.jpg',
      vida: 20.0,
      dano: 5.0,
      suerte: 10.0,
      victoria: 'El slime se disuelve en el suelo.\nYa no bloquea el paso.',
    ),
    (
      nombre: 'Una arana',
      imagen: 'lib/fotos/araña.jpg',
      vida: 30.0,
      dano: 7.0,
      suerte: 10.0,
      victoria: 'La arana cae retorciendose.\nSu veneno ya no te alcanzara.',
    ),
  ];

  if (s.enemyQueue.isEmpty) {
    s.enemyQueue = List.generate(datos.length, (i) => i)..shuffle(_rng);
  }
  final idx = s.enemyQueue.removeAt(0);
  final e = datos[idx];
  final cartaVictoria = _victoriaEnemigo(
    texto: e.victoria,
    siguiente: siguiente,
    deltaSuerte: e.suerte,
  );
  return _iniciarCombate(
    nombre: e.nombre,
    imagen: e.imagen,
    vida: e.vida,
    dano: e.dano,
    onVictoria: cartaVictoria,
  );
}

// ── Carta de continuación tras encuentro aleatorio ────────────────────────────

final _cartaContinuar = Carta(
  texto: 'El enemigo ha caido.\nSigues tu camino.',
  opcionIzquierda: 'Continuar',
  opcionDerecha: 'Continuar',
  efectoIzquierda: (_) => const Consecuencia(deltaTiempo: -3),
  efectoDerecha: (_) => const Consecuencia(deltaTiempo: -3),
);

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

// Nigromante: Golpe normal (seguro) / Golpe crítico (arriesgado, basado en suerte)
Carta _nigromanteRonda() => Carta(
  imagen: 'lib/fotos/nigromante.png',
  saltable: false,
  texto: '',
  textoBuilder: (_) => 'El nigromante combate.',
  opcionIzquierda: 'Golpe normal',
  opcionDerecha: 'Golpe critico',
  efectoIzquierda: (s) {
    final danio = (s.poder * 1.0).clamp(5.0, 35.0);
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
      onApply: (st) => _ir(st, _nigromanteRonda()),
    );
  },
  efectoDerecha: (s) {
    final exito = _conSuerte(s, 0.35);
    if (exito) {
      final danio = (s.poder * 2.0).clamp(15.0, 60.0);
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
        onApply: (st) => _ir(st, _nigromanteRonda()),
      );
    }
    return Consecuencia(
      deltaVida: -15,
      deltaTiempo: -5,
      onApply: (st) => _ir(st, _nigromanteRonda()),
    );
  },
);

final _cartaInicioNigromante = Carta(
  imagen: 'lib/fotos/nigromante.png',
  saltable: false,
  texto: 'El nigromante alza su baston.\nDebes acabar con el.',
  nota: (s) {
    final critPct = ((0.35 + (s.suerte - 50) * 0.008) * 100)
        .clamp(0, 100)
        .toInt();
    return 'BATALLA FINAL\n\n'
        'Cada ronda elegiras entre:\n'
        'IZQUIERDA → Golpe normal (seguro)\n'
        '  Haces ${s.poder.toInt()} de daño\n'
        '\n'
        'DERECHA → Golpe critico\n'
        '  Con tu suerte (${s.suerte.toInt()}) tienes $critPct% de acertar\n'
        '  Si fallas te pega más fuerte...';
  },
  opcionIzquierda: 'Prepararse',
  opcionDerecha: 'Atacar de inmediato',
  efectoIzquierda: (s) {
    s.enemyVida = 60;
    s.enemyMaxVida = 60;
    return Consecuencia(
      deltaTiempo: -3,
      onApply: (st) => _ir(st, _nigromanteRonda()),
    );
  },
  efectoDerecha: (s) {
    s.enemyVida = 60;
    s.enemyMaxVida = 60;
    s.enemyVida = (s.enemyVida! - 15).clamp(0.0, 60.0);
    return Consecuencia(
      deltaVida: -5,
      deltaTiempo: -3,
      onApply: (st) => _ir(st, _nigromanteRonda()),
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
  opcionIzquierda: 'No beber',
  opcionDerecha: 'Beber',
  efectoIzquierda: (s) {
    s.cantimploraEncontrada = true;
    return Consecuencia(
      deltaTiempo: -3,
      onApply: (st) => _ir(
        st,
        _encuentroEnemigoCombate(
          st,
          _encuentroEnemigoCombate(st, _cartaPuertaFinal),
        ),
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
        _encuentroEnemigoCombate(
          st,
          _encuentroEnemigoCombate(st, _cartaPuertaFinal),
        ),
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
  efectoDerecha: (s) => Consecuencia(
    deltaTiempo: -3,
    onApply: (st) => _ir(
      st,
      _iniciarCombate(
        nombre: 'El mimico',
        imagen: 'lib/fotos/mimico.jpg',
        vida: 35,
        dano: 12,
        onVictoria: _victoriaEnemigo(
          texto: 'El mimico se desmorona.\nEl cofre era una trampa.',
          siguiente: _cartaPasilloOscuro,
        ),
      ),
    ),
  ),
);

final _cartaCofre = Carta(
  imagen: 'lib/fotos/cofre cerrado.jpg',
  texto: 'Hay un cofre en el pasillo.\nParece cerrado.',
  opcionIzquierda: 'Ignorarlo',
  opcionDerecha: 'Abrirlo',
  efectoIzquierda: (s) => Consecuencia(
    deltaTiempo: -5,
    onApply: (st) => _ir(st, _encuentroEnemigoCombate(st, _cartaPasilloOscuro)),
  ),
  efectoDerecha: (s) {
    if (_conSuerte(s, s.abGroup == 'B' ? 0.70 : 0.50)) {
      // Poción: random entre quitar poder o dar suerte
      final esSuerte = _rng.nextBool();
      return Consecuencia(
        deltaSuerte: esSuerte ? 10 : 0,
        deltaPoder: esSuerte ? 0 : -8,
        deltaTiempo: -3,
        onApply: (st) =>
            _ir(st, _encuentroEnemigoCombate(st, _cartaPasilloOscuro)),
      );
    }
    return Consecuencia(
      deltaTiempo: -3,
      onApply: (st) => _ir(st, _cartaMimico),
    );
  },
);

// Victoria del aventurero: otorga vida y continua con un encuentro enemigo
final _cartaVictoriaAventurero = Carta(
  texto: 'Has derrotado al aventurero.\nSigues adelante.',
  opcionIzquierda: 'Continuar',
  opcionDerecha: 'Continuar',
  efectoIzquierda: (s) => Consecuencia(
    deltaVida: 10,
    deltaTiempo: -5,
    onApply: (st) => _ir(st, _encuentroEnemigoCombate(st, _cartaPasilloOscuro)),
  ),
  efectoDerecha: (s) => Consecuencia(
    deltaVida: 10,
    deltaTiempo: -5,
    onApply: (st) => _ir(st, _encuentroEnemigoCombate(st, _cartaPasilloOscuro)),
  ),
);

final _cartaCombateAventurero = _iniciarCombate(
  nombre: 'El aventurero',
  imagen: 'lib/fotos/aventurero.png',
  vida: 30,
  dano: 8,
  onVictoria: _cartaVictoriaAventurero,
);

final _cartaAventurero = Carta(
  imagen: 'lib/fotos/aventurero.png',
  texto: 'Un aventurero herido pide ayuda.\nParece en apuros.',
  opcionIzquierda: 'No ayudar',
  opcionDerecha: 'Ayudar',
  efectoIzquierda: (s) {
    s.aventureroEncontrado = true;
    return Consecuencia(deltaTiempo: -3, onApply: (st) => _ir(st, _cartaCofre));
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
  efectoIzquierda: (s) =>
      Consecuencia(deltaTiempo: -3, onApply: (st) => _ir(st, _cartaCofre)),
  efectoDerecha: (s) =>
      Consecuencia(deltaTiempo: -3, onApply: (st) => _ir(st, _cartaAventurero)),
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
      onApply: (st) => _ir(st, _encuentroEnemigoCombate(st, _cartaCantimplora)),
    ),
  );
}

bool _refsInited = false;

void _ensureInited() {
  if (_refsInited) return;
  _refsInited = true;
  _initLateRefs();
}

// ── API pública ───────────────────────────────────────────────────────────────

Carta drawRandomEnemy() {
  const datos = [
    (
      nombre: 'Esqueleto guerrero',
      imagen: 'lib/fotos/esqueleto.jpg',
      vida: 25.0,
      dano: 8.0,
      suerte: 0.0,
      victoria:
          'Los huesos del esqueleto se desmoronan.\nEl camino queda libre',
    ),
    (
      nombre: 'Goblin ',
      imagen: 'lib/fotos/goblin.jpg',
      vida: 35.0,
      dano: 6.0,
      suerte: 0.0,
      victoria: 'El goblin chilla y se desploma.\nHas salido victorioso',
    ),
    (
      nombre: 'Slime',
      imagen: 'lib/fotos/slime.jpg',
      vida: 20.0,
      dano: 5.0,
      suerte: 10.0,
      victoria: 'El slime se disuelve en el suelo.\nYa no bloquea el paso',
    ),
    (
      nombre: 'Araña gigante',
      imagen: 'lib/fotos/araña.jpg',
      vida: 30.0,
      dano: 7.0,
      suerte: 10.0,
      victoria: 'La araña cae retorciendose.\nSu veneno ya no te alcanzara',
    ),
  ];
  final e = datos[_rng.nextInt(datos.length)];
  return _iniciarCombate(
    nombre: e.nombre,
    imagen: e.imagen,
    vida: e.vida,
    dano: e.dano,
    onVictoria: _victoriaEnemigo(
      texto: e.victoria,
      siguiente: _cartaContinuar,
      deltaSuerte: e.suerte,
    ),
  );
}

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

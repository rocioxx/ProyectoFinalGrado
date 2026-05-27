import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/ads/ad_service.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../domain/entities/carta.dart';
import '../../domain/usecases/apply_decision_usecase.dart';
import '../../domain/usecases/draw_card_usecase.dart';
import '../../domain/usecases/skip_card_usecase.dart';
import '../cubits/game_cubit.dart';
import '../cubits/game_ui_state.dart';
import '../widgets/missions_panel.dart';
import '../widgets/scenario_text.dart';
import '../widgets/stats_panel.dart';
import '../widgets/swipe_card.dart';
import 'game_over_screen.dart';
import 'options_screen.dart';
import 'win_screen.dart';

class CardScreen extends StatelessWidget {
  const CardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repo = GameRepositoryImpl();
        return GameCubit(
          drawCard: DrawCardUseCase(repo),
          applyDecision: ApplyDecisionUseCase(repo),
          skipCard: SkipCardUseCase(repo),
        );
      },
      child: const _CardView(),
    );
  }
}

// ── View (animations + gestures) ─────────────────────────────────────────────

enum _Phase { idle, exiting, entering, returning, spinning }

class _CardView extends StatefulWidget {
  const _CardView();

  @override
  State<_CardView> createState() => _CardViewState();
}

class _CardViewState extends State<_CardView> with TickerProviderStateMixin {
  late Carta _cartaActual;
  final _adService = AdService();
  int _ruletasRestantes = 2;

  bool _notaVisible = true;

  // ── Overlay de consecuencias ──────────────────────────────────────────────
  List<({String texto, Color color})> _consecuencias = [];
  double _consecuenciasOpacidad = 0.0;

  void _mostrarResultado(double dv, double dp, double ds, double dt) {
    final items = <({String texto, Color color})>[];
    if (dv.abs() >= 0.5) {
      items.add((
        texto: '${dv > 0 ? '+' : ''}${dv.round()} Vida',
        color: dv > 0 ? const Color(0xFF6BCB77) : const Color(0xFFE8706A),
      ));
    }
    if (dp.abs() >= 0.5) {
      items.add((
        texto: '${dp > 0 ? '+' : ''}${dp.round()} Poder',
        color: dp > 0 ? const Color(0xFF78C4E0) : const Color(0xFFAAAAAA),
      ));
    }
    if (ds.abs() >= 0.5) {
      items.add((
        texto: '${ds > 0 ? '+' : ''}${ds.round()} Suerte',
        color: ds > 0 ? const Color(0xFFD4AF37) : const Color(0xFFAAAAAA),
      ));
    }
    if (dt.abs() >= 0.5) {
      items.add((
        texto: '${dt > 0 ? '+' : ''}${dt.round()} Tiempo',
        color: const Color(0xFFB0A080),
      ));
    }
    if (items.isEmpty) return;

    setState(() {
      _consecuencias = items;
      _consecuenciasOpacidad = 1.0;
    });
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      setState(() => _consecuenciasOpacidad = 0.0);
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() => _consecuencias = []);
    });
  }

  double _screenHeight = 1;
  double _screenWidth = 1;
  double _x = 0;
  // Empieza en entering para que el botón aparezca desactivado al inicio
  _Phase _phase = _Phase.entering;

  late final AnimationController _exitCtrl;
  late final AnimationController _enterCtrl;
  late final AnimationController _returnCtrl;
  late final AnimationController _spinCtrl;
  late final Animation<double> _enterScale;
  late final Animation<double> _enterOpacity;
  late final Animation<double> _enterY;
  // 4 vueltas en el eje Y (giro horizontal) que decelera — efecto ruleta
  late final Animation<double> _spinAnim;
  late Animation<Offset> _exitOffset;
  late Animation<double> _exitRot;
  late Animation<double> _returnAnim;

  double _threshold = 80.0;

  @override
  void initState() {
    super.initState();
    final initialState = context.read<GameCubit>().state as GamePlaying;
    _cartaActual = initialState.cartaActual;

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _enterScale = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutBack),
    );
    _enterOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut),
    );
    _enterY = Tween(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic),
    );
    _returnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // 4 vueltas completas en Y desacelerando
    _spinAnim = Tween<double>(begin: 0, end: 8 * pi).animate(
      CurvedAnimation(parent: _spinCtrl, curve: Curves.easeOut),
    );

    // Inicializar AdMob y precargar anuncio (solo Android)
    _adService.init().then((_) => _adService.load());

    // Animación de entrada al cargar la pantalla por primera vez
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _enterCtrl.forward(from: 0);
      if (!mounted) return;
      _enterCtrl.reset();
      setState(() => _phase = _Phase.idle);
    });
  }

  @override
  void dispose() {
    _exitCtrl.dispose();
    _enterCtrl.dispose();
    _returnCtrl.dispose();
    _spinCtrl.dispose();
    super.dispose();
  }

  Future<void> _returnToCenter() async {
    _returnAnim = Tween<double>(begin: _x, end: 0).animate(
      CurvedAnimation(parent: _returnCtrl, curve: Curves.easeOutBack),
    );
    setState(() => _phase = _Phase.returning);
    await _returnCtrl.forward(from: 0);
    _returnCtrl.reset();
    setState(() {
      _x = 0;
      _phase = _Phase.idle;
    });
  }

  Future<void> _swipe() async {
    final eligioIzquierda = _x < 0;
    final cartaActual = _cartaActual;
    final cubit = context.read<GameCubit>();

    // Capturar stats antes de aplicar la decisión
    final gs0 = (cubit.state as GamePlaying).gameState;
    final vida0 = gs0.vida;
    final poder0 = gs0.poder;
    final suerte0 = gs0.suerte;
    final tiempo0 = gs0.tiempo;

    final dir = _x.sign;
    final startX = _x;
    final startRot = (startX / (_screenWidth * 0.6)).clamp(-1.0, 1.0) * 0.3;

    _exitOffset = Tween<Offset>(
      begin: Offset(startX, 0),
      end: Offset(startX + dir * _screenWidth * 2, 0),
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));

    _exitRot = Tween<double>(
      begin: startRot,
      end: dir * 0.5,
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));

    setState(() => _phase = _Phase.exiting);
    await _exitCtrl.forward(from: 0);
    _exitCtrl.reset();

    cubit.applyDecision(cartaActual, eligioIzquierda);

    if (!mounted) return;

    final newState = cubit.state;

    if (newState is GameVictoryState) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WinScreen()),
      );
      return;
    }

    if (newState is GameOverState) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GameOverScreen()),
      );
      return;
    }

    final playing = newState as GamePlaying;
    final gs1 = playing.gameState;
    _mostrarResultado(
      gs1.vida - vida0,
      gs1.poder - poder0,
      gs1.suerte - suerte0,
      gs1.tiempo - tiempo0,
    );

    setState(() {
      _x = 0;
      _phase = _Phase.entering;
      _cartaActual = playing.cartaActual;
      _notaVisible = true;
    });

    await _enterCtrl.forward(from: 0);
    _enterCtrl.reset();
    setState(() => _phase = _Phase.idle);
  }

  void _onRuletaTap() {
    _adService.show(
      onRewarded: _usarRuleta,
      onNotReady: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cargando anuncio, inténtalo en un momento...'),
          duration: Duration(seconds: 2),
        ),
      ),
    );
  }

  Future<void> _usarRuleta() async {
    final cubit = context.read<GameCubit>();

    setState(() => _ruletasRestantes--);

    // Giro horizontal en el eje Y
    setState(() => _phase = _Phase.spinning);
    await _spinCtrl.forward(from: 0);
    _spinCtrl.reset();

    cubit.skipCard();

    if (!mounted) return;

    final newState = cubit.state as GamePlaying;
    setState(() {
      _x = 0;
      _phase = _Phase.entering;
      _cartaActual = newState.cartaActual;
      _notaVisible = true;
    });

    await _enterCtrl.forward(from: 0);
    _enterCtrl.reset();
    setState(() => _phase = _Phase.idle);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _screenWidth = size.width;
    _screenHeight = size.height;
    _threshold = (_screenWidth * 0.20).clamp(60.0, 100.0);
    final cardOffsetY = _screenHeight * 0.155;
    final hPad = _screenWidth * 0.08;

    final card = SwipeCard(imagen: _cartaActual.imagen);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 29, 20, 13),
      body: Stack(
        children: [
          Center(
            child: GestureDetector(
              onPanUpdate: _phase != _Phase.idle
                  ? null
                  : (d) => setState(() => _x += d.delta.dx),
              onPanEnd: _phase != _Phase.idle
                  ? null
                  : (_) =>
                      _x.abs() >= _threshold ? _swipe() : _returnToCenter(),
              child: switch (_phase) {
                _Phase.idle => Transform.translate(
                    offset: Offset(_x, cardOffsetY),
                    child: Transform.rotate(
                      angle:
                          (_x / (_screenWidth * 0.6)).clamp(-1.0, 1.0) * 0.3,
                      child: card,
                    ),
                  ),
                _Phase.exiting => AnimatedBuilder(
                    animation: _exitCtrl,
                    child: card,
                    builder: (_, child) => Transform.translate(
                      offset: _exitOffset.value + Offset(0, cardOffsetY),
                      child: Transform.rotate(
                        angle: _exitRot.value,
                        child: child,
                      ),
                    ),
                  ),
                _Phase.returning => AnimatedBuilder(
                    animation: _returnCtrl,
                    child: card,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(_returnAnim.value, cardOffsetY),
                      child: Transform.rotate(
                        angle: (_returnAnim.value / (_screenWidth * 0.6))
                                .clamp(-1.0, 1.0) *
                            0.3,
                        child: child,
                      ),
                    ),
                  ),
                _Phase.entering => AnimatedBuilder(
                    animation: _enterCtrl,
                    child: card,
                    builder: (_, child) => Opacity(
                      opacity: _enterOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _enterY.value + cardOffsetY),
                        child: Transform.scale(
                          scale: _enterScale.value,
                          child: child,
                        ),
                      ),
                    ),
                  ),
                // Giro horizontal: rotación en el eje Y con perspectiva
                _Phase.spinning => AnimatedBuilder(
                    animation: _spinCtrl,
                    child: card,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, cardOffsetY),
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(_spinAnim.value),
                        alignment: Alignment.center,
                        child: child,
                      ),
                    ),
                  ),
              },
            ),
          ),

          BlocBuilder<GameCubit, GameUiState>(
            buildWhen: (_, s) => s is GamePlaying,
            builder: (_, state) {
              final gs = (state as GamePlaying).gameState;
              return Stack(
                children: [
                  if (gs.enemyVida != null)
                    Positioned(
                      left: hPad,
                      right: hPad,
                      top: _screenHeight * 0.42,
                      child: _EnemyHealthBar(
                        vida: gs.enemyVida!,
                        maxVida: gs.enemyMaxVida!,
                      ),
                    ),
                  Positioned(
                    left: hPad,
                    right: hPad,
                    top: _screenHeight * 0.33,
                    child: ScenarioText(
                      carta: _cartaActual,
                      gameState: gs,
                      dragX: _phase == _Phase.idle ? _x : 0,
                      threshold: _threshold,
                    ),
                  ),
                  if (_cartaActual.nota != null && _notaVisible)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: hPad),
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                            decoration: BoxDecoration(
                              color: const Color(0xF01A1208),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFD4AF37), width: 1.5),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _notaVisible = false),
                                    child: const Icon(
                                      Icons.close,
                                      color: Color(0xFFD4AF37),
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _cartaActual.nota!.call(gs),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Inconsolata',
                                    fontSize: 14,
                                    color: Color(0xFFD4AF37),
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: SafeArea(
                      bottom: false,
                      child: StatsPanel(
                        vida: gs.vida,
                        poder: gs.poder,
                        tiempo: gs.tiempo,
                        suerte: gs.suerte,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const Positioned(top: 48, right: 16, child: MissionsPanel()),

          // ── Overlay de consecuencias ───────────────────────────────────
          if (_consecuencias.isNotEmpty)
            Positioned(
              left: hPad,
              right: hPad,
              top: _screenHeight * 0.28,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: _consecuenciasOpacidad,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xDD1A1208),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: const Color(0x66D4AF37), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: _consecuencias
                        .expand((e) => [
                              Text(
                                e.texto,
                                style: TextStyle(
                                  fontFamily: 'Inconsolata',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: e.color,
                                ),
                              ),
                              if (e != _consecuencias.last)
                                const Text(
                                  '  ·  ',
                                  style: TextStyle(
                                    fontFamily: 'Inconsolata',
                                    fontSize: 14,
                                    color: Color(0x88D4AF37),
                                  ),
                                ),
                            ])
                        .toList(),
                  ),
                ),
              ),
            ),

          // ── Botón ruleta ───────────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _RuletaButton(
                enabled: _phase == _Phase.idle &&
                    _ruletasRestantes > 0 &&
                    _cartaActual.saltable,
                restantes: _ruletasRestantes,
                onTap: _onRuletaTap,
              ),
            ),
          ),

          // ── Botón opciones ─────────────────────────────────────────────
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OptionsScreen()),
              ),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A1208),
                  border: Border.all(color: const Color(0x88D4AF37), width: 1.5),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: Color(0xFFD4AF37),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botón ruleta ──────────────────────────────────────────────────────────────

class _RuletaButton extends StatelessWidget {
  const _RuletaButton({
    required this.enabled,
    required this.restantes,
    required this.onTap,
  });

  final bool enabled;
  final int restantes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.35,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1208),
                border: Border.all(
                  color: enabled ? const Color(0xFFD4AF37) : Colors.grey,
                  width: 1.5,
                ),
                boxShadow: enabled
                    ? const [
                        BoxShadow(
                          color: Color(0x66D4AF37),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.shuffle_rounded,
                color: enabled ? const Color(0xFFD4AF37) : Colors.grey,
                size: 22,
              ),
            ),
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: restantes > 0 ? const Color(0xFFD4AF37) : Colors.grey,
                ),
                child: Center(
                  child: Text(
                    '$restantes',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1208),
                      fontFamily: 'Inconsolata',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Barra de vida del enemigo ─────────────────────────────────────────────────

class _EnemyHealthBar extends StatelessWidget {
  const _EnemyHealthBar({required this.vida, required this.maxVida});

  final double vida;
  final double maxVida;

  @override
  Widget build(BuildContext context) {
    final pct = (vida / maxVida).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Vida enemigo: ${vida.toInt()} / ${maxVida.toInt()}',
          style: const TextStyle(
            fontFamily: 'Inconsolata',
            fontSize: 13,
            color: Color(0xFFE8706A),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: const Color(0x44E8706A),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFE8706A)),
          ),
        ),
      ],
    );
  }
}


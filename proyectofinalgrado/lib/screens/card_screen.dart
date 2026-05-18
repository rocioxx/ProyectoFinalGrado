import 'package:flutter/material.dart';
import '../widgets/swipe_card.dart';
import '../widgets/stats_panel.dart';
import '../widgets/scenario_text.dart';
import '../models/carta.dart';
import '../models/game_state.dart';
import '../state/game_controller.dart';
import '../data/card_pool.dart';
import '../widgets/missions_panel.dart';
import 'game_over_screen.dart';

enum _Phase { idle, exiting, entering, returning }

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> with TickerProviderStateMixin {
  final _state = GameState();
  late Carta _cartaActual;

  double _screenHeight = 1;
  double _x = 0;
  _Phase _phase = _Phase.idle;
  double _screenWidth = 1;

  late final AnimationController _exitCtrl;
  late final AnimationController _enterCtrl;
  late final Animation<double> _enterScale;
  late final Animation<double> _enterOpacity;
  late final Animation<double> _enterY;
  late Animation<Offset> _exitOffset;
  late Animation<double> _exitRot;
  late final AnimationController _returnCtrl;
  late Animation<double> _returnAnim;

  static const _threshold = 80.0;

  @override
  void initState() {
    super.initState();
    _cartaActual = nextCarta(_state);

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
  }

  @override
  void dispose() {
    _exitCtrl.dispose();
    _enterCtrl.dispose();
    _returnCtrl.dispose();
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

    aplicarDecision(_state, cartaActual, eligioIzquierda);

    if (_state.vida <= 0 ||
        _state.suerte <= 0 ||
        _state.tiempo <= 0 ||
        _state.poder <= 0) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GameOverScreen()),
        );
      }
      return;
    }

    setState(() {
      _x = 0;
      _phase = _Phase.entering;
      _cartaActual = nextCarta(_state); // siguiente carta ya preparada
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

    const card = SwipeCard();

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
                  offset: Offset(_x, 130.0),
                  child: Transform.rotate(
                    angle: (_x / (_screenWidth * 0.6)).clamp(-1.0, 1.0) * 0.3,
                    child: card,
                  ),
                ),
                _Phase.exiting => AnimatedBuilder(
                  animation: _exitCtrl,
                  child: card,
                  builder: (_, child) => Transform.translate(
                    offset: _exitOffset.value + const Offset(0, 130.0),
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
                    offset: Offset(_returnAnim.value, 130.0),
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
                      offset: Offset(0, _enterY.value + 130.0),
                      child: Transform.scale(
                        scale: _enterScale.value,
                        child: child,
                      ),
                    ),
                  ),
                ),
              },
            ),
          ),

          Positioned(
            left: 32,
            right: 32,
            top: _screenHeight * 0.33,
            child: ScenarioText(
              carta: _cartaActual,
              dragX: _phase == _Phase.idle ? _x : 0,
              threshold: _threshold,
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: StatsPanel(
              vida: _state.vida,
              poder: _state.poder,
              tiempo: _state.tiempo,
              suerte: _state.suerte,
            ),
          ),

          Positioned(top: 48, right: 16, child: const MissionsPanel()),
        ],
      ),
    );
  }
}

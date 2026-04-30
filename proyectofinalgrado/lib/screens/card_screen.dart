import 'package:flutter/material.dart';
import '../widgets/swipe_card.dart';
import '../widgets/stats_panel.dart';
import '../state/stats_controller.dart';

// Las tres fases posibles de la carta en cada momento:
// - idle    → el usuario puede arrastrarla libremente
// - exiting → la carta está saliendo volando tras el swipe
// - entering → la carta nueva está apareciendo en pantalla
enum _Phase { idle, exiting, entering }

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> with TickerProviderStateMixin {
  final _stats = StatsController(vida: 0.5, experiencia: 0.9, nivel: 0.9, fuerza: 0.9);
  // Desplazamiento horizontal acumulado mientras el usuario arrastra
  double _x = 0;
  // Fase actual de la carta (controla qué se muestra en el build)
  _Phase _phase = _Phase.idle;
  // Ancho de pantalla guardado en build() para usarlo en _swipe(),
  // donde no tenemos acceso directo a BuildContext
  double _screenWidth = 1;
  // Controlador de la animación de salida (la carta vuela hacia un lado)
  late final AnimationController _exitCtrl;
  // Controlador de la animación de entrada (la carta nueva aparece)
  late final AnimationController _enterCtrl;
  // Animaciones de entrada: escala, opacidad y posición vertical
  // Se crean una sola vez en initState() porque sus extremos no cambian
  late final Animation<double> _enterScale;
  late final Animation<double> _enterOpacity;
  late final Animation<double> _enterY;
  // Animaciones de salida: posición y rotación
  // Se recrean en cada swipe porque dependen de _x en ese instante
  late Animation<Offset> _exitOffset;
  late Animation<double> _exitRot;
  // Distancia mínima en píxeles para que se considere un swipe válido
  static const _threshold = 100.0;

  @override
  void initState() {
    super.initState();

    // Controlador de salida: la carta tarda 300 ms en irse
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Controlador de entrada: la carta nueva tarda 450 ms en aparecer
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // La carta nueva crece de 80 % a 100 % con un leve rebote al final
    _enterScale = Tween(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutBack));

    // La carta nueva pasa de transparente a completamente visible
    _enterOpacity = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));

    // La carta nueva sube 40 píxeles desde abajo hasta su posición final
    _enterY = Tween(
      begin: 40.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    // Siempre hay que liberar los controladores para evitar fugas de memoria
    _exitCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  // Ejecuta la secuencia completa: salida de la carta actual + entrada de la nueva.
  // Es async para poder encadenar las dos animaciones con await.
  Future<void> _swipe() async {
    final dir = _x.sign; // +1 si va a la derecha, -1 si va a la izquierda
    final startX = _x; // posición desde la que empieza a volar
    final startRot = (startX / (_screenWidth * 0.6)).clamp(-1.0, 1.0) * 0.3;

    // La carta vuela desde su posición actual hasta fuera de la pantalla,
    // con un pequeño movimiento hacia arriba (-50 px en Y)
    _exitOffset = Tween<Offset>(
      begin: Offset(startX, 0),
      end: Offset(startX + dir * _screenWidth * 2, 0),
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));

    // La rotación parte del ángulo actual y se exagera en la dirección del swipe
    _exitRot = Tween<double>(
      begin: startRot,
      end: dir * 0.5,
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));

    // ── Fase 1: la carta sale volando ────────────────────────────────────────
    setState(() => _phase = _Phase.exiting);
    await _exitCtrl.forward(from: 0); // esperamos a que termine la salida
    _exitCtrl.reset(); // dejamos el controlador listo para el próximo swipe

    // ── Fase 2: la carta nueva entra en pantalla ─────────────────────────────
    setState(() {
      _x = 0; // reseteamos la posición al centro
      _phase = _Phase.entering;
    });
    await _enterCtrl.forward(from: 0); // esperamos a que termine la entrada
    _enterCtrl.reset();

    // Volvemos a idle para que el usuario pueda arrastrar de nuevo
    setState(() => _phase = _Phase.idle);
  }

  @override
  Widget build(BuildContext context) {
    // Guardamos el ancho aquí porque los callbacks no tienen BuildContext
    _screenWidth = MediaQuery.sizeOf(context).width;

    // SwipeCard es const: Flutter lo reutiliza sin reconstruirlo
    const card = SwipeCard();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          Center(
            child: GestureDetector(
              //mientras hay animación, desactivamos el gesto poniendo null
              onPanUpdate: _phase != _Phase.idle
                  ? null
                  : (d) => setState(() => _x += d.delta.dx),

              //al soltar el dedo: swipe si superó el umbral, volver al centro si no
              onPanEnd: _phase != _Phase.idle
                  ? null
                  : (_) => _x.abs() >= _threshold
                        ? _swipe()
                        : setState(() => _x = 0),

              //mostramos un widget distinto según la fase actual
              child: switch (_phase) {
                //cambio de fase de la carta

                //reposo: la carta sigue al dedo y rota ligeramente
                _Phase.idle => Transform.translate(
                  offset: Offset(_x, 130.0),
                  child: Transform.rotate(
                    //La rotación máxima es ±0.3 rad (~17°) al llegar al borde
                    angle: (_x / (_screenWidth * 0.6)).clamp(-1.0, 1.0) * 0.3,
                    child: card,
                  ),
                ),

                //salida: la carta vuela con rotación

                // Busca esto dentro del switch (_phase)
                _Phase.exiting => AnimatedBuilder(
                  animation: _exitCtrl,
                  child: card,
                  builder: (_, child) => Transform.translate(
                    // Usamos el offset completo de la animación de salida
                    // Sumamos 175.0 al eje Y para mantener la altura base que elegiste
                    offset: _exitOffset.value + const Offset(0, 130.0),
                    child: Transform.rotate(
                      angle: _exitRot.value,
                      child: child,
                    ),
                  ),
                ),

                //entrada: la carta nueva sube, crece y aparece
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
              }, //
            ),
          ),

          // Panel de estadísticas en la parte inferior
          Align(
            alignment: Alignment.topCenter,
            child: StatsPanel(
              vida: _stats.vida,
              experiencia: _stats.experiencia,
              nivel: _stats.nivel,
              fuerza: _stats.fuerza,
            ),
          ),
        ],
      ),
    );
  }
}

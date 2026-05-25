import 'package:flutter/material.dart';

class MissionsPanel extends StatefulWidget {
  const MissionsPanel({super.key});

  @override
  State<MissionsPanel> createState() => _MissionsPanelState();
}

class _MissionsPanelState extends State<MissionsPanel>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;

  static const _misiones = [
    _Mision(titulo: 'Derrotar al jefe final', completada: false),
    _Mision(titulo: 'Recoger 1 poción', completada: false),
    _Mision(titulo: 'Explorar la mazmorra', completada: false),
    _Mision(titulo: 'Hablar con el herrero', completada: false),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _toggle,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: Color(0xFFD4AF37),
              size: 24,
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 230,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(14, 12, 14, 6),
                          child: Text(
                            'Misiones',
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const Divider(color: Color(0xFF333333), height: 1),
                        ..._misiones.map((m) => _MisionTile(mision: m)),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _MisionTile extends StatelessWidget {
  const _MisionTile({required this.mision});
  final _Mision mision;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Icon(
            mision.completada
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: mision.completada ? const Color(0xFF5B9BD5) : Colors.white38,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mision.titulo,
              style: TextStyle(
                color: mision.completada ? Colors.white38 : Colors.white70,
                fontSize: 12,
                decoration: mision.completada
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Mision {
  const _Mision({required this.titulo, required this.completada});
  final String titulo;
  final bool completada;
}

import 'package:flutter/material.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  double _x = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: GestureDetector(
          // Cada vez que el dedo se mueve, sumamos el desplazamiento a _x
          onPanUpdate: (details) {
            setState(() {
              _x += details.delta.dx;
            });
          },
          child: Transform.translate(
            offset: Offset(_x, 0),
            child: Container(
              width: 200,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: const Center(
                child: Text('🃏', style: TextStyle(fontSize: 64)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

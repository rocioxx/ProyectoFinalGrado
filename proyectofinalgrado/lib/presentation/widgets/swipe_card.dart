import 'package:flutter/material.dart';

class SwipeCard extends StatelessWidget {
  const SwipeCard({super.key, this.imagen});

  final String? imagen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      height: 400,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 10)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: imagen != null
              ? Image.asset(imagen!, fit: BoxFit.cover)
              : const ColoredBox(color: Color(0xFF1A1208)),
        ),
      ),
    );
  }
}

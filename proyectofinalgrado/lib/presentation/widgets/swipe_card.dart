import 'package:flutter/material.dart';

class SwipeCard extends StatelessWidget {
  const SwipeCard({super.key, this.imagen});

  final String? imagen;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = (size.width * 0.87).clamp(260.0, 360.0);
    final h = (size.height * 0.46).clamp(280.0, 420.0);

    return SizedBox(
      width: w,
      height: h,
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

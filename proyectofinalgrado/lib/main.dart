import 'package:flutter/material.dart';
import 'screens/card_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key}); //constructor de la clase padre

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CardScreen());
  }
}

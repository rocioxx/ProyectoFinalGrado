import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/screens/play_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qatjobztluikjbapbvgv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFhdGpvYnp0bHVpa2piYXBidmd2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkyMDU0MjcsImV4cCI6MjA5NDc4MTQyN30.6ogTjmDSBNifaxLWCFMXo2bpv3fXzGg-3h2e0mrvDj8',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: PlayScreen());
  }
}

import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsService {
  AnalyticsService({required this.sessionId, required this.abGroup});

  final String sessionId;
  final String abGroup;
  final _db = Supabase.instance.client.from('eventos');

  static String generateSessionId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(99999);
    return '${ts}_$rand';
  }

  static String assignAbGroup() => Random().nextBool() ? 'A' : 'B';

  Future<void> _log(String tipo,
      [Map<String, dynamic> datos = const {}]) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    try {
      await _db.insert({
        'tipo': tipo,
        'datos': datos,
        'user_id': userId,
        'session_id': sessionId,
        'ab_group': abGroup,
      });
    } catch (e, st) {
      print('Analytics ERROR ($tipo): $e\n$st');
    }
  }

  Future<void> gameStarted() => _log('game_started');

  Future<void> cardSwiped({
    required String carta,
    required String direccion,
  }) =>
      _log('card_swiped', {'carta': carta, 'direccion': direccion});

  Future<void> ruletaUsed() => _log('ruleta_used');

  Future<void> combatStarted(String enemigo) =>
      _log('combat_started', {'enemigo': enemigo});

  Future<void> gameOver({
    required String statMuerta,
    required Map<String, dynamic> stats,
  }) =>
      _log('game_over', {'stat_muerta': statMuerta, ...stats});

  Future<void> gameWon(Map<String, dynamic> stats) => _log('game_won', stats);
}

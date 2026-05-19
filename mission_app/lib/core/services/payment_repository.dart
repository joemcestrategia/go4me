import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class PaymentRepository {
  final SupabaseClient _client;

  PaymentRepository(this._client);

  String get _supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String currency,
    String? missionaryId,
    String? donorId,
    String? projectId,
    bool isRecurring = false,
    bool isAnonymous = false,
  }) async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) throw Exception('Usuário não autenticado');

      final response = await http.post(
        Uri.parse('$_supabaseUrl/functions/v1/stripe-payment'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'missionary_id': missionaryId,
          'donor_id': donorId,
          'project_id': projectId,
          'is_recurring': isRecurring,
          'is_anonymous': isAnonymous,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> presentPaymentSheet(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Go4Me Missions',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final client = Supabase.instance.client;
  return PaymentRepository(client);
});

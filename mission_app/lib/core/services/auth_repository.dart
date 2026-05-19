import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go4me/core/models/user_profile.dart';
import 'package:go4me/core/services/supabase_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(SupabaseService.client);
});

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  /// Stream que observa as mudanças de estado de autenticação
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Usuário atual (nativo do Supabase Auth)
  User? get currentUser => _client.auth.currentUser;

  /// Login com e-mail e senha
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Cadastro de novo usuário
  /// O perfil é criado automaticamente via Trigger no Postgres (supabase_schema.sql)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.donor,
    String? country,
    String? slug,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role.name,
        'country': (country?.isEmpty ?? true) ? null : country,
        'slug': (slug?.isEmpty ?? true) ? null : slug,
      },
    );
  }

  /// Logout
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Busca o perfil completo do usuário na tabela 'profiles'
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Reset de senha
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Reenviar e-mail de confirmação
  Future<void> resendConfirmationEmail(String email) async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go4me/core/models/user_profile.dart';
import 'package:go4me/core/services/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider que observa o estado de autenticação do Supabase
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Provider que busca o perfil do usuário logado
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authState = ref.watch(authStateProvider).value;
  final user = authState?.session?.user ?? ref.watch(authRepositoryProvider).currentUser;
  
  if (user == null) return null;
  
  return await ref.watch(authRepositoryProvider).getUserProfile(user.id);
});

/// Controller para gerenciar ações de autenticação na UI (Login, Logout)
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.read(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.signIn(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _repository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.donor,
    String? country,
    String? slug,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        country: country,
        slug: slug,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resendConfirmation(String email) async {
    state = const AsyncValue.loading();
    try {
      await _repository.resendConfirmationEmail(email);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

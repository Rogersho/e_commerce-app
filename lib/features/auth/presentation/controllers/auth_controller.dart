import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/auth_repository.dart';
import '../../data/auth_repository_impl.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
});

final authStateChangeProvider = StreamProvider<AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(false); // Loading state

  Future<void> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authRepository.signIn(email: email, password: password);
    state = false;
    res.fold(
      (l) {
        debugPrint('Sign in error: ${l.message}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.message)));
      },
      (r) {
        debugPrint('Sign in successful for user: ${r.email}');
        // Router will handle redirection via authStateChanges
      },
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authRepository.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );
    state = false;
    res.fold(
      (l) {
        debugPrint('Sign up error: ${l.message}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.message)));
      },
      (r) {
        debugPrint('Sign up successful for user: ${r.email}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Account created!')));
      },
    );
  }

  Future<void> signOut(BuildContext context) async {
    final res = await _authRepository.signOut();
    res.fold(
      (l) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.message))),
      (r) {},
    );
  }

  Future<void> deleteAccount(BuildContext context) async {
    state = true;
    final res = await _authRepository.deleteAccount();
    state = false;
    res.fold(
      (l) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l.message)));
        }
      },
      (r) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully.')),
          );
        }
      },
    );
  }
}

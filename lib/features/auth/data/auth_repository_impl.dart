import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/type_defs.dart';
import '../domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(supabase: Supabase.instance.client);
});

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  AuthRepositoryImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  User? get currentUser => _supabase.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  @override
  FutureEither<User> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user == null) {
        return left(const Failure('User is null'));
      }

      return right(response.user!);
    } on AuthException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  FutureEither<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return left(const Failure('User is null'));
      }

      return right(response.user!);
    } on AuthException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  FutureVoid signOut() async {
    try {
      await _supabase.auth.signOut();
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  FutureVoid deleteAccount() async {
    try {
      await _supabase.rpc('delete_account');
      await _supabase.auth.signOut();
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}

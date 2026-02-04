import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/type_defs.dart';

abstract class AuthRepository {
  FutureEither<User> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  FutureEither<User> signIn({required String email, required String password});

  FutureVoid signOut();

  FutureVoid deleteAccount();

  User? get currentUser;

  Stream<AuthState> get authStateChanges;
}

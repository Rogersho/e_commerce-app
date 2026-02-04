import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/profile.dart';

import './auth_controller.dart';

final profileProvider = FutureProvider<Profile?>((ref) async {
  final authState = ref.watch(authStateChangeProvider);
  final user = authState.value?.session?.user;

  if (user == null) return null;

  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('profiles')
      .select()
      .eq('id', user.id)
      .single();
  return Profile.fromJson(data);
});

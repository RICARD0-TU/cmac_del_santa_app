import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repository/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError(
    'Configure AuthRepositoryImpl with Supabase client.',
  );
});

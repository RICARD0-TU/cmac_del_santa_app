import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_environment.dart';

class SupabaseConfig {
  const SupabaseConfig._();

  static Future<void> initialize(AppEnvironment environment) async {
    if (!environment.hasSupabaseConfig) {
      return;
    }

    await Supabase.initialize(
      url: environment.supabaseUrl,
      anonKey: environment.supabaseAnonKey,
      debug: environment.type != EnvironmentType.production,
    );
  }
}

import '../config/app_environment.dart';
import '../config/supabase_config.dart';

class AppBootstrap {
  const AppBootstrap._();

  static Future<void> initialize() async {
    final environment = AppEnvironment.fromDartDefines();
    await SupabaseConfig.initialize(environment);
  }
}

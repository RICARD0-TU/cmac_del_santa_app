enum EnvironmentType { development, staging, production }

class AppEnvironment {
  const AppEnvironment({
    required this.type,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.enableNetworkLogs,
  });

  factory AppEnvironment.fromDartDefines() {
    const value = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );

    return AppEnvironment(
      type: switch (value) {
        'production' => EnvironmentType.production,
        'staging' => EnvironmentType.staging,
        _ => EnvironmentType.development,
      },
      supabaseUrl: const String.fromEnvironment('SUPABASE_URL'),
      supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      enableNetworkLogs: const bool.fromEnvironment(
        'ENABLE_NETWORK_LOGS',
        defaultValue: true,
      ),
    );
  }

  final EnvironmentType type;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final bool enableNetworkLogs;

  bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}

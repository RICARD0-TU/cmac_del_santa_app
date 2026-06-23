part of cmac_del_santa_app;

class CmacSantaApp extends ConsumerWidget {
  const CmacSantaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(supabaseClientProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CMAC Del Santa',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.red,
          primary: AppColors.red,
          secondary: AppColors.blue,
          tertiary: AppColors.gold,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: AppColors.red,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE1E5EA)),
          ),
        ),
      ),
      home: db.auth.currentSession == null
          ? const LoginPage()
          : const ClientHomePage(),
    );
  }
}

class AppColors {
  static const red = Color(0xFFC61920);
  static const darkRed = Color(0xFF8F1015);
  static const gold = Color(0xFFFFC400);
  static const blue = Color(0xFF0057A8);
  static const green = Color(0xFF149447);
  static const ink = Color(0xFF17202A);
  static const muted = Color(0xFF667085);
}

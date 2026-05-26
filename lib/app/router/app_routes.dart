enum AppRoute {
  splash('/'),
  login('/login'),
  register('/register'),
  resetPassword('/reset-password'),
  dashboard('/dashboard');

  const AppRoute(this.path);

  final String path;
}

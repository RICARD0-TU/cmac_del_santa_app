enum AppRoute {
  splash('/'),
  login('/login'),
  dashboard('/dashboard');

  const AppRoute(this.path);

  final String path;
}

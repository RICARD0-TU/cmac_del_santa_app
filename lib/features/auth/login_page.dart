part of cmac_del_santa_app;

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final dniController = TextEditingController(text: '72000001');
  final passwordController = TextEditingController();
  bool loading = false;
  bool hidePassword = true;
  String? error;

  @override
  void dispose() {
    dniController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final input = dniController.text.trim();
      final email = input.contains('@')
          ? input
          : '$input@clientes.cmacdelsanta.pe';

      await ref.read(supabaseClientProvider).auth.signInWithPassword(
        email: email,
        password: passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ClientHomePage()),
      );
    } on AuthException catch (e) {
      setState(() => error = e.message);
    } catch (_) {
      setState(() => error = 'No se pudo iniciar sesion. Revisa tu conexion.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 28),
            const BrandHeader(compact: false),
            const SizedBox(height: 28),
            Text(
              'Banca movil para clientes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Consulta tus ahorros, creditos, pagos y servicios desde Caja del Santa.',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: dniController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'DNI o correo',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passwordController,
              obscureText: hidePassword,
              decoration: InputDecoration(
                labelText: 'Contrasena',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => hidePassword = !hidePassword),
                  icon: Icon(hidePassword ? Icons.visibility : Icons.visibility_off),
                ),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, style: const TextStyle(color: AppColors.red)),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: loading ? null : login,
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login),
              label: const Text('Ingresar'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

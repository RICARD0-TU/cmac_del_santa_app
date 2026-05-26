import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../shared/design_system/buttons/primary_button.dart';
import '../../../../shared/design_system/inputs/app_text_field.dart';
import '../controllers/auth_form_validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_message_panel.dart';
import '../widgets/auth_page_shell.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final environment = ref.watch(appEnvironmentProvider);
    final isDevelopmentFallback = !environment.hasSupabaseConfig;

    return AuthPageShell(
      children: [
        if (isDevelopmentFallback) ...[
          const AuthMessagePanel(
            success:
                'Modo desarrollo: Supabase no esta configurado. Puedes ingresar con cualquier correo valido y una clave de 6 caracteres.',
          ),
          const SizedBox(height: 16),
        ],
        AuthMessagePanel(
          error: authState.error,
          success: authState.successMessage,
        ),
        if (authState.error != null || authState.successMessage != null)
          const SizedBox(height: 16),
        AppTextField(
          label: 'Correo electronico',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixIcon: const Icon(Icons.mail_outline),
          errorText: _emailError,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Clave digital',
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            tooltip: _obscurePassword ? 'Mostrar clave' : 'Ocultar clave',
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
          errorText: _passwordError,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Ingresar',
          icon: Icons.lock_open,
          isLoading: authState.isLoading,
          onPressed: authState.isLoading ? null : _submit,
        ),
        if (authState.isBiometricAvailable) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: authState.isLoading ? null : _loginWithBiometrics,
            icon: const Icon(Icons.fingerprint),
            label: const Text('Ingresar con biometria'),
          ),
        ],
        const SizedBox(height: 16),
        TextButton(
          onPressed: authState.isLoading
              ? null
              : () => context.goNamed(AppRoute.resetPassword.name),
          child: const Text('Recuperar clave digital'),
        ),
        TextButton(
          onPressed: authState.isLoading
              ? null
              : () => context.goNamed(AppRoute.register.name),
          child: const Text('Crear usuario digital'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    ref.read(authProvider.notifier).clearMessages();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = AuthFormValidators.isValidEmail(email)
          ? null
          : 'Ingresa un correo valido.';
      _passwordError = AuthFormValidators.isValidPassword(password)
          ? null
          : 'La clave debe tener al menos 6 caracteres.';
    });

    if (_emailError != null || _passwordError != null) {
      return;
    }

    await ref
        .read(authProvider.notifier)
        .login(email: email, password: password);

    if (mounted && ref.read(authProvider).isAuthenticated) {
      context.goNamed(AppRoute.dashboard.name);
    }
  }

  Future<void> _loginWithBiometrics() async {
    await ref.read(authProvider.notifier).loginWithBiometrics();
    if (mounted && ref.read(authProvider).isAuthenticated) {
      context.goNamed(AppRoute.dashboard.name);
    }
  }
}

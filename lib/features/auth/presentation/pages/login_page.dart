import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../shared/design_system/buttons/primary_button.dart';
import '../../../../shared/design_system/inputs/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/secure_login_header.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _documentController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _documentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SecureLoginHeader(),
                  const SizedBox(height: 32),
                  AppTextField(
                    label: 'DNI o correo',
                    controller: _documentController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Clave digital',
                    controller: _passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: authState.isLoading ? 'Validando...' : 'Ingresar',
                    icon: Icons.lock_open,
                    onPressed: authState.isLoading ? null : _submit,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Recuperar clave digital'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    await ref
        .read(authNotifierProvider.notifier)
        .login(
          documentNumber: _documentController.text,
          password: _passwordController.text,
        );

    if (mounted) {
      context.goNamed(AppRoute.dashboard.name);
    }
  }
}

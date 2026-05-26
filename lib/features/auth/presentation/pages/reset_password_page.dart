import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../shared/design_system/buttons/primary_button.dart';
import '../../../../shared/design_system/inputs/app_text_field.dart';
import '../controllers/auth_form_validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_message_panel.dart';
import '../widgets/auth_page_shell.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _emailController = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return AuthPageShell(
      children: [
        Text(
          'Recuperar clave digital',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
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
          prefixIcon: const Icon(Icons.mail_outline),
          errorText: _emailError,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Enviar enlace',
          icon: Icons.mark_email_read_outlined,
          isLoading: authState.isLoading,
          onPressed: authState.isLoading ? null : _submit,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: authState.isLoading
              ? null
              : () => context.goNamed(AppRoute.login.name),
          child: const Text('Volver al ingreso'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    ref.read(authProvider.notifier).clearMessages();
    final email = _emailController.text.trim();
    setState(() {
      _emailError = AuthFormValidators.isValidEmail(email)
          ? null
          : 'Ingresa un correo valido.';
    });

    if (_emailError != null) {
      return;
    }

    await ref.read(authProvider.notifier).resetPassword(email);
  }
}

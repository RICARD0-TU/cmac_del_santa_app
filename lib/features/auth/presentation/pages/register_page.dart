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

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _dniController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _formError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _dniController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return AuthPageShell(
      children: [
        Text('Registro digital', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        AuthMessagePanel(error: _formError ?? authState.error),
        if (_formError != null || authState.error != null)
          const SizedBox(height: 16),
        AppTextField(
          label: 'Nombres y apellidos',
          controller: _fullNameController,
          prefixIcon: const Icon(Icons.person_outline),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'DNI',
          controller: _dniController,
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.badge_outlined),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Celular',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Correo electronico',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.mail_outline),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Clave digital',
          controller: _passwordController,
          obscureText: _obscurePassword,
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
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Crear usuario',
          icon: Icons.person_add_alt_1,
          isLoading: authState.isLoading,
          onPressed: authState.isLoading ? null : _submit,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: authState.isLoading
              ? null
              : () => context.goNamed(AppRoute.login.name),
          child: const Text('Ya tengo usuario digital'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    ref.read(authProvider.notifier).clearMessages();
    final fullName = _fullNameController.text.trim();
    final dni = _dniController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final error = _validate(
      fullName: fullName,
      dni: dni,
      phone: phone,
      email: email,
      password: password,
    );

    setState(() => _formError = error);
    if (error != null) {
      return;
    }

    await ref
        .read(authProvider.notifier)
        .register(
          email: email,
          password: password,
          fullName: fullName,
          dni: dni,
          phone: phone,
        );

    if (mounted && ref.read(authProvider).isAuthenticated) {
      context.goNamed(AppRoute.dashboard.name);
    }
  }

  String? _validate({
    required String fullName,
    required String dni,
    required String phone,
    required String email,
    required String password,
  }) {
    if (fullName.length < 4) {
      return 'Ingresa tus nombres y apellidos.';
    }
    if (!AuthFormValidators.isValidDni(dni)) {
      return 'El DNI debe tener 8 digitos.';
    }
    if (!AuthFormValidators.isValidPhone(phone)) {
      return 'El celular debe tener 9 digitos.';
    }
    if (!AuthFormValidators.isValidEmail(email)) {
      return 'Ingresa un correo valido.';
    }
    if (!AuthFormValidators.isValidPassword(password)) {
      return 'La clave debe tener al menos 6 caracteres.';
    }
    return null;
  }
}

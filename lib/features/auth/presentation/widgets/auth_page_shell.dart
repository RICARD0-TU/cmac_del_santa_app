import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'secure_login_header.dart';

class AuthPageShell extends StatelessWidget {
  const AuthPageShell({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SecureLoginHeader(),
                      const SizedBox(height: 24),
                      ...children,
                      const SizedBox(height: 8),
                      Text(
                        'Tus datos viajan protegidos con cifrado y politicas de sesion segura.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

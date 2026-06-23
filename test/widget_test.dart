import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cmac_del_santa_app/main.dart';

void main() {
  testWidgets('Login screen shows CMAC Del Santa branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginPage()),
      ),
    );

    expect(find.text('Caja del Santa'), findsOneWidget);
    expect(find.text('Banca movil para clientes'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);

    expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
  });
}

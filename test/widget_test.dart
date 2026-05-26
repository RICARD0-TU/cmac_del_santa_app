import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cmac_del_santa/app/app.dart';
import 'package:cmac_del_santa/features/auth/data/repository/unconfigured_auth_repository.dart';
import 'package:cmac_del_santa/features/auth/di/auth_di.dart';

void main() {
  testWidgets('renders the initial secure login screen', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            const UnconfiguredAuthRepository(),
          ),
        ],
        child: const CmacDelSantaApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('CMAC Del Santa'), findsWidgets);
    expect(find.text('Ingresar'), findsOneWidget);
  });
}

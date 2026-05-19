import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cmac_del_santa/app/app.dart';

void main() {
  testWidgets('renders the initial secure login screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CmacDelSantaApp()));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('CMAC Del Santa'), findsWidgets);
    expect(find.text('Ingresar'), findsOneWidget);
  });
}

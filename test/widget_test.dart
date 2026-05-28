import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bac_app/src/screens/login_screen.dart';

void main() {
  testWidgets('landing screen shows brand and auth actions', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('BacPro'), findsOneWidget);
    expect(find.text('Autentificare'), findsOneWidget);
    expect(find.text('Creează cont'), findsOneWidget);
  });
}

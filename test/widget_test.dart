import 'package:flutter_test/flutter_test.dart';
import 'package:bac_app/app.dart';
void main() {
  testWidgets('shows login screen on start', (WidgetTester tester) async {
    await tester.pumpWidget(const BacApp());
    expect(find.text('BacHub'), findsOneWidget);
    expect(find.text('Conectează-te'), findsOneWidget);
  });
}

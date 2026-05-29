import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/src/app.dart';

void main() {
  testWidgets('renders scaffold overview', (tester) async {
    await tester.pumpWidget(const DoitApp());

    expect(find.text('Monorepo scaffold ready'), findsOneWidget);
    expect(find.text('api-server'), findsOneWidget);
    expect(find.text('contracts'), findsOneWidget);
  });
}

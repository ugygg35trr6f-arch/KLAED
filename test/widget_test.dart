import 'package:flutter_test/flutter_test.dart';
import 'package:klaed/main.dart';

void main() {
  testWidgets('KLAED home screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const KLAEDApp());

    expect(find.text('KLAED'), findsOneWidget);
    expect(find.text('آخر المنشورات'), findsOneWidget);
  });
}

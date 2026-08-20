import 'package:flutter_test/flutter_test.dart';

import 'package:stackflow/app.dart';

void main() {
  testWidgets(
    'StackFlow app loads',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const StackFlowApp(),
      );

      expect(
        find.text('StackFlow'),
        findsOneWidget,
      );

      expect(
        find.text(
          'Simple inventory. Smarter billing.',
        ),
        findsOneWidget,
      );
    },
  );
}
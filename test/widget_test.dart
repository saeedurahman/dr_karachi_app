import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_app/core/widgets/marketing_opt_in_checkbox.dart';

void main() {
  testWidgets('MarketingOptInCheckbox smoke test', (WidgetTester tester) async {
    bool isChecked = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MarketingOptInCheckbox(
            value: isChecked,
            onChanged: (val) {
              isChecked = val;
            },
          ),
        ),
      ),
    );

    expect(find.byType(MarketingOptInCheckbox), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_app/core/widgets/marketing_opt_in_checkbox.dart';
import 'package:pharmacy_app/features/pharmacy/data/models/checkout_models.dart';

void main() {
  group('MarketingOptInCheckbox Widget Tests', () {
    testWidgets('renders unchecked by default with exact required English and Urdu copy',
        (tester) async {
      bool checked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return MarketingOptInCheckbox(
                  value: checked,
                  onChanged: (val) {
                    setState(() => checked = val);
                  },
                );
              },
            ),
          ),
        ),
      );

      // Verify English copy
      expect(
        find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text
                .toPlainText()
                .contains('I agree to receive offers and updates on WhatsApp.')),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text
                .toPlainText()
                .contains('Reply STOP anytime to unsubscribe.')),
        findsOneWidget,
      );

      // Verify Urdu copy
      expect(
        find.text('میں واٹس ایپ پر آفرز اور اپ ڈیٹس وصول کرنے پر رضامند ہوں۔'),
        findsOneWidget,
      );

      // Verify checkbox is unchecked
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);
      Checkbox checkbox = tester.widget(checkboxFinder);
      expect(checkbox.value, isFalse);

      // Tap on the container text (accessible tap target)
      await tester.tap(find.text('میں واٹس ایپ پر آفرز اور اپ ڈیٹس وصول کرنے پر رضامند ہوں۔'));
      await tester.pumpAndSettle();

      // Checkbox should now be checked
      checkbox = tester.widget(checkboxFinder);
      expect(checkbox.value, isTrue);
      expect(checked, isTrue);

      // Tap again to uncheck
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      checkbox = tester.widget(checkboxFinder);
      expect(checkbox.value, isFalse);
      expect(checked, isFalse);
    });
  });

  group('Request Models & Phone Regex Tests', () {
    test('CheckoutRequestModel serializes marketing_opt_in accurately', () {
      final defaultModel = CheckoutRequestModel();
      expect(defaultModel.marketingOptIn, isFalse);
      expect(defaultModel.toJson()['marketing_opt_in'], isFalse);

      final tickedModel = CheckoutRequestModel(marketingOptIn: true);
      expect(tickedModel.marketingOptIn, isTrue);
      expect(tickedModel.toJson()['marketing_opt_in'], isTrue);
    });

    test('Pakistani phone regex accepts 03X, +923X, 923X, 00923X formats', () {
      final phoneRegex = RegExp(r'^((\+92)|(0092)|92|0)?3\d{9}$');

      expect(phoneRegex.hasMatch('03001234567'), isTrue);
      expect(phoneRegex.hasMatch('+923001234567'), isTrue);
      expect(phoneRegex.hasMatch('923001234567'), isTrue);
      expect(phoneRegex.hasMatch('00923001234567'), isTrue);
      expect(phoneRegex.hasMatch('3001234567'), isTrue);

      // Invalid formats
      expect(phoneRegex.hasMatch('12345'), isFalse);
      expect(phoneRegex.hasMatch('04001234567'), isFalse);
    });
  });
}

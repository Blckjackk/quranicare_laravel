// QuraniCare widget tests
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quranicare/main.dart';

void main() {
  testWidgets('QuraniCare app basic configuration test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Verify app title is set correctly
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, 'QuraniCare');
    
    // Verify debug banner is disabled
    expect(app.debugShowCheckedModeBanner, false);
    
    // Verify primary color
    expect(app.theme?.primaryColor, const Color(0xFF2D5A5A));
    
    // Verify Material3 is enabled
    expect(app.theme?.useMaterial3, true);
  });
}

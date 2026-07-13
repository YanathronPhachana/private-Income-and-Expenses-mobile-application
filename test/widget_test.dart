// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:private_expense_mobileapp_new/main.dart';

void main() {
  testWidgets('Dashboard smoke test', (WidgetTester tester) async {
    // Initialize Thai date formatting for the test environment.
    await initializeDateFormatting('th_TH', null);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the title 'กระเป๋าเงินของฉัน' is shown.
    expect(find.text('กระเป๋าเงินของฉัน'), findsOneWidget);

    // Verify that the empty state is displayed initially.
    expect(find.text('ยังไม่มีรายการธุรกรรมใด ๆ'), findsOneWidget);

    // Verify bottom navigation destinations.
    expect(find.text('แดชบอร์ด'), findsOneWidget);
    expect(find.text('บันทึก'), findsOneWidget);
    expect(find.text('สรุปผล'), findsOneWidget);
  });
}

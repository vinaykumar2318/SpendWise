// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sw_frontend/app/app.dart';

void main() {
  testWidgets('SpendWise app starts successfully', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SpendWiseApp()));

    await tester.pumpAndSettle();

    expect(find.text('SpendWise'), findsOneWidget);
  });
}

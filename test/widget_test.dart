import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lock_in_app/pages/task_page.dart';
import 'package:lock_in_app/services/local_account_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Add task dialog adds a task to the checklist', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TaskPage()),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('ADD TASK'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD TASK'));
    await tester.pumpAndSettle();

    expect(find.text('Add task'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Call the dentist');
    await tester.tap(find.text('ADD TASK').last);
    await tester.pumpAndSettle();

    expect(find.text('CALL THE DENTIST'), findsOneWidget);
  });

  test('Local account is saved and password verification works', () async {
    SharedPreferences.setMockInitialValues({});

    final created = await LocalAccountStore.create(
      name: 'Taylor Example',
      email: 'taylor@example.com',
      password: 'secret1',
    );
    final saved = await LocalAccountStore.load();

    expect(saved?.name, 'Taylor Example');
    expect(saved?.email, 'taylor@example.com');
    expect(LocalAccountStore.verifyPassword(created, 'secret1'), isTrue);
    expect(
        LocalAccountStore.verifyPassword(created, 'wrong-password'), isFalse);
  });
}

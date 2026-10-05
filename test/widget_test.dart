import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/main.dart';
import 'package:trainer_app/features/auth/login_screen.dart';

void main() {
  testWidgets('SkillSense AI smoke test loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SkillSenseApp(),
      ),
    );
    await tester.pump();

    // Verify SkillSense AI branding loads
    expect(find.text('SkillSense AI'), findsWidgets);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silent_sos_movil/app.dart';

void main() {
  testWidgets('renderiza splash inicial', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SilentSosApp()),
    );
    expect(find.text('SilentSOS'), findsOneWidget);
  });
}

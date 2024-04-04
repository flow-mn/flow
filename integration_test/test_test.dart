import 'package:flow/main.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/prefs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/database_test.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await ObjectBox.initialize(
    customDirectory: objectboxTestRootDir().path,
    subdirectory: "main",
  );
  await LocalPreferences.initialize();

  testWidgets(
    "Test run",
    (widgetTester) async {
      TestWidgetsFlutterBinding.ensureInitialized();

      await widgetTester.pumpWidget(const Flow());

      expect(find.byType(Flow), findsOneWidget);
    },
  );
}

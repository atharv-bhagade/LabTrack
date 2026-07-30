import 'package:flutter_test/flutter_test.dart';
import 'package:hello_flutter/constants/app_info.dart';
import 'package:hello_flutter/controllers/dashboard_controller.dart';
import 'package:hello_flutter/controllers/lab_layout_controller.dart';
import 'package:hello_flutter/controllers/theme_controller.dart';
import 'package:hello_flutter/main.dart';
import 'package:hello_flutter/services/dashboard_storage_service.dart';
import 'package:hello_flutter/services/layout_storage_service.dart';
import 'package:hello_flutter/services/settings_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('FIX IT reaches dashboard after splash', (
    WidgetTester tester,
  ) async {
    final layoutController = LabLayoutController(
      storageService: LayoutStorageService(),
    );
    final themeController = ThemeController(SettingsStorageService());
    final dashboardController = DashboardController(
      dashboardStorage: DashboardStorageService(),
      layoutStorage: LayoutStorageService(),
    );

    await tester.pumpWidget(
      LabLayoutApp(
        layoutController: layoutController,
        themeController: themeController,
        dashboardController: dashboardController,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppInfo.appName), findsWidgets);
    expect(find.text('No buildings yet'), findsOneWidget);
    expect(find.text('Add Building'), findsWidgets);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hello_flutter/constants/app_info.dart';
import 'package:hello_flutter/controllers/dashboard_controller.dart';
import 'package:hello_flutter/controllers/lab_layout_controller.dart';
import 'package:hello_flutter/controllers/theme_controller.dart';
import 'package:hello_flutter/main.dart';
import 'package:hello_flutter/presentation/providers/app_providers.dart';
import 'package:hello_flutter/services/dashboard_storage_service.dart';
import 'package:hello_flutter/services/layout_storage_service.dart';
import 'package:hello_flutter/services/settings_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('FIX IT shows login after splash when logged out', (
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
      ProviderScope(
        overrides: [
          layoutControllerProvider.overrideWithValue(layoutController),
          themeControllerProvider.overrideWithValue(themeController),
          dashboardControllerProvider.overrideWithValue(dashboardController),
        ],
        child: LabLayoutApp(
          layoutController: layoutController,
          themeController: themeController,
          dashboardController: dashboardController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in to your role dashboard'), findsOneWidget);
    expect(find.text(AppInfo.appName), findsWidgets);
  });
}

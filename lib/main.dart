import 'package:flutter/material.dart';

import 'package:hello_flutter/constants/app_info.dart';

import 'package:hello_flutter/controllers/dashboard_controller.dart';

import 'package:hello_flutter/controllers/lab_layout_controller.dart';

import 'package:hello_flutter/controllers/theme_controller.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hello_flutter/screens/splash_screen.dart';

import 'package:hello_flutter/presentation/providers/app_providers.dart';

import 'package:hello_flutter/services/dashboard_storage_service.dart';

import 'package:hello_flutter/services/layout_storage_service.dart';

import 'package:hello_flutter/services/settings_storage_service.dart';

import 'package:hello_flutter/theme/app_theme.dart';



Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();



  final layoutStorageService = LayoutStorageService();

  final dashboardStorageService = DashboardStorageService();



  final layoutController = LabLayoutController(

    storageService: layoutStorageService,

  );



  final themeController = ThemeController(

    SettingsStorageService(),

  );



  final dashboardController = DashboardController(

    dashboardStorage: dashboardStorageService,

    layoutStorage: layoutStorageService,

  );



  runApp(

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

}



class LabLayoutApp extends StatelessWidget {

  const LabLayoutApp({

    super.key,

    required this.layoutController,

    required this.themeController,

    required this.dashboardController,

  });



  final LabLayoutController layoutController;

  final ThemeController themeController;

  final DashboardController dashboardController;



  @override

  Widget build(BuildContext context) {

    return AnimatedBuilder(

      animation: themeController,

      builder: (context, _) {

        return MaterialApp(

          debugShowCheckedModeBanner: false,

          title: AppInfo.appName,

          theme: AppTheme.light(),

          darkTheme: AppTheme.dark(),

          themeMode: themeController.themeMode,

          home: SplashScreen(

            layoutController: layoutController,

            themeController: themeController,

            dashboardController: dashboardController,

          ),

        );

      },

    );

  }

}

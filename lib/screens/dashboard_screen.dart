import 'package:flutter/material.dart';
import 'package:hello_flutter/constants/app_info.dart';
import 'package:hello_flutter/controllers/dashboard_controller.dart';
import 'package:hello_flutter/controllers/lab_layout_controller.dart';
import 'package:hello_flutter/controllers/theme_controller.dart';
import 'package:hello_flutter/models/building.dart';
import 'package:hello_flutter/models/floor.dart';
import 'package:hello_flutter/models/room.dart';
import 'package:hello_flutter/presentation/admin/building_creation_wizard_screen.dart';
import 'package:hello_flutter/presentation/admin/user_management_screen.dart';
import 'package:hello_flutter/screens/about_screen.dart';
import 'package:hello_flutter/screens/lab_layout_screen.dart';
import 'package:hello_flutter/screens/settings_screen.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/widgets/app_confirm_dialog.dart';
import 'package:hello_flutter/widgets/app_gradient_background.dart';
import 'package:hello_flutter/widgets/app_input_dialog.dart';
import 'package:hello_flutter/widgets/building_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.layoutController,
    required this.themeController,
    required this.dashboardController,
    this.canManageCampus = true,
    this.dashboardTitle,
    this.onLogout,
    this.labLayoutReadOnly = false,
  });

  final LabLayoutController layoutController;
  final ThemeController themeController;
  final DashboardController dashboardController;
  final bool canManageCampus;
  final String? dashboardTitle;
  final VoidCallback? onLogout;
  final bool labLayoutReadOnly;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnimatedBuilder(
      animation: dashboardController,
      builder: (context, _) {
        if (!dashboardController.isLoaded) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: palette.accent),
            ),
          );
        }

        final buildings = dashboardController.buildings;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(dashboardTitle ?? AppInfo.appName),
            actions: [
              if (canManageCampus) ...[
                IconButton(
                  tooltip: 'User Management',
                  icon: const Icon(Icons.group_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const UserManagementScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Reports & Analytics',
                  icon: const Icon(Icons.analytics_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Reports & analytics module coming soon.',
                        ),
                      ),
                    );
                  },
                ),
              ],
              IconButton(
                tooltip: 'About',
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AboutScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SettingsScreen(
                        layoutController: layoutController,
                        themeController: themeController,
                      ),
                    ),
                  );
                },
              ),
              if (onLogout != null)
                IconButton(
                  tooltip: 'Logout',
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: onLogout,
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: palette.borderSubtle),
            ),
          ),
          floatingActionButton: canManageCampus
              ? FloatingActionButton.extended(
                  onPressed: () => _addBuilding(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Building'),
                )
              : null,
          body: AppGradientBackground(
            child: SafeArea(
              child: buildings.isEmpty
                  ? _EmptyDashboard(
                      onAddBuilding: canManageCampus
                          ? () => _addBuilding(context)
                          : null,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      itemCount: buildings.length,
                      itemBuilder: (context, index) {
                        final building = buildings[index];
                        return BuildingCard(
                          key: ValueKey(building.id),
                          building: building,
                          readOnly: !canManageCampus,
                          onRoomTap: (room) => _openRoom(context, building, room),
                          onRenameBuilding: () =>
                              _renameBuilding(context, building),
                          onDeleteBuilding: () =>
                              _deleteBuilding(context, building),
                          onAddFloor: () => _addFloor(context, building),
                          onRenameFloor: (floor) =>
                              _renameFloor(context, building, floor),
                          onDeleteFloor: (floor) =>
                              _deleteFloor(context, building, floor),
                          onAddRoom: (floor) =>
                              _addRoom(context, building, floor),
                          onRenameRoom: (floor, room) =>
                              _renameRoom(context, building, floor, room),
                          onDeleteRoom: (floor, room) =>
                              _deleteRoom(context, building, floor, room),
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addBuilding(BuildContext context) async {
    final result = await Navigator.of(context).push<BuildingWizardResult>(
      MaterialPageRoute(builder: (_) => const BuildingCreationWizardScreen()),
    );
    if (result == null || !context.mounted) return;
    await dashboardController.addBuildingFromWizard(
      name: result.buildingName,
      floorInputs: result.floors,
    );
  }

  Future<void> _renameBuilding(BuildContext context, Building building) async {
    final name = await AppInputDialog.show(
      context: context,
      title: 'Rename Building',
      hint: 'Building name',
      initialValue: building.name,
    );
    if (name == null || !context.mounted) return;
    await dashboardController.renameBuilding(building.id, name);
  }

  Future<void> _deleteBuilding(BuildContext context, Building building) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Delete Building',
      message:
          'Delete "${building.name}" and all of its floors, labs, and saved layouts?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await dashboardController.deleteBuilding(building.id);
  }

  Future<void> _addFloor(BuildContext context, Building building) async {
    final name = await AppInputDialog.show(
      context: context,
      title: 'Add Floor',
      hint: 'Floor name',
      confirmLabel: 'Add',
    );
    if (name == null || !context.mounted) return;
    await dashboardController.addFloor(building.id, name);
  }

  Future<void> _renameFloor(
    BuildContext context,
    Building building,
    Floor floor,
  ) async {
    final name = await AppInputDialog.show(
      context: context,
      title: 'Rename Floor',
      hint: 'Floor name',
      initialValue: floor.name,
    );
    if (name == null || !context.mounted) return;
    await dashboardController.renameFloor(building.id, floor.id, name);
  }

  Future<void> _deleteFloor(
    BuildContext context,
    Building building,
    Floor floor,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Delete Floor',
      message:
          'Delete "${floor.name}" and all labs and saved layouts on this floor?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await dashboardController.deleteFloor(building.id, floor.id);
  }

  Future<void> _addRoom(
    BuildContext context,
    Building building,
    Floor floor,
  ) async {
    final name = await AppInputDialog.show(
      context: context,
      title: 'Add Room',
      hint: 'Lab name',
      confirmLabel: 'Add',
    );
    if (name == null || !context.mounted) return;
    await dashboardController.addRoom(building.id, floor.id, name);
  }

  Future<void> _renameRoom(
    BuildContext context,
    Building building,
    Floor floor,
    Room room,
  ) async {
    final name = await AppInputDialog.show(
      context: context,
      title: 'Rename Room',
      hint: 'Lab name',
      initialValue: room.name,
    );
    if (name == null || !context.mounted) return;
    await dashboardController.renameRoom(
      building.id,
      floor.id,
      room.id,
      name,
    );
  }

  Future<void> _deleteRoom(
    BuildContext context,
    Building building,
    Floor floor,
    Room room,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Delete Room',
      message:
          'Delete "${room.name}" and its saved chessboard layout permanently?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await dashboardController.deleteRoom(building.id, floor.id, room.id);
  }

  void _openRoom(BuildContext context, Building building, Room room) {
    var floorName = '';
    for (final floor in building.floors) {
      if (floor.rooms.any((item) => item.id == room.id)) {
        floorName = floor.name;
        break;
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LabLayoutScreen(
          room: room,
          buildingName: building.name,
          floorName: floorName,
          layoutController: layoutController,
          themeController: themeController,
          readOnly: labLayoutReadOnly,
        ),
      ),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard({this.onAddBuilding});

  final VoidCallback? onAddBuilding;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Card(
          margin: const EdgeInsets.all(28),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: palette.borderSubtle),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: palette.shadow.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          palette.accent.withValues(alpha: 0.22),
                          palette.accent.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.apartment_rounded,
                      size: 34,
                      color: palette.accent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No buildings yet',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Create your first building to organize floors, labs, and device layouts.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.textSecondary,
                      height: 1.55,
                      fontSize: 15,
                    ),
                  ),
                  if (onAddBuilding != null) ...[
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: onAddBuilding,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Building'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

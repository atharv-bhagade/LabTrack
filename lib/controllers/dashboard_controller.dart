import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hello_flutter/domain/services/building_wizard_service.dart';
import 'package:hello_flutter/models/building.dart';
import 'package:hello_flutter/models/floor.dart';
import 'package:hello_flutter/models/room.dart';
import 'package:hello_flutter/services/dashboard_storage_service.dart';
import 'package:hello_flutter/services/layout_storage_service.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({
    required DashboardStorageService dashboardStorage,
    required LayoutStorageService layoutStorage,
  })  : _dashboardStorage = dashboardStorage,
        _layoutStorage = layoutStorage;

  final DashboardStorageService _dashboardStorage;
  final LayoutStorageService _layoutStorage;

  List<Building> _buildings = [];
  bool isLoaded = false;
  bool _notifyPending = false;

  List<Building> get buildings => List.unmodifiable(_buildings);

  /// Schedules [notifyListeners] for the next frame so dialog routes can finish
  /// disposing before the dashboard [AnimatedBuilder] rebuilds the tree.
  void _notifyListeners() {
    if (_notifyPending) return;
    _notifyPending = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _notifyPending = false;
      if (hasListeners) notifyListeners();
    });
  }

  Future<void> load() async {
    _buildings = await _dashboardStorage.loadBuildings();
    isLoaded = true;
    notifyListeners();
  }

  Future<void> addBuilding(String name) async {
    _buildings = [
      ..._buildings,
      Building(
        id: _newId('building'),
        name: name,
        floors: const [],
      ),
    ];
    _notifyListeners();
    await _persist();
  }

  Future<void> addBuildingFromWizard({
    required String name,
    required List<FloorWizardInput> floorInputs,
  }) async {
    final floors = BuildingWizardService.buildFloors(
      inputs: floorInputs,
      newId: _newId,
    );

    _buildings = [
      ..._buildings,
      Building(
        id: _newId('building'),
        name: name,
        floors: floors,
      ),
    ];
    _notifyListeners();
    await _persist();
  }

  Future<void> renameBuilding(String buildingId, String newName) async {
    _buildings = _buildings
        .map(
          (building) => building.id == buildingId
              ? building.copyWith(name: newName)
              : building,
        )
        .toList();
    _notifyListeners();
    await _persist();
  }

  Future<void> deleteBuilding(String buildingId) async {
    final building = _buildingById(buildingId);
    if (building == null) return;

    await _layoutStorage.deleteLayouts(building.roomIds);
    _buildings = _buildings.where((b) => b.id != buildingId).toList();
    _notifyListeners();
    await _persist();
  }

  Future<void> addFloor(String buildingId, String name) async {
    _buildings = _buildings.map((building) {
      if (building.id != buildingId) return building;
      return building.copyWith(
        floors: [
          ...building.floors,
          Floor(
            id: _newId('floor'),
            name: name,
            rooms: const [],
          ),
        ],
      );
    }).toList();
    _notifyListeners();
    await _persist();
  }

  Future<void> renameFloor(
    String buildingId,
    String floorId,
    String newName,
  ) async {
    _buildings = _buildings.map((building) {
      if (building.id != buildingId) return building;
      return building.copyWith(
        floors: building.floors
            .map(
              (floor) => floor.id == floorId
                  ? floor.copyWith(name: newName)
                  : floor,
            )
            .toList(),
      );
    }).toList();
    _notifyListeners();
    await _persist();
  }

  Future<void> deleteFloor(String buildingId, String floorId) async {
    final building = _buildingById(buildingId);
    if (building == null) return;

    final floor = building.floors.firstWhere((item) => item.id == floorId);
    await _layoutStorage.deleteLayouts(floor.rooms.map((room) => room.id));

    _buildings = _buildings.map((item) {
      if (item.id != buildingId) return item;
      return item.copyWith(
        floors: item.floors.where((f) => f.id != floorId).toList(),
      );
    }).toList();
    _notifyListeners();
    await _persist();
  }

  Future<void> addRoom(String buildingId, String floorId, String name) async {
    _buildings = _buildings.map((building) {
      if (building.id != buildingId) return building;
      return building.copyWith(
        floors: building.floors.map((floor) {
          if (floor.id != floorId) return floor;
          return floor.copyWith(
            rooms: [
              ...floor.rooms,
              Room(
                id: _newId('room'),
                name: name,
              ),
            ],
          );
        }).toList(),
      );
    }).toList();
    _notifyListeners();
    await _persist();
  }

  Future<void> renameRoom(
    String buildingId,
    String floorId,
    String roomId,
    String newName,
  ) async {
    _buildings = _buildings.map((building) {
      if (building.id != buildingId) return building;
      return building.copyWith(
        floors: building.floors.map((floor) {
          if (floor.id != floorId) return floor;
          return floor.copyWith(
            rooms: floor.rooms
                .map(
                  (room) =>
                      room.id == roomId ? room.copyWith(name: newName) : room,
                )
                .toList(),
          );
        }).toList(),
      );
    }).toList();
    _notifyListeners();
    await _persist();
  }

  Future<void> deleteRoom(
    String buildingId,
    String floorId,
    String roomId,
  ) async {
    await _layoutStorage.deleteLayout(roomId);
    _buildings = _buildings.map((building) {
      if (building.id != buildingId) return building;
      return building.copyWith(
        floors: building.floors.map((floor) {
          if (floor.id != floorId) return floor;
          return floor.copyWith(
            rooms: floor.rooms.where((room) => room.id != roomId).toList(),
          );
        }).toList(),
      );
    }).toList();
    _notifyListeners();
    await _persist();
  }

  Building? _buildingById(String buildingId) {
    for (final building in _buildings) {
      if (building.id == buildingId) return building;
    }
    return null;
  }

  String _newId(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}';

  Future<void> _persist() async {
    await _dashboardStorage.saveBuildings(_buildings);
  }
}

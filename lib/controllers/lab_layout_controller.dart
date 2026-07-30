import 'package:flutter/material.dart';
import 'package:hello_flutter/constants/layout_constants.dart';
import 'package:hello_flutter/models/device.dart';
import 'package:hello_flutter/models/device_status.dart';
import 'package:hello_flutter/models/device_type.dart';
import 'package:hello_flutter/models/lab_layout_data.dart';
import 'package:hello_flutter/services/device_naming_service.dart';
import 'package:hello_flutter/services/layout_storage_service.dart';

class LabLayoutController extends ChangeNotifier {
  LabLayoutController({
    required LayoutStorageService storageService,
    DeviceNamingService? namingService,
  })  : _storageService = storageService,
        _namingService = namingService ?? DeviceNamingService();

  final LayoutStorageService _storageService;
  final DeviceNamingService _namingService;

  LabLayoutData _data = LabLayoutData.initial();
  String? _currentRoomId;
  bool isLoaded = false;
  final Set<String> removingDeviceIds = {};
  final Set<String> placingDeviceIds = {};

  int get rows => _data.rows;
  int get cols => _data.cols;
  List<Device> get devices => List.unmodifiable(_data.devices);
  int get nextDeviceId => _data.nextDeviceId;
  String? get currentRoomId => _currentRoomId;

  Future<void> loadForRoom(
    String roomId, {
    int defaultRows = LayoutConstants.defaultGridSize,
    int defaultCols = LayoutConstants.defaultGridSize,
  }) async {
    _currentRoomId = roomId;
    final saved = await _storageService.loadLayout(roomId);
    _data = saved ??
        LabLayoutData.initial().copyWith(
          rows: defaultRows,
          cols: defaultCols,
        );
    isLoaded = true;
    removingDeviceIds.clear();
    placingDeviceIds.clear();
    notifyListeners();
  }

  Future<void> addDevice(DeviceType type, int row, int col) async {
    final now = DateTime.now();
    final counters = Map<DeviceType, int>.from(_data.typeCounters);
    final name = _namingService.nextDefaultName(type, counters);
    final id = 'device_${_data.nextDeviceId}';

    final updatedDevices = _data.devices
        .where((device) => device.row != row || device.column != col)
        .toList()
      ..add(
        Device(
          id: id,
          name: name,
          type: type,
          row: row,
          column: col,
          status: DeviceStatus.working,
          failureReason: '',
          dateCreated: now,
          lastUpdated: now,
        ),
      );

    placingDeviceIds.add(id);
    _data = _data.copyWith(
      devices: updatedDevices,
      typeCounters: counters,
      nextDeviceId: _data.nextDeviceId + 1,
    );
    notifyListeners();
    await _persist();

    Future<void>.delayed(const Duration(milliseconds: 350), () {
      placingDeviceIds.remove(id);
      notifyListeners();
    });
  }

  Future<void> updateDevice(Device device) async {
    final updatedDevices = _data.devices
        .map((existing) => existing.id == device.id ? device : existing)
        .toList();

    _data = _data.copyWith(devices: updatedDevices);
    notifyListeners();
    await _persist();
  }

  Future<void> removeDevice(String id) async {
    removingDeviceIds.add(id);
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 280));

    _data = _data.copyWith(
      devices: _data.devices.where((device) => device.id != id).toList(),
    );
    removingDeviceIds.remove(id);
    notifyListeners();
    await _persist();
  }

  List<Device> devicesOutsideBounds({int? rows, int? cols}) {
    final targetRows = rows ?? _data.rows;
    final targetCols = cols ?? _data.cols;
    return _data.devices
        .where(
          (device) =>
              device.row >= targetRows || device.column >= targetCols,
        )
        .toList();
  }

  Future<void> resizeRows(int newRows, {required bool removeOutside}) async {
    if (newRows < LayoutConstants.minGridSize ||
        newRows > LayoutConstants.maxGridSize) {
      return;
    }

    var updatedDevices = _data.devices;
    if (removeOutside) {
      updatedDevices = updatedDevices
          .where((device) => device.row < newRows)
          .toList();
    }

    _data = _data.copyWith(rows: newRows, devices: updatedDevices);
    notifyListeners();
    await _persist();
  }

  Future<void> resizeCols(int newCols, {required bool removeOutside}) async {
    if (newCols < LayoutConstants.minGridSize ||
        newCols > LayoutConstants.maxGridSize) {
      return;
    }

    var updatedDevices = _data.devices;
    if (removeOutside) {
      updatedDevices = updatedDevices
          .where((device) => device.column < newCols)
          .toList();
    }

    _data = _data.copyWith(cols: newCols, devices: updatedDevices);
    notifyListeners();
    await _persist();
  }

  Future<void> clearLayout() async {
    _data = LabLayoutData.initial().copyWith(
      rows: _data.rows,
      cols: _data.cols,
    );
    notifyListeners();
    await _persist();
  }

  Future<void> resetDeviceCounter() async {
    final counters = {
      for (final type in DeviceType.values) type: 0,
    };
    _data = _data.copyWith(
      typeCounters: counters,
      nextDeviceId: 1,
    );
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final roomId = _currentRoomId;
    if (roomId == null) return;
    await _storageService.saveLayout(roomId, _data);
  }
}

import 'package:flutter/material.dart';
import 'package:hello_flutter/domain/services/building_wizard_service.dart';
import 'package:hello_flutter/theme/app_palette.dart';

class BuildingCreationWizardScreen extends StatefulWidget {
  const BuildingCreationWizardScreen({super.key});

  @override
  State<BuildingCreationWizardScreen> createState() =>
      _BuildingCreationWizardScreenState();
}

class _BuildingCreationWizardScreenState
    extends State<BuildingCreationWizardScreen> {
  final _buildingNameController = TextEditingController();
  int _floorCount = 1;
  late List<_FloorDraft> _floors;

  @override
  void initState() {
    super.initState();
    _floors = [_FloorDraft(floorNumber: 1)];
  }

  @override
  void dispose() {
    _buildingNameController.dispose();
    for (final floor in _floors) {
      floor.nameController.dispose();
    }
    super.dispose();
  }

  void _syncFloorDrafts() {
    if (_floorCount < 1) _floorCount = 1;
    if (_floorCount > 20) _floorCount = 20;

    while (_floors.length < _floorCount) {
      final n = _floors.length + 1;
      _floors.add(_FloorDraft(floorNumber: n));
    }
    while (_floors.length > _floorCount) {
      final removed = _floors.removeLast();
      removed.nameController.dispose();
    }
  }

  void _setFloorCount(int value) {
    setState(() {
      _floorCount = value;
      _syncFloorDrafts();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _finish() {
    final name = _buildingNameController.text.trim();
    if (name.isEmpty) {
      _showError('Enter a building name.');
      return;
    }

    _syncFloorDrafts();

    final inputs = _floors
        .map(
          (floor) => FloorWizardInput(
            floorNumber: floor.floorNumber,
            name: floor.nameController.text.trim().isEmpty
                ? 'Floor ${floor.floorNumber}'
                : floor.nameController.text.trim(),
            roomCount: floor.roomCount.clamp(1, 50),
          ),
        )
        .toList();

    Navigator.pop(
      context,
      BuildingWizardResult(buildingName: name, floors: inputs),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Building'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Building details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _buildingNameController,
                          decoration: const InputDecoration(
                            labelText: 'Building Name',
                            hintText: 'Building A',
                            prefixIcon: Icon(Icons.apartment_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Number of floors',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _StepperIconButton(
                              icon: Icons.remove_rounded,
                              onPressed: _floorCount > 1
                                  ? () => _setFloorCount(_floorCount - 1)
                                  : null,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$_floorCount',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: palette.textPrimary,
                                ),
                              ),
                            ),
                            _StepperIconButton(
                              icon: Icons.add_rounded,
                              onPressed: _floorCount < 20
                                  ? () => _setFloorCount(_floorCount + 1)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Floors & rooms',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 10),
                for (final floor in _floors)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      title: Text('Floor ${floor.floorNumber}'),
                      subtitle: Text('${floor.roomCount} room(s)'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            children: [
                              TextField(
                                controller: floor.nameController,
                                decoration: InputDecoration(
                                  labelText: 'Floor name',
                                  hintText: 'Floor ${floor.floorNumber}',
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(
                                    'Rooms',
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                    ),
                                  ),
                                  const Spacer(),
                                  _StepperIconButton(
                                    icon: Icons.remove_rounded,
                                    onPressed: floor.roomCount > 1
                                        ? () => setState(() {
                                              floor.roomCount--;
                                            })
                                        : null,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text('${floor.roomCount}'),
                                  ),
                                  _StepperIconButton(
                                    icon: Icons.add_rounded,
                                    onPressed: floor.roomCount < 50
                                        ? () => setState(() {
                                              floor.roomCount++;
                                            })
                                        : null,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Labs: ${List.generate(floor.roomCount, (i) => BuildingWizardService.labRoomName(floor.floorNumber, i + 1)).take(6).join(', ')}${floor.roomCount > 6 ? '…' : ''}',
                                  style: TextStyle(
                                    color: palette.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: FilledButton.icon(
              onPressed: _finish,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Create Building'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperIconButton extends StatelessWidget {
  const _StepperIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            size: 20,
            color: onPressed == null
                ? palette.textSecondary.withValues(alpha: 0.35)
                : palette.accent,
          ),
        ),
      ),
    );
  }
}

class BuildingWizardResult {
  const BuildingWizardResult({
    required this.buildingName,
    required this.floors,
  });

  final String buildingName;
  final List<FloorWizardInput> floors;
}

class _FloorDraft {
  _FloorDraft({required this.floorNumber})
      : nameController = TextEditingController(text: 'Floor $floorNumber');

  final int floorNumber;
  final TextEditingController nameController;
  int roomCount = 4;
}

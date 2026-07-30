import 'package:flutter/material.dart';
import 'package:hello_flutter/models/building.dart';
import 'package:hello_flutter/models/floor.dart';
import 'package:hello_flutter/models/room.dart';
import 'package:hello_flutter/theme/app_palette.dart';

class BuildingCard extends StatelessWidget {
  const BuildingCard({
    super.key,
    required this.building,
    required this.onRoomTap,
    required this.onRenameBuilding,
    required this.onDeleteBuilding,
    required this.onAddFloor,
    required this.onRenameFloor,
    required this.onDeleteFloor,
    required this.onAddRoom,
    required this.onRenameRoom,
    required this.onDeleteRoom,
  });

  final Building building;
  final void Function(Room room) onRoomTap;
  final VoidCallback onRenameBuilding;
  final VoidCallback onDeleteBuilding;
  final VoidCallback onAddFloor;
  final void Function(Floor floor) onRenameFloor;
  final void Function(Floor floor) onDeleteFloor;
  final void Function(Floor floor) onAddRoom;
  final void Function(Floor floor, Room room) onRenameRoom;
  final void Function(Floor floor, Room room) onDeleteRoom;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: palette.borderSubtle),
      ),
      shadowColor: palette.shadow,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: palette.shadow.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: palette.accent.withValues(alpha: 0.08),
            highlightColor: palette.accent.withValues(alpha: 0.04),
          ),
          child: ExpansionTile(
            key: PageStorageKey<String>('building-${building.id}'),
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.fromLTRB(18, 10, 8, 10),
            childrenPadding: const EdgeInsets.only(bottom: 4),
            shape: const RoundedRectangleBorder(),
            collapsedShape: const RoundedRectangleBorder(),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    palette.accent.withValues(alpha: 0.22),
                    palette.accent.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: palette.accent.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(Icons.apartment_rounded, color: palette.accent),
            ),
            title: Text(
              building.name,
              style: TextStyle(
                color: palette.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                letterSpacing: -0.2,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${building.floors.length} floor(s)',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Rename building',
                  icon: Icon(Icons.edit_outlined, color: palette.accent),
                  onPressed: onRenameBuilding,
                ),
                IconButton(
                  tooltip: 'Delete building',
                  icon: Icon(Icons.delete_outline_rounded,
                      color: palette.defective),
                  onPressed: onDeleteBuilding,
                ),
              ],
            ),
            children: [
              if (building.floors.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                  child: Text(
                    'No floors yet. Add a floor to begin organizing labs.',
                    style: TextStyle(
                      color: palette.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
              for (final floor in building.floors) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: _FloorPanel(
                    key: ValueKey(floor.id),
                    floor: floor,
                    onRoomTap: onRoomTap,
                    onRenameFloor: () => onRenameFloor(floor),
                    onDeleteFloor: () => onDeleteFloor(floor),
                    onAddRoom: () => onAddRoom(floor),
                    onRenameRoom: (room) => onRenameRoom(floor, room),
                    onDeleteRoom: (room) => onDeleteRoom(floor, room),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: onAddFloor,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Floor'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloorPanel extends StatelessWidget {
  const _FloorPanel({
    super.key,
    required this.floor,
    required this.onRoomTap,
    required this.onRenameFloor,
    required this.onDeleteFloor,
    required this.onAddRoom,
    required this.onRenameRoom,
    required this.onDeleteRoom,
  });

  final Floor floor;
  final void Function(Room room) onRoomTap;
  final VoidCallback onRenameFloor;
  final VoidCallback onDeleteFloor;
  final VoidCallback onAddRoom;
  final void Function(Room room) onRenameRoom;
  final void Function(Room room) onDeleteRoom;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: palette.accent.withValues(alpha: 0.08),
          highlightColor: palette.accent.withValues(alpha: 0.04),
        ),
        child: ExpansionTile(
          key: PageStorageKey<String>('floor-${floor.id}'),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          shape: const RoundedRectangleBorder(),
          collapsedShape: const RoundedRectangleBorder(),
          leading: Icon(Icons.layers_rounded, color: palette.accent, size: 22),
          title: Text(
            floor.name,
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${floor.rooms.length} lab(s)',
              style: TextStyle(color: palette.textSecondary, fontSize: 12),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Rename floor',
                icon: Icon(Icons.edit_outlined,
                    size: 20, color: palette.accent),
                onPressed: onRenameFloor,
              ),
              IconButton(
                tooltip: 'Delete floor',
                icon: Icon(Icons.delete_outline_rounded,
                    size: 20, color: palette.defective),
                onPressed: onDeleteFloor,
              ),
            ],
          ),
          children: [
            if (floor.rooms.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'No labs on this floor yet.',
                  style: TextStyle(color: palette.textSecondary),
                ),
              ),
            for (final room in floor.rooms)
              ListTile(
                key: ValueKey(room.id),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Icon(Icons.meeting_room_outlined,
                    color: palette.accent),
                title: Text(room.name),
                subtitle: Text('${room.rows} x ${room.columns} grid'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Rename lab',
                      icon: Icon(Icons.edit_outlined,
                          size: 20, color: palette.accent),
                      onPressed: () => onRenameRoom(room),
                    ),
                    IconButton(
                      tooltip: 'Delete lab',
                      icon: Icon(Icons.delete_outline_rounded,
                          size: 20, color: palette.defective),
                      onPressed: () => onDeleteRoom(room),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: palette.textSecondary),
                  ],
                ),
                onTap: () => onRoomTap(room),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onAddRoom,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Room'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

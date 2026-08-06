import 'package:uuid/uuid.dart';

/// Generates collision-resistant IDs for campus entities (buildings, floors, rooms).
abstract final class UniqueEntityId {
  static const _uuid = Uuid();

  static String generate(String prefix) => '${prefix}_${_uuid.v4()}';
}

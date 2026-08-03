enum DeviceStatus {
  working,
  defective,
  underRepair;

  bool get isDefective => this == DeviceStatus.defective;

  bool get isUnderRepair => this == DeviceStatus.underRepair;

  bool get isOperational => this == DeviceStatus.working;

  static DeviceStatus fromJson(String value) => switch (value) {
        'defective' => DeviceStatus.defective,
        'underRepair' => DeviceStatus.underRepair,
        _ => DeviceStatus.working,
      };

  String toJson() => name;
}

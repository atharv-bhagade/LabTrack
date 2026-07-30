enum DeviceStatus {
  working,
  defective;

  bool get isDefective => this == DeviceStatus.defective;

  static DeviceStatus fromJson(String value) => switch (value) {
        'defective' => DeviceStatus.defective,
        _ => DeviceStatus.working,
      };

  String toJson() => name;
}

enum UserRole {
  superAdmin,
  teacher,
  technician;

  String get label => switch (this) {
        UserRole.superAdmin => 'Super Admin',
        UserRole.teacher => 'Teacher',
        UserRole.technician => 'Technician',
      };

  static UserRole fromJson(String value) => switch (value) {
        'teacher' => UserRole.teacher,
        'technician' => UserRole.technician,
        _ => UserRole.superAdmin,
      };

  String toJson() => switch (this) {
        UserRole.superAdmin => 'superAdmin',
        UserRole.teacher => 'teacher',
        UserRole.technician => 'technician',
      };
}

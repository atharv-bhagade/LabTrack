import 'package:flutter/foundation.dart';
import 'package:hello_flutter/domain/entities/user_role.dart';

@immutable
class AppUser {
  const AppUser({
    required this.userId,
    required this.password,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.profilePicturePath,
  });

  final String userId;
  final String password;
  final String name;
  final String email;
  final String phoneNumber;
  final UserRole role;
  final String? profilePicturePath;

  AppUser copyWith({
    String? userId,
    String? password,
    String? name,
    String? email,
    String? phoneNumber,
    UserRole? role,
    String? profilePicturePath,
  }) {
    return AppUser(
      userId: userId ?? this.userId,
      password: password ?? this.password,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'password': password,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': role.toJson(),
        'profilePicturePath': profilePicturePath,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      userId: json['userId'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      role: UserRole.fromJson(json['role'] as String? ?? 'superAdmin'),
      profilePicturePath: json['profilePicturePath'] as String?,
    );
  }
}

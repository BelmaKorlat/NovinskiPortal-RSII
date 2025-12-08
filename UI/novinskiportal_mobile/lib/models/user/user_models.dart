class UserDto {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final int roleId;
  final String roleName;

  UserDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.roleId,
    required this.roleName,
  });

  factory UserDto.fromJson(Map<String, dynamic> j) => UserDto(
    id: j['id'] is int
        ? j['id'] as int
        : int.tryParse(j['id']?.toString() ?? '') ?? 0,
    firstName: (j['firstName'] ?? '') as String,
    lastName: (j['lastName'] ?? '') as String,
    username: (j['username'] ?? '') as String,
    roleId: j['roleId'] is int
        ? j['roleId'] as int
        : int.tryParse(j['roleId']?.toString() ?? '') ?? 0,
    roleName: (j['roleName'] ?? '') as String,
  );
}

class UpdateProfileRequest {
  final String firstName;
  final String lastName;
  final String username;

  const UpdateProfileRequest({
    required this.firstName,
    required this.lastName,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'username': username,
  };
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
    'confirmNewPassword': confirmNewPassword,
  };
}

class UserDto {
  final String firstName;
  final String lastName;
  final String username;
  final int roleId;
  final String roleName;

  UserDto({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.roleId,
    required this.roleName,
  });

  factory UserDto.fromJson(Map<String, dynamic> j) => UserDto(
    firstName: (j['firstName'] ?? '') as String,
    lastName: (j['lastName'] ?? '') as String,
    username: (j['username'] ?? '') as String,
    roleId: j['roleId'] is int
        ? j['roleId'] as int
        : int.tryParse(j['roleId']?.toString() ?? '') ?? 0,
    roleName: (j['roleName'] ?? '') as String,
  );
}

class AuthResponseDto {
  final String token;
  final UserDto user;

  AuthResponseDto({required this.token, required this.user});

  factory AuthResponseDto.fromJson(Map<String, dynamic> j) => AuthResponseDto(
    token: (j['token'] ?? '') as String,
    user: UserDto.fromJson(j['user'] as Map<String, dynamic>),
  );
}

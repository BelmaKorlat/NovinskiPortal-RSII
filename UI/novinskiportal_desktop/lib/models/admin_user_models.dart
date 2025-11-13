import 'package:novinskiportal_desktop/core/base_search.dart';

class UserAdminDto {
  final int id;
  final String firstName;
  final String lastName;
  final String nick;
  final String username;
  final String email;
  final int roleId;
  final String roleName;
  final bool active;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserAdminDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.nick,
    required this.username,
    required this.email,
    required this.roleId,
    required this.roleName,
    required this.active,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory UserAdminDto.fromJson(Map<String, dynamic> j) {
    return UserAdminDto(
      id: j['id'] as int,
      firstName: (j['firstName'] ?? '') as String,
      lastName: (j['lastName'] ?? '') as String,
      nick: (j['nick'] ?? '') as String,
      username: (j['username'] ?? '') as String,
      email: (j['email'] ?? '') as String,
      roleId: j['roleId'] as int,
      roleName: (j['roleName'] ?? '') as String,
      active: j['active'] as bool,
      createdAt: (DateTime.parse(j['createdAt'] as String)).toLocal(),
      lastLoginAt: j['lastLoginAt'] != null
          ? DateTime.parse(j['lastLoginAt'] as String).toLocal()
          : null,
    );
  }
}

class UserAdminSearch extends BaseSearch {
  final int? roleId;
  final bool? active;

  const UserAdminSearch({
    this.roleId,
    this.active,
    super.fts,
    super.page = 0,
    super.pageSize = 10,
    super.includeTotalCount = true,
    super.retrieveAll = false,
  });

  @override
  Map<String, dynamic> toQuery() {
    final q = super.toQuery();
    if (roleId != null) q['RoleId'] = roleId;
    if (active != null) q['Active'] = active.toString();
    return q;
  }
}

class CreateAdminUserRequest {
  final String firstName;
  final String lastName;
  final String? nick;
  final String username;
  final String email;
  final String password;
  final int roleId;
  final bool active;
  CreateAdminUserRequest({
    required this.firstName,
    required this.lastName,
    this.nick,
    required this.username,
    required this.email,
    required this.password,
    required this.roleId,
    this.active = true,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'nick': nick,
    'username': username,
    'email': email,
    'password': password,
    'roleId': roleId,
    'active': active,
  };
}

class UpdateAdminUserRequest {
  final String firstName;
  final String lastName;
  final String? nick;
  final String username;
  final String email;
  final int roleId;
  final bool active;

  UpdateAdminUserRequest({
    required this.firstName,
    required this.lastName,
    this.nick,
    required this.username,
    required this.email,
    required this.roleId,
    required this.active,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'nick': nick,
    'username': username,
    'email': email,
    'roleId': roleId,
    'active': active,
  };
}

class AdminChangePasswordRequest {
  final String newPassword;
  final String confirmNewPassword;

  AdminChangePasswordRequest({
    required this.newPassword,
    required this.confirmNewPassword,
  });

  Map<String, dynamic> toJson() => {
    'newPassword': newPassword,
    'confirmNewPassword': confirmNewPassword,
  };
}

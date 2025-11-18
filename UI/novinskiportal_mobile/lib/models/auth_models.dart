import 'user_models.dart';

class AuthResponseDto {
  final String token;
  final UserDto user;

  AuthResponseDto({required this.token, required this.user});

  factory AuthResponseDto.fromJson(Map<String, dynamic> j) => AuthResponseDto(
    token: (j['token'] ?? '') as String,
    user: UserDto.fromJson(j['user'] as Map<String, dynamic>),
  );
}

class LoginRequest {
  final String emailOrUsername;
  final String password;

  LoginRequest({required this.emailOrUsername, required this.password});

  Map<String, dynamic> toJson() => {
    'emailOrUsername': emailOrUsername,
    'password': password,
  };
}

class RegisterRequest {
  final String firstName;
  final String lastName;
  final String? nick;
  final String username;
  final String email;
  final String password;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    this.nick,
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'nick': nick,
    'username': username,
    'email': email,
    'password': password,
  };
}

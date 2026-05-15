import 'user_model.dart';

class AuthResponseModel {
  final String accessToken;
  final String tokenType;
  final UserModel? user;

  const AuthResponseModel({
    required this.accessToken,
    required this.tokenType,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      user: json['user'] != null 
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

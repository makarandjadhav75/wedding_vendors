// lib/Models/login_model.dart
class LoginModel {
  final String token;
  final int expiresAt;

  LoginModel({required this.token, required this.expiresAt});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    // defensive parsing: never assume the fields exist or are the correct type
    final token = json['token']?.toString() ?? '';
    final dynamic expiresRaw = json['expiresAt'] ?? json['expires_at'] ?? json['expiry'];

    final int expiresAt = () {
      if (expiresRaw == null) return 0;
      if (expiresRaw is int) return expiresRaw;
      if (expiresRaw is String) {
        return int.tryParse(expiresRaw) ?? 0;
      }
      return 0;
    }();

    return LoginModel(token: token, expiresAt: expiresAt);
  }

  Map<String, dynamic> toJson() => {'token': token, 'expiresAt': expiresAt};
}

// lib/models/login_response.dart

class LoginResponse {
  final String accessToken;
  final String userRole;
  final int userId;
  final String userName;

  LoginResponse({
    required this.accessToken,
    required this.userRole,
    required this.userId,
    required this.userName,
  });

  // Factory para crear la instancia desde el JSON de Laravel
  factory LoginResponse.fromJson(Map<String, dynamic> json) {

    String tempName = 'N/A';
    if (json['user'] != null) {
      if (json['user']['role'] == 'vendedor' && json['user']['vendedor'] != null) {
        tempName = json['user']['vendedor']['nombre_tienda'];
      } else if (json['user']['role'] == 'estudiante' && json['user']['estudiante'] != null) {
        tempName = json['user']['estudiante']['nombre_completo'];
      }
    }

    return LoginResponse(
      accessToken: json['access_token'],
      userId: json['user']['id'],
      userRole: json['user']['role'],
      userName: tempName,
    );
  }
}
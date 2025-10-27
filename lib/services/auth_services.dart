// lib/services/auth_service.dart

import 'dart:convert';

import '../Ambiente/ambiente.dart';
import '../Modelos/LoginModel.dart';

import 'package:http/http.dart' as http;


class AuthService {

  Future<LoginResponse> login(String email, String password) async {

    final url = Uri.parse('${Ambiente.urlServer}/api/login');

    print('Intentando conectar a: $url'); // Para depurar

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('Respuesta del servidor: ${response.statusCode}'); // Para depurar

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return LoginResponse.fromJson(responseData);
    } else {
      String errorMessage = 'Error desconocido';
      try {
        final errorBody = jsonDecode(response.body);
        errorMessage = errorBody['message'] ?? 'Error en el login';
      } catch (e) {
        errorMessage = 'Error ${response.statusCode}: ${response.body}';
      }
      throw Exception(errorMessage);
    }
  }

// (Aquí también puedes poner la función de Registro)
}
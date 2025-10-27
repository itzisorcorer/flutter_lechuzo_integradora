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

    if (response.statusCode == 200 || response.statusCode == 201) {
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

// Aquí va la función de Registro
  Future<LoginResponse> register({
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    required String nombreTienda,  // para los vendedores
    required String nombreCompleto, // para los estudiantes
}) async {
    final url = Uri.parse('${Ambiente.urlServer}/api/register');

    //construimos el cuerpo del envio del json
    Map<String, String> body = {
      'email' : email,
      'password' : password,
      'password_confirmation' : passwordConfirmation,
      'role' : role,
    };
      //añadimos los campos condicionales
    if(role == 'vendedor'){
      body['nombre_tienda'] = nombreTienda;

    }else if (role == 'estudiante'){
      body['nombre_completo'] = nombreCompleto;
    }

    //hacer la llamada
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );
    print('Respuesta de Registro: ${response.statusCode}');
    print('Cuerpo: ${response.body}');

    //en lavarel tenemo 201 cuando se crea exitosamente, so:
    if(response.statusCode == 201 ) {
      final responseData = jsonDecode(response.body);
      return LoginResponse.fromJson(responseData);

    } else{
      String errorMessage = 'Error desconocido';
      try {
        final errorBody = jsonDecode(response.body);
        //leemos los errores de laravel
        if(errorBody['errors'] != null){
          errorMessage = errorBody['errors'].values.first[0];
        }else{
          errorMessage = errorBody['message'] ?? 'Error en el registro';
        }
      } catch (e) {
        errorMessage = 'Error ${response.statusCode}: ${response.body}';
        }
        throw Exception(errorMessage);
      }
    }
}


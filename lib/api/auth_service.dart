import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_url_global.dart';

class AuthService {
  static const String apiUrlGlobal = ApiUrlGlobal.baseUrl;
  static const String baseUrl = '$apiUrlGlobal/api/v1/auth';

  Future<http.Response> login(String username, String password, String deviceToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: jsonEncode({
          'username': username,
          'password': password,
          'deviceToken': deviceToken,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      return response;
    } catch (e) {
      print('Error during login: $e');
      throw Exception('Failed to login');
    }
  }
}
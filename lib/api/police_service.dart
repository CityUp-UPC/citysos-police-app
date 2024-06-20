import 'dart:convert';
import 'package:citysos_police/api/api_url_global.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/auth_provider.dart';

class PoliceService {
  static const String apiUrlGlobal = ApiUrlGlobal.baseUrl;
  static const String baseUrl = '$apiUrlGlobal/api/v1/polices';

  Future<dynamic> joinIncident(Int incidentId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/$policeId/incident', body: {
          'incidentId': incidentId,
        }),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        String token = AuthProvider().getToken;
        throw Exception('Failed to load data ${token}');
      }
    } catch (e) {
      String token = AuthProvider().getToken;
      throw Exception('Error fetching data: $e $token');
    }

  }
}
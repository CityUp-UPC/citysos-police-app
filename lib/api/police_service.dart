import 'dart:convert';
import 'package:citysos_police/api/api_url_global.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/auth_provider.dart';

class PoliceService {
  static const String apiUrlGlobal = ApiUrlGlobal.baseUrl;
  static const String baseUrl = '$apiUrlGlobal/api/v1/polices';

  Future<int> _getPoliceId(int userId) async {
    try {
      final response = await getPoliceByUserId(userId);

      if (response != null) {
        return response['id'];
      } else {
        throw Exception('Failed to fetch citizenId');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<dynamic> getPoliceByUserId(int userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      final response = await http.get(
          Uri.parse('$baseUrl/user/$userId'),
          headers: {
            'Authorization': 'Bearer $token',
          }
      );

      final dynamic jsonData = jsonDecode(response.body);
      return jsonData;
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<dynamic> joinIncident(int incidentId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';
      int userId = prefs.getInt('userId') ?? 0;

      int policeId = await _getPoliceId(userId);

      final response = await http.post(
        Uri.parse('$baseUrl/$policeId/incident'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'incidentId': incidentId,
          },
        ),
      );

      // return jsonDecode(response.body);
      return true;
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }
}
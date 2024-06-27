import 'dart:convert';
import 'package:citysos_police/api/api_url_global.dart';
import 'package:citysos_police/api/police_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/auth_provider.dart';

class FeedsService {
  static const String apiUrlGlobal = ApiUrlGlobal.baseUrl;
  static const String baseUrl = '$apiUrlGlobal/api/v1/feeds';

  Future<List<Map<String, dynamic>>> getFeedsByIncidentId(int id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/incident/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => {
        'comment': data['comment'],
        'police': data['givenPolice'],
      }).toList().reversed.toList();
    } catch (e) {
      String token = AuthProvider().getToken;
      throw Exception('Error fetching data: $e $token');
    }
  }
  Future<int> _getPoliceId(int userId) async {
    PoliceService policeService = PoliceService();

    try {
      final response = await policeService.getPoliceByUserId(userId);

      if (response != null) {
        return response['id'];
      } else {
        throw Exception('Failed to fetch citizenId');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<http.Response> postFeed(int incidentId, String comment) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';
      int userId = prefs.getInt('userId') ?? 0;

      int policeId = await _getPoliceId(userId);

      final response = await http.post(
        Uri.parse('$apiUrlGlobal/api/v1/polices/$policeId/incident/$incidentId/feed'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'comment': comment,
        }),
      );

      return response;

    } catch (e) {
      String token = AuthProvider().getToken;
      throw Exception('Error fetching data: $e $token');
    }
  }
}

import 'dart:convert';
import 'package:citysos_police/api/api_url_global.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/auth_provider.dart';

class IncidentService {
  static const String apiUrlGlobal = ApiUrlGlobal.baseUrl;
  static const String baseUrl = '$apiUrlGlobal/api/v1/incidents';

  Future<List<Map<String, dynamic>>> getPendingIncidents() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/pendients'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => {
          'description': data['description'],
          'date': data['date'],
          'address': data['address'],
          'district': data['district'],
          'latitude': double.parse(data['latitude']),
          'longitude': double.parse(data['longitude']),
          'status': data['status'],
        }).toList();
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
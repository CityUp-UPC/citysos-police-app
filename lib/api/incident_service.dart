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

      final List<dynamic> jsonData = jsonDecode(response.body);
      // Reverse the list before returning it
      return jsonData.map((data) => {
        'id': data['id'],
        'description': data['description'],
        'date': data['date'],
        'address': data['address'],
        'district': data['district'],
        'latitude': double.parse(data['latitude']),
        'longitude': double.parse(data['longitude']),
        'status': data['status'],
      }).toList().reversed.toList();
    } catch (e) {
      String token = AuthProvider().getToken;
      throw Exception('Error fetching data: $e $token');
    }
  }
}
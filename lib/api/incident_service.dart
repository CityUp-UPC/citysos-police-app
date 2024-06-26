import 'dart:convert';
import 'package:citysos_police/api/api_url_global.dart';
import 'package:citysos_police/api/police_service.dart';
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

  Future<List<Map<String, dynamic>>> getInProgressIncidentsByPoliceId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';
      int userId = prefs.getInt('userId') ?? 0;

      int policeId = await _getPoliceId(userId);

      final response = await http.get(
        Uri.parse('$baseUrl/police/$policeId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.where((data) => data['status'] != 'COMPLETED').map((data) => {
        'id': data['id'],
        'description': data['description'],
        'date': data['date'],
        'address': data['address'],
        'district': data['district'],
        'latitude': double.parse(data['latitude']),
        'longitude': double.parse(data['longitude']),
        'status': data['status'],
        'citizen': data['citizen'],
        'police': data['police'],
      }).toList().reversed.toList();
    } catch (e) {
      String token = AuthProvider().getToken;
      throw Exception('Error fetching data: $e $token');
    }
  }

  Future<dynamic> completeIncidentById(int id) async {
    try {
      print('Completing incident with id: $id');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      final response = await http.put(
        Uri.parse('$apiUrlGlobal/api/v1/polices/incident/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 202) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  Future<dynamic> requestHelp(int id) async {
    try {
      print('Requesting help incident with id: $id');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      final response = await http.put(
        Uri.parse('$apiUrlGlobal/api/v1/polices/$id/help'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 202) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
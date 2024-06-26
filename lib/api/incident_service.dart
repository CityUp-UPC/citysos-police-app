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

  Future<List<Map<String, dynamic>>> getIncidents() async {
    try {
      print('Getting incidents');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final List<dynamic> jsonData = jsonDecode(response.body);
      // Reverse the list before returning it
      return jsonData.map((data) => {
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

  Future<List<Incident>> fetchNearIncidents(double latitude, double longitude, int km) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/near/$km?latitude=$latitude&longitude=$longitude'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      print(jsonResponse);
      return jsonResponse.map((incident) => Incident.fromJson(incident)).toList();
    } else {
      throw Exception('Failed to load incidents');
    }
  }
}

class Incident {
  final int id;
  final double latitude;
  final double longitude;
  final String description;
  final String date;
  final String address;
  final String district;
  final String status;
  final List<dynamic> police;

  Incident({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.date,
    required this.address,
    required this.district,
    required this.status,
    required this.police,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      description: json['description'],
      date: json['date'],
      address: json['address'],
      district: json['district'],
      status: json['status'],
      police: json['police'],
    );
  }
}
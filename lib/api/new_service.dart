import 'dart:convert';
import 'dart:io';
import 'package:citysos_police/api/police_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_url_global.dart';

class NewService {
  static const String apiUrlGlobal = ApiUrlGlobal.baseUrl;
  static const String baseUrl = '$apiUrlGlobal/api/v1/news';

  Future<dynamic> getAllNews() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      final response = await http.get(
          Uri.parse(baseUrl),
          headers: {
            'Authorization': 'Bearer $token',
          }
      );

      final List<dynamic> jsonData = jsonDecode(response.body);

      return jsonData.map((data) => {
        'id': data['id'],
        'description': data['description'],
        'date': data['date'],
        'police-name': data['police']['user']['firstName'] + ' ' + data['police']['user']['lastName'],
        'images': data['images'],
        'comments': data['comments'],
      }).toList().reversed.toList();
    } catch (e) {
      throw Exception('Error fetching data: $e');
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

  Future<dynamic> publishNews(String description, List<File> files) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';
      int userId = prefs.getInt('userId') ?? 0;

      int policeId = await _getPoliceId(userId);

      List<String> base64Files = [];
      for (var file in files) {
        List<int> fileBytes = await file.readAsBytes();
        String base64File = base64Encode(fileBytes);
        base64Files.add(base64File);
      }

      final response = await http.post(
        Uri.parse('$apiUrlGlobal/api/v1/polices/$policeId/news'),
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'description': description,
          'files': base64Files,
          'district': '', // Example of another field if required by your API
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error publishing news: $e');
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class ApiService {
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        return {'error': true, 'message': 'HTTP ${response.statusCode}'};
      }
    } catch (e) {
      return {'error': true, 'message': 'Connection failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final url = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body != null ? json.encode(body) : null,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        return {'error': true, 'message': 'HTTP ${response.statusCode}'};
      }
    } catch (e) {
      return {'error': true, 'message': 'Connection failed: $e'};
    }
  }
}

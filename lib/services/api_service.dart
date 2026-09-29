import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee.dart';

/// Handles all REST API communication.
/// Uses JSONPlaceholder (https://jsonplaceholder.typicode.com/) - a free
/// public fake REST API, used here to simulate an employee directory.
class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Employee>> fetchEmployees() async {
    final uri = Uri.parse('$baseUrl/users');
    try {
      final response = await http.get(uri).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Employee.fromJson(json)).toList();
      } else {
        throw ApiException(
          'Server returned status code ${response.statusCode}',
        );
      }
    } on http.ClientException {
      throw ApiException('Network error. Please check your connection.');
    } on FormatException {
      throw ApiException('Received invalid data from the server.');
    } catch (e) {
      throw ApiException('Something went wrong: ${e.toString()}');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin/admin.dart';
import '../models/admin/dashboard_stats.dart';

class AdminService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/admin';
  
  String? _token;

  // Get stored token
  Future<String?> getToken() async {
    if (_token != null) return _token;
    
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('admin_token');
    return _token;
  }

  // Save token
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_token', token);
  }

  // Clear token
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
  }

  // Get headers with token
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Admin Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('AdminService: Attempting login for $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('AdminService: Response status ${response.statusCode}');
      print('AdminService: Response body ${response.body}');

      // Check if response body is empty
      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Check if required fields exist
        if (data['token'] == null || data['admin'] == null) {
          print('AdminService: Missing token or admin in response');
          return {
            'success': false,
            'message': 'Invalid response format from server',
          };
        }
        
        await saveToken(data['token']);
        print('AdminService: Login successful, token saved');
        
        return {
          'success': true,
          'admin': Admin.fromJson(data['admin']),
          'message': data['message'] ?? 'Login successful',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('AdminService: Login error - $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Admin Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await _getHeaders(),
      );

      await clearToken();
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Logged out successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Logout failed',
        };
      }
    } catch (e) {
      await clearToken(); // Clear token anyway
      return {
        'success': true,
        'message': 'Logged out (offline)',
      };
    }
  }

  // Get Admin Profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'admin': Admin.fromJson(data['admin']),
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Get Dashboard Stats
  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return DashboardStats.fromJson(data['data']);
      } else {
        throw Exception(data['error'] ?? 'Failed to get dashboard stats');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;

    // Verify token by getting profile
    final result = await getProfile();
    return result['success'] == true;
  }

  // Generic API call method for CRUD operations
  Future<Map<String, dynamic>> apiCall(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl/$endpoint');
      
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      http.Response response;
      final headers = await _getHeaders();

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': data['data'] ?? data,
          'message': data['message'] ?? 'Success',
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? data['message'] ?? 'Request failed',
          'errors': data['messages'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
}
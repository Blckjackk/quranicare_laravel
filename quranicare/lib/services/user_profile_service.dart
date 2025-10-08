import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserProfileService {
  static const String baseUrl = 'https://quranicarelaravel-production.up.railway.app/api';
  final AuthService _authService = AuthService();
  String? _token;
  
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  /// Initialize service dengan mengambil token
  Future<void> initialize() async {
    _token = await _authService.getToken();
    print('🔑 UserProfileService initialized with token: ${_token != null ? 'YES (${_token!.substring(0, 20)}...)' : 'NO'}');
  }

  /// Get headers dengan authorization token
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// Get user profile data dari API /me
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      await initialize(); // Ensure token is loaded
      
      if (_token == null) {
        print('❌ No authentication token available');
        return null;
      }

      final url = Uri.parse('$baseUrl/me');
      print('👤 Fetching user profile from: $url');
      
      final response = await http.get(url, headers: _headers);
      
      print('📊 Profile response status: ${response.statusCode}');
      print('📋 Profile response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ User profile loaded successfully');
          return data['data'];
        } else {
          print('❌ API returned success=false or no data');
          return null;
        }
      } else if (response.statusCode == 401) {
        print('🔐 Unauthorized - token may be invalid');
        return null;
      } else {
        print('❌ Profile API error: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception getting user profile: $e');
      return null;
    }
  }

  /// Get current user name
  Future<String?> getUserName() async {
    final profile = await getUserProfile();
    return profile?['name'];
  }

  /// Get current user email  
  Future<String?> getUserEmail() async {
    final profile = await getUserProfile();
    return profile?['email'];
  }

  /// Get current user ID
  Future<int?> getUserId() async {
    final profile = await getUserProfile();
    return profile?['id'];
  }

  /// Update user profile using new /profile/edit endpoint
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? password,
    String? passwordConfirmation,
  }) async {
    try {
      await initialize(); // Ensure token is loaded
      
      if (_token == null) {
        print('❌ No authentication token available for update');
        return {
          'success': false,
          'message': 'Authentication token not found',
        };
      }

      final url = Uri.parse('$baseUrl/profile/edit');
      
      // Prepare request body - only name, email, and password fields as per backend
      final body = <String, dynamic>{
        'name': name,
        'email': email,
      };
      
      // Add password fields if provided
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
        body['password_confirmation'] = passwordConfirmation ?? password;
      }

      print('📤 Updating profile: $url');
      print('📦 Request body: ${body.keys.join(', ')}'); // Don't log password
      
      final response = await http.put(
        url,
        headers: _headers,
        body: json.encode(body),
      );
      
      print('📊 Update profile response status: ${response.statusCode}');
      print('📋 Update profile response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          print('✅ Profile updated successfully');
          return {
            'success': true,
            'message': data['message'] ?? 'Barakallahu fiik! Profile berhasil diperbarui',
            'data': data['data'],
            'alhamdulillah': data['alhamdulillah'],
          };
        } else {
          print('❌ Profile update failed: ${data['message']}');
          return {
            'success': false,
            'message': data['message'] ?? 'Update failed',
            'errors': data['errors'],
          };
        }
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        print('❌ Validation errors: ${data['errors']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Alhamdulillah, ada beberapa yang perlu diperbaiki',
          'errors': data['errors'] ?? {},
          'bismillah': data['bismillah'],
        };
      } else if (response.statusCode == 401) {
        print('🔐 Unauthorized access for profile update');
        return {
          'success': false,
          'message': 'Session expired, please login again',
        };
      } else if (response.statusCode == 500) {
        final data = json.decode(response.body);
        print('❌ Server error: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Astaghfirullah, terjadi kesalahan saat memperbarui profile',
          'istighfar': data['istighfar'],
        };
      } else {
        print('❌ Profile update API error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Server error occurred',
        };
      }
    } catch (e) {
      print('❌ Exception updating profile: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  /// Get detailed user profile from /user/profile endpoint
  Future<Map<String, dynamic>?> getDetailedUserProfile() async {
    try {
      await initialize(); // Ensure token is loaded
      
      if (_token == null) {
        print('❌ No authentication token available');
        return null;
      }

      final url = Uri.parse('$baseUrl/user/profile');
      print('👤 Fetching detailed user profile from: $url');
      
      final response = await http.get(url, headers: _headers);
      
      print('📊 Detailed profile response status: ${response.statusCode}');
      print('📋 Detailed profile response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Detailed user profile loaded successfully');
          return data['data'];
        } else {
          print('❌ API returned success=false or no data');
          return null;
        }
      } else if (response.statusCode == 401) {
        print('🔐 Unauthorized - token may be invalid');
        return null;
      } else {
        print('❌ Detailed profile API error: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception getting detailed user profile: $e');
      return null;
    }
  }

  /// Test connection to profile API
  Future<bool> testConnection() async {
    try {
      final profile = await getUserProfile();
      return profile != null;
    } catch (e) {
      print('❌ Profile connection test failed: $e');
      return false;
    }
  }
}
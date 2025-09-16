import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/audio_relax.dart';

class AudioRelaxService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Get all audio categories
  Future<List<AudioCategory>> getAllCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/audio-categories'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((json) => AudioCategory.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load audio categories');
        }
      } else {
        throw Exception('Failed to load audio categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading audio categories: $e');
    }
  }

  // Get audio by category
  Future<Map<String, dynamic>> getAudioByCategory(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/audio-relax/category/$categoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final audioList = (data['data'] as List)
              .map((json) => AudioRelax.fromJson(json))
              .toList();
          
          return {
            'audio_list': audioList,
            'category': data['category'],
            'total': data['total'] ?? audioList.length,
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to load audio by category');
        }
      } else {
        throw Exception('Failed to load audio by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading audio by category: $e');
    }
  }

  // Get single audio detail
  Future<AudioRelax> getAudioById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/audio-relax/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return AudioRelax.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load audio detail');
        }
      } else {
        throw Exception('Failed to load audio detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading audio detail: $e');
    }
  }

  // Get popular/featured audio
  Future<List<AudioRelax>> getPopularAudio() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/audio-relax/popular'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((json) => AudioRelax.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load popular audio');
        }
      } else {
        throw Exception('Failed to load popular audio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading popular audio: $e');
    }
  }

  // Search audio
  Future<List<AudioRelax>> searchAudio(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/audio-relax/search?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((json) => AudioRelax.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to search audio');
        }
      } else {
        throw Exception('Failed to search audio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching audio: $e');
    }
  }

  // Update play count
  Future<bool> updatePlayCount(int audioId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/audio-relax/$audioId/play'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Rate audio
  Future<bool> rateAudio(int audioId, double rating) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/audio-relax/$audioId/rate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'rating': rating,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
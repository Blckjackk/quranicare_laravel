import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_activity.dart';
import '../models/activity_summary.dart';

class SakinahTrackerService {
  static const String baseUrl = 'http://localhost:8000/api';
  String? _token;
  static final SakinahTrackerService _instance = SakinahTrackerService._internal();
  
  factory SakinahTrackerService() => _instance;
  
  SakinahTrackerService._internal();

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  void setToken(String token) {
    _token = token;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('auth_token', token);
    });
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // Get daily activities for a specific date
  Future<List<UserActivity>> getDailyActivities(DateTime date) async {
    try {
      final formattedDate = date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      final url = Uri.parse('$baseUrl/sakinah-tracker/daily/$formattedDate');
      
      print('Making request to: $url');
      print('Headers: $_headers');
      
      final response = await http.get(url, headers: _headers);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final activities = (data['data'] as List)
              .map((activity) => UserActivity.fromJson(activity))
              .toList();
          print('Parsed ${activities.length} activities');
          return activities;
        }
      } else if (response.statusCode == 401) {
        print('Unauthorized - using mock data for demonstration');
        return _getMockActivitiesForDate(date);
      }
      
      print('No valid data found, returning empty list');
      return [];
    } catch (e) {
      print('Error getting daily activities: $e');
      // Return mock data for testing when server is not available
      return _getMockActivitiesForDate(date);
    }
  }

  // Get monthly activity summary
  Future<ActivitySummary?> getMonthlyRecap(int year, int month) async {
    try {
      final url = Uri.parse('$baseUrl/sakinah-tracker/monthly/$year/$month');
      
      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return ActivitySummary.fromJson(data['data']);
        }
      } else if (response.statusCode == 401) {
        print('Unauthorized - using mock monthly data');
        return _getMockMonthlySummary(year, month);
      }
      
      return null;
    } catch (e) {
      print('Error getting monthly recap: $e');
      return _getMockMonthlySummary(year, month);
    }
  }

  // Get weekly activities
  Future<List<UserActivity>> getWeeklyActivities(DateTime startDate) async {
    try {
      final formattedDate = startDate.toIso8601String().split('T')[0];
      final url = Uri.parse('$baseUrl/sakinah-tracker/weekly/$formattedDate');
      
      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((activity) => UserActivity.fromJson(activity))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error getting weekly activities: $e');
      return [];
    }
  }

  // Get calendar data for a month (activity counts per day)
  Future<Map<String, int>> getCalendarData(int year, int month) async {
    try {
      final url = Uri.parse('$baseUrl/sakinah-tracker/calendar/$year/$month');
      
      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Map<String, int>.from(data['data']);
        }
      } else if (response.statusCode == 401) {
        print('Unauthorized - using mock calendar data');
        return _getMockCalendarData(year, month);
      }
      
      return {};
    } catch (e) {
      print('Error getting calendar data: $e');
      return _getMockCalendarData(year, month);
    }
  }

  // Get activity summary statistics
  Future<Map<String, dynamic>?> getActivitySummary() async {
    try {
      final url = Uri.parse('$baseUrl/sakinah-tracker/summary');
      
      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting activity summary: $e');
      return null;
    }
  }

  // Log a custom activity (for manual logging)
  Future<bool> logActivity({
    required String activityType,
    required String activityName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/sakinah-tracker/log-activity');
      
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode({
          'activity_type': activityType,
          'activity_name': activityName,
          'metadata': metadata ?? {},
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('Error logging activity: $e');
      return false;
    }
  }

  // Mock data for testing when server is not available
  List<UserActivity> _getMockActivitiesForDate(DateTime date) {
    // Only provide mock data for recent dates
    final now = DateTime.now();
    final daysDifference = now.difference(date).inDays;
    
    if (daysDifference > 7 || daysDifference < -1) {
      return []; // No activities for dates too far in the past or future
    }
    
    // Generate mock activities based on date
    List<UserActivity> mockActivities = [];
    
    if (daysDifference <= 3) { // Recent days have more activities
      mockActivities = [
        UserActivity(
          id: 1,
          activityType: 'quran_reading',
          activityName: 'Membaca Al-Qur\'an',
          activityDate: date,
          metadata: {
            'surah_name': 'Al-Fatiha',
            'verses_count': 7,
            'session_duration': 15
          },
          createdAt: DateTime(date.year, date.month, date.day, 8, 30),
        ),
        UserActivity(
          id: 2,
          activityType: 'dzikir_session',
          activityName: 'Dzikir Pagi',
          activityDate: date,
          metadata: {
            'dzikir_type': 'Tasbih',
            'repetition_count': 33,
            'session_duration': 10
          },
          createdAt: DateTime(date.year, date.month, date.day, 9, 15),
        ),
        if (daysDifference == 0) // Today has more activities
          UserActivity(
            id: 3,
            activityType: 'mood_tracking',
            activityName: 'Mencatat mood',
            activityDate: date,
            metadata: {
              'mood_type': 'senang',
              'mood_level': 4
            },
            createdAt: DateTime(date.year, date.month, date.day, 20, 0),
          ),
      ];
    } else if (daysDifference <= 5) {
      mockActivities = [
        UserActivity(
          id: 4,
          activityType: 'breathing_exercise',
          activityName: 'Latihan Pernapasan',
          activityDate: date,
          metadata: {
            'exercise_name': '4-7-8 Breathing',
            'duration': 5
          },
          createdAt: DateTime(date.year, date.month, date.day, 12, 0),
        ),
      ];
    }
    
    return mockActivities;
  }

  ActivitySummary _getMockMonthlySummary(int year, int month) {
    return ActivitySummary(
      totalActivities: 47,
      activityTypeCount: {
        'quran_reading': 15,
        'dzikir_session': 12,
        'breathing_exercise': 8,
        'mood_tracking': 7,
        'audio_listening': 3,
        'journal_entry': 2,
      },
      monthlyStats: {
        'days_active': 18,
        'longest_streak': 7,
        'current_streak': 3,
      },
      streaks: [
        ActivityStreak(
          activityType: 'quran_reading',
          currentStreak: 5,
          longestStreak: 12,
          lastActivityDate: DateTime.now().subtract(Duration(days: 1)),
        ),
        ActivityStreak(
          activityType: 'dzikir_session',
          currentStreak: 3,
          longestStreak: 8,
          lastActivityDate: DateTime.now(),
        ),
      ],
      averageActivitiesPerDay: 2.6,
      activeDays: 18,
    );
  }

  Map<String, int> _getMockCalendarData(int year, int month) {
    Map<String, int> calendarData = {};
    
    // Generate mock activity counts for the month
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final today = DateTime.now();
    
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Don't add activities for future dates
      if (date.isAfter(today)) continue;
      
      // Generate activity count based on day pattern
      int activityCount = 0;
      if (day % 7 == 0) { // Sundays - less activity
        activityCount = day <= 21 ? 1 : 0;
      } else if (day % 3 == 0) { // Every 3rd day
        activityCount = 2;
      } else if (day <= today.day && day > today.day - 7) { // Recent week
        activityCount = 3;
      } else if (day % 2 == 0) { // Even days
        activityCount = 1;
      }
      
      if (activityCount > 0) {
        calendarData[dateKey] = activityCount;
      }
    }
    
    return calendarData;
  }
}
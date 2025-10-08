import 'dart:convert';
import 'package:http/http.dart' as http;
import 'activity_logger_service.dart';
import 'auth_service.dart';

class DailyRecapService {
  static const String baseUrl = 'https://quranicarelaravel-production.up.railway.app/api';
  final ActivityLoggerService _activityLogger = ActivityLoggerService();
  final AuthService _authService = AuthService();
  String? _token;
  static final DailyRecapService _instance = DailyRecapService._internal();
  
  factory DailyRecapService() => _instance;
  
  DailyRecapService._internal();

  Future<void> initialize() async {
    _token = await _authService.getToken();
    print('🔑 DailyRecapService initialized with token: ${_token != null ? 'YES' : 'NO'}');
  }

  void setToken(String token) {
    _token = token;
    _authService.saveToken(token);
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// Get comprehensive daily recap including all activities (Primary method to use)
  Future<Map<String, dynamic>?> getComprehensiveDailyRecap({DateTime? date}) async {
    try {
      await initialize();
      
      // Get comprehensive activity data from SakinahTrackerService
      final activityRecap = await _activityLogger.getDailyRecap(date: date);
      
      if (activityRecap != null) {
        print('✅ Comprehensive daily recap loaded from activity tracker');
        return {
          'success': true,
          'data': {
            'activities': activityRecap['activities'] ?? [],
            'summary': activityRecap['summary'] ?? {},
            'streaks': activityRecap['streaks'] ?? {},
            'goals_achieved': activityRecap['goals_achieved'] ?? {},
            'date': date?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
            'has_activities': (activityRecap['summary']?['total_activities'] ?? 0) > 0,
          }
        };
      }

      // Fallback to mood-only recap if activity tracker fails
      return await getDailyMoodRecap(date: date);
    } catch (e) {
      print('❌ Error getting comprehensive daily recap: $e');
      // Fallback to mood-only recap
      return await getDailyMoodRecap(date: date);
    }
  }

  /// Get dashboard summary for home screen
  Future<Map<String, dynamic>?> getDashboardSummary() async {
    try {
      await initialize();
      
      final dashboardData = await _activityLogger.getDashboardSummary();
      
      if (dashboardData != null) {
        print('✅ Dashboard summary loaded from activity tracker');
        return {
          'success': true,
          'data': dashboardData,
        };
      }

      return null;
    } catch (e) {
      print('❌ Error getting dashboard summary: $e');
      return null;
    }
  }

  /// Get activity streaks for motivation
  Future<Map<String, int>?> getActivityStreaks() async {
    try {
      await initialize();
      
      final streaks = await _activityLogger.getActivityStreaks();
      
      if (streaks != null) {
        print('✅ Activity streaks loaded');
        return streaks;
      }

      return null;
    } catch (e) {
      print('❌ Error getting activity streaks: $e');
      return null;
    }
  }

  /// Original mood-only daily recap (kept for backward compatibility)
  Future<Map<String, dynamic>?> getDailyMoodRecap({DateTime? date}) async {
    try {
      await initialize(); // Ensure token is loaded
      
      final targetDate = date ?? DateTime.now();
      final formattedDate = targetDate.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      final url = Uri.parse('$baseUrl/mood-daily/$formattedDate');
      
      print('🔍 Fetching daily mood data for: $formattedDate');
      print('🔑 Using token: ${_token != null ? 'YES' : 'NO'}');
      print('📡 URL: $url');
      
      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Daily mood data loaded successfully with ${data['data']['moods']?.length ?? 0} entries');
          print('📦 Raw mood data from API: ${data['data']['moods']}');
          
          // Transform data untuk kompatibilitas dengan MoodEntry model
          List<dynamic> moodEntries = (data['data']['moods'] ?? []).map((mood) {
            // Map emoji based on mood type (sesuai dengan MoodSpinnerWidget)
            Map<String, String> moodEmojis = {
              'senang': '�',
              'biasa_saja': '😐',
              'sedih': '�',
              'marah': '😡',
              'murung': '�',
            };
            
            var entry = {
              'id': mood['id'] ?? 0,
              'mood_type': mood['type'] ?? '',
              'mood_label': mood['type']?.toString().toUpperCase() ?? '',
              'mood_emoji': moodEmojis[mood['type']] ?? '😐',
              'mood_score': (mood['level'] ?? 0).toDouble(),
              'notes': mood['note'],
              'timestamp': mood['created_at'] ?? DateTime.now().toIso8601String(),
            };
            print('🔄 Transformed mood entry: $entry');
            return entry;
          }).toList();
          
          return {
            'success': true,
            'data': {
              'date': formattedDate,
              'mood_entries': moodEntries,
              'daily_stats': data['data']['statistics'],
              'weekly_context': {},
              'insights': {},
            },
          };
        }
      } else if (response.statusCode == 401) {
        print('🔐 Unauthorized access - token may be invalid');
        // Try to refresh token
        await initialize();
        
        // Return empty data structure for fallback
        return {
          'success': true,
          'data': {
            'date': formattedDate,
            'mood_entries': [],
            'daily_stats': null,
            'weekly_context': {},
            'insights': {},
          },
        };
      } else if (response.statusCode == 404) {
        print('📅 No data found for this date - returning empty structure');
        return {
          'success': true,
          'data': {
            'date': formattedDate,
            'mood_entries': [],
            'daily_stats': null,
            'weekly_context': {},
            'insights': {},
          },
        };
      }
      
      // Fallback for other status codes
      print('⚠️ Unexpected response, using fallback data');
      return {
        'success': true,
        'data': {
          'date': formattedDate,
          'mood_entries': [],
          'daily_stats': null,
          'weekly_context': {},
          'insights': {},
        },
      };
    } catch (e) {
      print('❌ Error getting daily recap: $e');
      final targetDate = date ?? DateTime.now();
      final formattedDate = targetDate.toIso8601String().split('T')[0];
      return {
        'success': true,
        'data': {
          'date': formattedDate,
          'mood_entries': [],
          'daily_stats': null,
          'weekly_context': {},
          'insights': {},
        },
      };
    }
  }

  /// Create mood entry (delegate to backend)
  Future<bool> createMoodEntry({
    required String moodType,
    String? notes,
    DateTime? timestamp,
  }) async {
    try {
      await initialize();
      
      final url = Uri.parse('$baseUrl/mood');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode({
          'mood_type': moodType,
          'notes': notes,
          'created_at': timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('Error creating mood entry: $e');
      return false;
    }
  }

  /// Update an existing mood entry
  Future<bool> updateMoodEntry({
    required int entryId,
    required String moodType,
    String? notes,
  }) async {
    try {
      await initialize();
      
      final url = Uri.parse('$baseUrl/mood/$entryId');
      final response = await http.put(
        url,
        headers: _headers,
        body: json.encode({
          'mood_type': moodType,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('Error updating mood entry: $e');
      return false;
    }
  }

  /// Delete a mood entry
  Future<bool> deleteMoodEntry(int entryId) async {
    try {
      await initialize();
      
      final url = Uri.parse('$baseUrl/mood/$entryId');
      final response = await http.delete(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('Error deleting mood entry: $e');
      return false;
    }
  }

  /// Get mood insights and trends (weekly/monthly analysis)
  Future<Map<String, dynamic>?> getMoodInsights({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await initialize();
      
      final start = startDate?.toIso8601String().split('T')[0] ?? 
                   DateTime.now().subtract(Duration(days: 30)).toIso8601String().split('T')[0];
      final end = endDate?.toIso8601String().split('T')[0] ?? 
                 DateTime.now().toIso8601String().split('T')[0];
      
      final url = Uri.parse('$baseUrl/mood/insights?start_date=$start&end_date=$end');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting mood insights: $e');
      return null;
    }
  }

  /// Get monthly overview for calendar - menggunakan API mood-calendar
  Future<Map<String, dynamic>?> getMonthlyOverview(int year, int month) async {
    try {
      await initialize(); // Ensure token is loaded
      
      final url = Uri.parse('$baseUrl/mood-calendar/$year/$month');
      
      print('�️ Fetching mood calendar for: $year-$month');
      print('🔑 Using token: ${_token != null ? 'YES' : 'NO'}');
      print('📡 URL: $url');
      
      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Mood calendar loaded successfully');
          // Transform data untuk kompatibilitas dengan UI yang ada
          Map<String, dynamic> transformedData = {
            'year': data['data']['year'],
            'month': data['data']['month'],
            'calendar_data': {},
            'monthly_stats': {
              'total_days_with_mood': data['data']['total_days_with_mood'],
              'total_mood_entries': data['data']['total_mood_entries'],
            },
          };
          
          // Transform calendar_data format untuk kompatibilitas dengan MonthlyOverview.fromJson
          Map<String, dynamic> apiCalendarData = data['data']['calendar_data'] ?? {};
          Map<String, dynamic> calendarData = {};
          
          // Map emoji based on mood type (sesuai dengan MoodSpinnerWidget)
          Map<String, String> moodEmojis = {
            'senang': '�',
            'biasa_saja': '😐',
            'sedih': '�',
            'marah': '😡',
            'murung': '�',
          };

          apiCalendarData.forEach((date, dayData) {
            // Transform mood entries untuk kompatibilitas dengan MoodEntry model
            List<Map<String, dynamic>> transformedEntries = [];
            if (dayData['moods'] != null) {
              for (var mood in dayData['moods']) {
                transformedEntries.add({
                  'id': mood['id'] ?? 0,
                  'mood_type': mood['type'] ?? '',
                  'mood_label': mood['type']?.toString().toUpperCase() ?? '',
                  'mood_emoji': moodEmojis[mood['type']] ?? '😐',
                  'mood_score': (mood['level'] ?? 0).toDouble(),
                  'notes': mood['note'],
                  'timestamp': mood['created_at'] ?? DateTime.now().toIso8601String(),
                });
              }
            }
            
            // Format sesuai dengan yang diharapkan MonthlyOverview model
            calendarData[date] = {
              'mood_score': (dayData['average_level'] ?? 0.0).toDouble(),
              'mood_count': dayData['mood_count'] ?? 0,
              'dominant_mood': dayData['dominant_mood'] ?? '',
              'entries': transformedEntries,
            };
          });
          
          transformedData['calendar_data'] = calendarData;
          return transformedData;
        }
      } else if (response.statusCode == 401) {
        print('🔐 Unauthorized access for mood calendar - token may be invalid');
        await initialize(); // Try to refresh token
      } else if (response.statusCode == 404) {
        print('📅 No mood calendar data found - returning empty structure');
      }
      
      // Return empty data for fallback
      print('⚠️ Using fallback data for mood calendar');
      return {
        'year': year,
        'month': month,
        'calendar_data': {},
        'monthly_stats': {},
      };
    } catch (e) {
      print('❌ Error getting mood calendar: $e');
      // Return empty data for fallback
      return {
        'year': year,
        'month': month,
        'calendar_data': {},
        'monthly_stats': {},
      };
    }
  }

  /// Legacy method for backward compatibility - use getComprehensiveDailyRecap instead
  Future<Map<String, dynamic>?> getDailyRecap(DateTime date) async {
    return await getComprehensiveDailyRecap(date: date);
  }
}
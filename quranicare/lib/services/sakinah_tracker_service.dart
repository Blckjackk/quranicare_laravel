import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_activity.dart';
import '../models/activity_summary.dart';
import 'auth_service.dart';

class SakinahTrackerService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  final AuthService _authService = AuthService();
  String? _token;
  static final SakinahTrackerService _instance = SakinahTrackerService._internal();
  
  factory SakinahTrackerService() => _instance;
  
  SakinahTrackerService._internal();

  Future<void> initialize() async {
    _token = await _authService.getToken();
    print('🔑 SakinahTrackerService initialized with token: ${_token != null ? 'YES' : 'NO'}');
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

  // Get daily activities for a specific date
  Future<List<UserActivity>> getDailyActivities(DateTime date) async {
    try {
      final formattedDate = date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      final url = Uri.parse('$baseUrl/sakinah-tracker/daily/$formattedDate');
      
      print('Making request to: $url');
      print('Headers: $_headers');
      
      final response = await http.get(url, headers: _headers);
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final activities = (data['data'] as List)
              .map((activity) => UserActivity.fromJson(activity))
              .toList();
          print('✅ Loaded ${activities.length} real activities from API');
          return activities;
        }
      } else if (response.statusCode == 401) {
        print('🔐 Unauthorized - using mock data');
        return _getMockActivitiesForDate(date);
      }
      
      print('⚠️ No valid data found, using mock data');
      return _getMockActivitiesForDate(date);
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
    // Generate realistic mock data based on the date pattern
    // Using date hash to ensure consistent data for each date
    final dayOfMonth = date.day;
    final dayOfWeek = date.weekday;
    
    List<UserActivity> mockActivities = [];
    
    // Weekend pattern (Friday = 5, Saturday = 6, Sunday = 7)
    bool isWeekend = dayOfWeek >= 5;
    
    // More activities on weekends and certain dates
    int baseActivityCount = isWeekend ? 4 : 2;
    if (dayOfMonth % 7 == 0) baseActivityCount += 2; // Special days
    if (dayOfMonth <= 3) baseActivityCount += 1; // Beginning of month
    
    // Generate activities based on patterns
    if (baseActivityCount >= 1) {
      mockActivities.add(UserActivity(
        id: dayOfMonth * 10 + 1,
        activityType: 'quran_reading',
        activityName: 'Membaca Al-Qur\'an',
        activityDate: date,
        metadata: {
          'surah_name': _getRandomSurah(dayOfMonth),
          'verses_count': (dayOfMonth % 10) + 5,
          'session_duration': (dayOfMonth % 20) + 10
        },
        createdAt: DateTime(date.year, date.month, date.day, 6 + (dayOfMonth % 3), 30),
      ));
    }
    
    if (baseActivityCount >= 2) {
      mockActivities.add(UserActivity(
        id: dayOfMonth * 10 + 2,
        activityType: 'dzikir_session',
        activityName: 'Sesi Dzikir',
        activityDate: date,
        metadata: {
          'dzikir_type': _getRandomDzikir(dayOfMonth),
          'repetition_count': (dayOfMonth % 50) + 33,
          'session_duration': (dayOfMonth % 15) + 5
        },
        createdAt: DateTime(date.year, date.month, date.day, 9, 15 + (dayOfMonth % 30)),
      ));
    }
    
    if (baseActivityCount >= 3) {
      mockActivities.add(UserActivity(
        id: dayOfMonth * 10 + 3,
        activityType: _getRandomActivityType(dayOfMonth),
        activityName: _getRandomActivityName(dayOfMonth),
        activityDate: date,
        metadata: _getRandomMetadata(dayOfMonth),
        createdAt: DateTime(date.year, date.month, date.day, 12 + (dayOfMonth % 6), (dayOfMonth * 7) % 60),
      ));
    }
    
    if (baseActivityCount >= 4) {
      mockActivities.add(UserActivity(
        id: dayOfMonth * 10 + 4,
        activityType: 'mood_tracking',
        activityName: 'Pelacakan Mood',
        activityDate: date,
        metadata: {
          'mood_type': _getRandomMood(dayOfMonth),
          'mood_level': (dayOfMonth % 5) + 1
        },
        createdAt: DateTime(date.year, date.month, date.day, 19, (dayOfMonth * 3) % 60),
      ));
    }
    
    if (baseActivityCount >= 5) {
      mockActivities.add(UserActivity(
        id: dayOfMonth * 10 + 5,
        activityType: 'breathing_exercise',
        activityName: 'Latihan Pernapasan',
        activityDate: date,
        metadata: {
          'exercise_name': _getRandomBreathingExercise(dayOfMonth),
          'duration': (dayOfMonth % 10) + 5,
          'completed_cycles': (dayOfMonth % 15) + 10
        },
        createdAt: DateTime(date.year, date.month, date.day, 14, (dayOfMonth * 2) % 60),
      ));
    }
    
    if (baseActivityCount >= 6) {
      mockActivities.add(UserActivity(
        id: dayOfMonth * 10 + 6,
        activityType: 'journal_entry',
        activityName: 'Menulis Jurnal',
        activityDate: date,
        metadata: {
          'title': 'Refleksi Hari Ini',
          'word_count': (dayOfMonth * 5) + 50,
          'tags': ['refleksi', 'syukur']
        },
        createdAt: DateTime(date.year, date.month, date.day, 21, (dayOfMonth * 4) % 60),
      ));
    }
    
    if (baseActivityCount >= 7) {
      mockActivities.add(UserActivity(
        id: dayOfMonth * 10 + 7,
        activityType: 'audio_listening',
        activityName: 'Mendengarkan Audio',
        activityDate: date,
        metadata: {
          'audio_title': _getRandomAudio(dayOfMonth),
          'duration': (dayOfMonth % 20) + 15,
          'artist': 'Various Artists'
        },
        createdAt: DateTime(date.year, date.month, date.day, 16, (dayOfMonth * 6) % 60),
      ));
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
      
      // Generate activity count using same logic as _getMockActivitiesForDate
      final dayOfWeek = date.weekday;
      bool isWeekend = dayOfWeek >= 5; // Friday, Saturday, Sunday
      
      int baseActivityCount = isWeekend ? 4 : 2;
      if (day % 7 == 0) baseActivityCount += 2; // Special days
      if (day <= 3) baseActivityCount += 1; // Beginning of month
      if (day > today.day - 7 && day <= today.day) baseActivityCount += 1; // Recent week
      
      // Add some randomness but keep it consistent for same date
      final variance = (day * 3) % 3;
      int finalCount = (baseActivityCount + variance).clamp(0, 7);
      
      if (finalCount > 0) {
        calendarData[dateKey] = finalCount;
      }
    }
    
    return calendarData;
  }

  // Helper methods for generating realistic mock data
  String _getRandomSurah(int seed) {
    List<String> surahs = [
      'Al-Fatiha', 'Al-Baqarah', 'Ali Imran', 'An-Nisa', 'Al-Maidah',
      'Al-An\'am', 'Al-A\'raf', 'Al-Anfal', 'At-Taubah', 'Yunus',
      'Hud', 'Yusuf', 'Ar-Ra\'d', 'Ibrahim', 'Al-Hijr', 'An-Nahl'
    ];
    return surahs[seed % surahs.length];
  }

  String _getRandomDzikir(int seed) {
    List<String> dzikirs = [
      'Tasbih', 'Tahmid', 'Takbir', 'Tahlil', 'Istighfar',
      'Shalawat', 'Doa Pagi', 'Doa Petang', 'Asmaul Husna'
    ];
    return dzikirs[seed % dzikirs.length];
  }

  String _getRandomActivityType(int seed) {
    List<String> types = [
      'audio_listening', 
      'journal_entry', 
      'qalbuchat_session', 
      'psychology_assessment',
      'chatbot_session',
      'audio_relax',
      'doa_dzikir',
      'meditation',
      'therapy_session',
      'spiritual_reading',
      'gratitude_journal',
      'self_reflection'
    ];
    return types[seed % types.length];
  }

  String _getRandomActivityName(int seed) {
    Map<String, List<String>> names = {
      'audio_listening': ['Tilawah Al-Quran', 'Murottal', 'Ceramah', 'Musik Relaksasi'],
      'journal_entry': ['Refleksi Harian', 'Syukur Hari Ini', 'Evaluasi Diri', 'Catatan Ibadah'],
      'qalbuchat_session': ['Konsultasi AI', 'Sharing Curhat', 'Bimbingan Spiritual', 'Tanya Jawab'],
      'psychology_assessment': ['Tes Mood', 'Evaluasi Mental', 'Self Assessment', 'Wellness Check'],
      'chatbot_session': ['Chat dengan QalbuBot', 'Konsultasi AI', 'AI Coaching', 'Bimbingan Digital'],
      'audio_relax': ['Meditasi Audio', 'Relaksasi Suara', 'Terapi Musik', 'Suara Alam'],
      'doa_dzikir': ['Doa Pagi', 'Dzikir Petang', 'Istighfar', 'Tasbih Digital'],
      'meditation': ['Meditasi Mindfulness', 'Breathing Exercise', 'Body Scan', 'Fokus Pernapasan'],
      'therapy_session': ['Sesi Terapi', 'Konseling Online', 'Mental Health Check', 'Stress Management'],
      'spiritual_reading': ['Baca Hadist', 'Tafsir Quran', 'Kisah Nabi', 'Buku Spiritual'],
      'gratitude_journal': ['Jurnal Syukur', 'Catatan Nikmat', 'Refleksi Positif', 'Daily Gratitude'],
      'self_reflection': ['Muhasabah Diri', 'Introspeksi', 'Evaluasi Spiritual', 'Self Improvement']
    };
    
    String activityType = _getRandomActivityType(seed);
    List<String> nameList = names[activityType] ?? ['Aktivitas Spiritual'];
    return nameList[seed % nameList.length];
  }

  Map<String, dynamic> _getRandomMetadata(int seed) {
    String activityType = _getRandomActivityType(seed);
    
    switch (activityType) {
      case 'audio_listening':
        return {
          'audio_title': _getRandomAudio(seed),
          'duration': (seed % 30) + 10,
          'artist': 'Qari Internasional'
        };
      case 'journal_entry':
        return {
          'title': 'Refleksi ${seed % 10 + 1}',
          'word_count': (seed * 7) + 80,
          'tags': ['refleksi', 'syukur', 'muhasabah']
        };
      case 'qalbuchat_session':
        return {
          'message_count': (seed % 8) + 3,
          'session_duration': (seed % 15) + 5,
          'topic': 'Bimbingan Spiritual'
        };
      case 'psychology_assessment':
        return {
          'assessment_type': 'Mood Assessment',
          'score': (seed % 5) + 1,
          'completion_time': (seed % 10) + 2
        };
      case 'chatbot_session':
        return {
          'bot_name': 'QalbuBot',
          'messages_exchanged': (seed % 12) + 5,
          'session_duration': (seed % 20) + 8,
          'topic': 'Konsultasi Spiritual'
        };
      case 'audio_relax':
        return {
          'track_name': 'Relaksasi ${seed % 5 + 1}',
          'duration': (seed % 25) + 10,
          'type': 'Nature Sounds'
        };
      case 'doa_dzikir':
        return {
          'doa_type': 'Doa ${seed % 10 + 1}',
          'repetitions': (seed % 100) + 33,
          'duration': (seed % 15) + 5
        };
      case 'meditation':
        return {
          'meditation_type': 'Mindfulness',
          'duration': (seed % 20) + 10,
          'focus_level': (seed % 5) + 1
        };
      case 'therapy_session':
        return {
          'session_type': 'Individual Therapy',
          'duration': (seed % 45) + 30,
          'therapist': 'AI Counselor'
        };
      case 'spiritual_reading':
        return {
          'content_type': 'Hadist',
          'pages_read': (seed % 10) + 2,
          'reading_time': (seed % 30) + 10
        };
      case 'gratitude_journal':
        return {
          'gratitude_count': (seed % 5) + 3,
          'word_count': (seed % 100) + 50,
          'mood_after': 'grateful'
        };
      case 'self_reflection':
        return {
          'reflection_type': 'Muhasabah',
          'insights_count': (seed % 3) + 1,
          'duration': (seed % 20) + 15
        };
      default:
        return {
          'activity_duration': (seed % 30) + 5,
          'completion_status': 'completed'
        };
    }
  }

  String _getRandomMood(int seed) {
    List<String> moods = ['senang', 'tenang', 'bersyukur', 'biasa_saja', 'murung'];
    return moods[seed % moods.length];
  }

  String _getRandomBreathingExercise(int seed) {
    List<String> exercises = [
      '4-7-8 Breathing', 'Box Breathing', 'Deep Breathing', 
      'Belly Breathing', 'Counted Breathing'
    ];
    return exercises[seed % exercises.length];
  }

  String _getRandomAudio(int seed) {
    List<String> audios = [
      'Tilawah Surah Al-Kahfi', 'Murottal Merdu', 'Ceramah Singkat',
      'Dzikir Pagi', 'Asmaul Husna', 'Shalawat Nabi', 'Suara Hujan'
    ];
    return audios[seed % audios.length];
  }
}
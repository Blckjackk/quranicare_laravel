import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DailyRecapService {
  static const String baseUrl = 'http://localhost:8000/api';
  String? _token;
  static final DailyRecapService _instance = DailyRecapService._internal();
  
  factory DailyRecapService() => _instance;
  
  DailyRecapService._internal();

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('user_token'); // Sesuaikan dengan AuthService
  }

  void setToken(String token) {
    _token = token;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('user_token', token); // Sesuaikan dengan AuthService
    });
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // Get daily mood recap for a specific date
  Future<DailyMoodRecap?> getDailyRecap(DateTime date) async {
    try {
      final formattedDate = date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      final url = Uri.parse('$baseUrl/daily-recap/$formattedDate');
      
      final response = await http.get(url, headers: _headers);
      
      print('Daily recap response status: ${response.statusCode}');
      print('Daily recap response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return DailyMoodRecap.fromJson(data['data']);
        }
      } else if (response.statusCode == 401) {
        print('Unauthorized access - using mock data');
        return _getMockDailyRecap(date);
      }
      
      return _getMockDailyRecap(date);
    } catch (e) {
      print('Error getting daily recap: $e');
      return _getMockDailyRecap(date);
    }
  }

  // Get monthly mood overview
  Future<MonthlyMoodOverview?> getMonthlyOverview(int year, int month) async {
    try {
      final url = Uri.parse('$baseUrl/daily-recap/monthly/$year/$month');
      
      final response = await http.get(url, headers: _headers);
      
      print('Monthly overview response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return MonthlyMoodOverview.fromJson(data['data']);
        }
      } else if (response.statusCode == 401) {
        print('Unauthorized access - using mock data');
        return _getMockMonthlyOverview(year, month);
      }
      
      return _getMockMonthlyOverview(year, month);
    } catch (e) {
      print('Error getting monthly overview: $e');
      return _getMockMonthlyOverview(year, month);
    }
  }

  // Mock data for testing when API is not available
  DailyMoodRecap _getMockDailyRecap(DateTime date) {
    // Generate different moods based on day of month for variety
    final dayOfMonth = date.day;
    final moodTypes = ['senang', 'sedih', 'biasa_saja', 'marah', 'murung'];
    final selectedMood = moodTypes[dayOfMonth % moodTypes.length];
    
    // Generate 1-3 mood entries for the day
    final entryCount = (dayOfMonth % 3) + 1;
    final moodEntries = <MoodEntry>[];
    
    for (int i = 0; i < entryCount; i++) {
      final hour = 8 + (i * 4); // 8am, 12pm, 4pm
      moodEntries.add(MoodEntry(
        id: i + 1,
        moodType: i == 0 ? selectedMood : moodTypes[(dayOfMonth + i) % moodTypes.length],
        moodEmoji: _getMoodEmoji(i == 0 ? selectedMood : moodTypes[(dayOfMonth + i) % moodTypes.length]),
        moodLabel: _getMoodLabel(i == 0 ? selectedMood : moodTypes[(dayOfMonth + i) % moodTypes.length]),
        moodColor: _getMoodColor(i == 0 ? selectedMood : moodTypes[(dayOfMonth + i) % moodTypes.length]),
        notes: i == 0 ? 'Feeling ${_getMoodLabel(selectedMood).toLowerCase()} today' : null,
        time: '${hour.toString().padLeft(2, '0')}:00',
        timeFormatted: '${hour.toString().padLeft(2, '0')}:00',
      ));
    }

    return DailyMoodRecap(
      date: date.toIso8601String().split('T')[0],
      dateFormatted: _formatIndonesianDate(date),
      moodEntries: moodEntries,
      dailyStats: DailyMoodStats(
        totalEntries: entryCount,
        dominantMood: selectedMood,
        dominantMoodEmoji: _getMoodEmoji(selectedMood),
        dominantMoodLabel: _getMoodLabel(selectedMood),
        moodScore: _getMoodScore(selectedMood),
        moodCounts: {selectedMood: entryCount},
      ),
      weeklyContext: WeeklyContext(
        weekStart: date.subtract(Duration(days: date.weekday - 1)).toIso8601String().split('T')[0],
        weekEnd: date.add(Duration(days: 7 - date.weekday)).toIso8601String().split('T')[0],
        weeklyAverageScore: 3.5,
        weeklyTotalEntries: 15,
        daysWithRecords: 5,
        weekStats: [],
      ),
      insights: MoodInsights(
        moodStreak: dayOfMonth % 7,
        moodTrend: MoodTrend(
          trend: 'stable',
          message: 'Mood Anda cukup stabil dalam seminggu terakhir 😊',
          scores: [3.0, 3.5, 3.2, 3.8, 3.6],
        ),
        recommendations: MoodRecommendations(
          message: _getRecommendationMessage(selectedMood),
          suggestions: _getRecommendationSuggestions(selectedMood),
        ),
      ),
    );
  }

  MonthlyMoodOverview _getMockMonthlyOverview(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final calendarData = <String, MoodCalendarData>{};
    
    for (int day = 1; day <= daysInMonth; day++) {
      if (day % 3 != 0) { // Some days have no mood data
        final moodType = ['senang', 'biasa_saja', 'sedih', 'murung', 'marah'][day % 5];
        calendarData['$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}'] = MoodCalendarData(
          moodScore: _getMoodScore(moodType),
          dominantMood: moodType,
          totalEntries: (day % 3) + 1,
          emoji: _getMoodEmoji(moodType),
        );
      }
    }

    return MonthlyMoodOverview(
      month: month,
      year: year,
      monthName: _getMonthName(month),
      summary: MonthlyMoodSummary(
        totalEntries: calendarData.length * 2,
        averageScore: 3.2,
        daysWithRecords: calendarData.length,
        totalDays: daysInMonth,
        trackingPercentage: (calendarData.length / daysInMonth * 100),
      ),
      moodDistribution: {
        'senang': (calendarData.length * 0.3).round(),
        'biasa_saja': (calendarData.length * 0.25).round(),
        'sedih': (calendarData.length * 0.2).round(),
        'murung': (calendarData.length * 0.15).round(),
        'marah': (calendarData.length * 0.1).round(),
      },
      calendarData: calendarData,
      dailyStats: [],
    );
  }

  // Helper methods
  String _getMoodEmoji(String moodType) {
    switch (moodType) {
      case 'senang': return '😊';
      case 'sedih': return '😢';
      case 'biasa_saja': return '😐';
      case 'marah': return '😡';
      case 'murung': return '😟';
      default: return '😐';
    }
  }

  String _getMoodLabel(String moodType) {
    switch (moodType) {
      case 'senang': return 'Senang';
      case 'sedih': return 'Sedih';
      case 'biasa_saja': return 'Biasa Saja';
      case 'marah': return 'Marah';
      case 'murung': return 'Murung';
      default: return 'Tidak Diketahui';
    }
  }

  String _getMoodColor(String moodType) {
    switch (moodType) {
      case 'senang': return '#10B981';
      case 'sedih': return '#EF4444';
      case 'biasa_saja': return '#F59E0B';
      case 'marah': return '#DC2626';
      case 'murung': return '#6B7280';
      default: return '#6B7280';
    }
  }

  double _getMoodScore(String moodType) {
    switch (moodType) {
      case 'senang': return 5.0;
      case 'biasa_saja': return 3.0;
      case 'sedih': return 2.0;
      case 'murung': return 1.0;
      case 'marah': return 1.0;
      default: return 3.0;
    }
  }

  String _formatIndonesianDate(DateTime date) {
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return months[month - 1];
  }

  String _getRecommendationMessage(String moodType) {
    switch (moodType) {
      case 'senang': return 'Alhamdulillah! Mood Anda hari ini sangat baik.';
      case 'biasa_saja': return 'Mood Anda cukup stabil hari ini.';
      case 'sedih': return 'Hari yang berat, tapi ingat bahwa ini akan berlalu.';
      case 'murung': return 'Sepertinya Anda butuh waktu untuk diri sendiri.';
      case 'marah': return 'Sabar adalah kunci. Tenangkan diri Anda.';
      default: return 'Mulai catat mood Anda untuk insight yang lebih baik!';
    }
  }

  List<String> _getRecommendationSuggestions(String moodType) {
    switch (moodType) {
      case 'senang':
        return [
          'Bagikan kebahagiaan dengan orang lain',
          'Perbanyak syukur dan dzikir',
          'Manfaatkan mood baik untuk produktivitas'
        ];
      case 'biasa_saja':
        return [
          'Coba lakukan aktivitas yang menyenangkan',
          'Dengarkan murottal atau musik relaksasi',
          'Berinteraksi dengan teman atau keluarga'
        ];
      case 'sedih':
        return [
          'Curhat dengan orang terdekat',
          'Perbanyak istighfar dan doa',
          'Lakukan aktivitas yang Anda sukai'
        ];
      case 'murung':
        return [
          'Lakukan meditasi atau breathing exercise',
          'Jalan-jalan di alam terbuka',
          'Istirahat yang cukup'
        ];
      case 'marah':
        return [
          'Ambil napas dalam-dalam',
          'Wudhu dan sholat untuk ketenangan',
          'Hindari mengambil keputusan saat marah'
        ];
      default:
        return [
          'Luangkan waktu untuk refleksi diri',
          'Baca Al-Quran untuk ketenangan hati',
          'Lakukan dzikir dan doa'
        ];
    }
  }
}

// Data Models
class DailyMoodRecap {
  final String date;
  final String dateFormatted;
  final List<MoodEntry> moodEntries;
  final DailyMoodStats? dailyStats;
  final WeeklyContext weeklyContext;
  final MoodInsights insights;

  DailyMoodRecap({
    required this.date,
    required this.dateFormatted,
    required this.moodEntries,
    this.dailyStats,
    required this.weeklyContext,
    required this.insights,
  });

  factory DailyMoodRecap.fromJson(Map<String, dynamic> json) {
    return DailyMoodRecap(
      date: json['date'] ?? '',
      dateFormatted: json['date_formatted'] ?? '',
      moodEntries: (json['mood_entries'] as List? ?? [])
          .map((entry) => MoodEntry.fromJson(entry))
          .toList(),
      dailyStats: json['daily_stats'] != null 
          ? DailyMoodStats.fromJson(json['daily_stats'])
          : null,
      weeklyContext: WeeklyContext.fromJson(json['weekly_context'] ?? {}),
      insights: MoodInsights.fromJson(json['insights'] ?? {}),
    );
  }
}

class MoodEntry {
  final int id;
  final String moodType;
  final String moodEmoji;
  final String moodLabel;
  final String moodColor;
  final String? notes;
  final String time;
  final String timeFormatted;

  MoodEntry({
    required this.id,
    required this.moodType,
    required this.moodEmoji,
    required this.moodLabel,
    required this.moodColor,
    this.notes,
    required this.time,
    required this.timeFormatted,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] ?? 0,
      moodType: json['mood_type'] ?? '',
      moodEmoji: json['mood_emoji'] ?? '😐',
      moodLabel: json['mood_label'] ?? '',
      moodColor: json['mood_color'] ?? '#6B7280',
      notes: json['notes'],
      time: json['time'] ?? '',
      timeFormatted: json['time_formatted'] ?? '',
    );
  }
}

class DailyMoodStats {
  final int totalEntries;
  final String dominantMood;
  final String dominantMoodEmoji;
  final String dominantMoodLabel;
  final double moodScore;
  final Map<String, int> moodCounts;

  DailyMoodStats({
    required this.totalEntries,
    required this.dominantMood,
    required this.dominantMoodEmoji,
    required this.dominantMoodLabel,
    required this.moodScore,
    required this.moodCounts,
  });

  factory DailyMoodStats.fromJson(Map<String, dynamic> json) {
    return DailyMoodStats(
      totalEntries: json['total_entries'] ?? 0,
      dominantMood: json['dominant_mood'] ?? '',
      dominantMoodEmoji: json['dominant_mood_emoji'] ?? '😐',
      dominantMoodLabel: json['dominant_mood_label'] ?? '',
      moodScore: (json['mood_score'] ?? 0.0).toDouble(),
      moodCounts: Map<String, int>.from(json['mood_counts'] ?? {}),
    );
  }
}

class WeeklyContext {
  final String weekStart;
  final String weekEnd;
  final double weeklyAverageScore;
  final int weeklyTotalEntries;
  final int daysWithRecords;
  final List<dynamic> weekStats;

  WeeklyContext({
    required this.weekStart,
    required this.weekEnd,
    required this.weeklyAverageScore,
    required this.weeklyTotalEntries,
    required this.daysWithRecords,
    required this.weekStats,
  });

  factory WeeklyContext.fromJson(Map<String, dynamic> json) {
    return WeeklyContext(
      weekStart: json['week_start'] ?? '',
      weekEnd: json['week_end'] ?? '',
      weeklyAverageScore: (json['weekly_average_score'] ?? 0.0).toDouble(),
      weeklyTotalEntries: json['weekly_total_entries'] ?? 0,
      daysWithRecords: json['days_with_records'] ?? 0,
      weekStats: json['week_stats'] ?? [],
    );
  }
}

class MoodInsights {
  final int moodStreak;
  final MoodTrend moodTrend;
  final MoodRecommendations recommendations;

  MoodInsights({
    required this.moodStreak,
    required this.moodTrend,
    required this.recommendations,
  });

  factory MoodInsights.fromJson(Map<String, dynamic> json) {
    return MoodInsights(
      moodStreak: json['mood_streak'] ?? 0,
      moodTrend: MoodTrend.fromJson(json['mood_trend'] ?? {}),
      recommendations: MoodRecommendations.fromJson(json['recommendations'] ?? {}),
    );
  }
}

class MoodTrend {
  final String trend;
  final String message;
  final List<double> scores;

  MoodTrend({
    required this.trend,
    required this.message,
    required this.scores,
  });

  factory MoodTrend.fromJson(Map<String, dynamic> json) {
    return MoodTrend(
      trend: json['trend'] ?? '',
      message: json['message'] ?? '',
      scores: (json['scores'] as List<dynamic>? ?? []).map((score) => (score as num).toDouble()).toList(),
    );
  }
}

class MoodRecommendations {
  final String message;
  final List<String> suggestions;

  MoodRecommendations({
    required this.message,
    required this.suggestions,
  });

  factory MoodRecommendations.fromJson(Map<String, dynamic> json) {
    return MoodRecommendations(
      message: json['message'] ?? '',
      suggestions: List<String>.from(json['suggestions'] ?? []),
    );
  }
}

class MonthlyMoodOverview {
  final int month;
  final int year;
  final String monthName;
  final MonthlyMoodSummary summary;
  final Map<String, int> moodDistribution;
  final Map<String, MoodCalendarData> calendarData;
  final List<dynamic> dailyStats;

  MonthlyMoodOverview({
    required this.month,
    required this.year,
    required this.monthName,
    required this.summary,
    required this.moodDistribution,
    required this.calendarData,
    required this.dailyStats,
  });

  factory MonthlyMoodOverview.fromJson(Map<String, dynamic> json) {
    final calendarDataJson = json['calendar_data'] as Map<String, dynamic>? ?? {};
    final calendarData = <String, MoodCalendarData>{};
    
    calendarDataJson.forEach((key, value) {
      calendarData[key] = MoodCalendarData.fromJson(value);
    });

    return MonthlyMoodOverview(
      month: json['month'] ?? 1,
      year: json['year'] ?? DateTime.now().year,
      monthName: json['month_name'] ?? '',
      summary: MonthlyMoodSummary.fromJson(json['summary'] ?? {}),
      moodDistribution: Map<String, int>.from(json['mood_distribution'] ?? {}),
      calendarData: calendarData,
      dailyStats: json['daily_stats'] ?? [],
    );
  }
}

class MonthlyMoodSummary {
  final int totalEntries;
  final double averageScore;
  final int daysWithRecords;
  final int totalDays;
  final double trackingPercentage;

  MonthlyMoodSummary({
    required this.totalEntries,
    required this.averageScore,
    required this.daysWithRecords,
    required this.totalDays,
    required this.trackingPercentage,
  });

  factory MonthlyMoodSummary.fromJson(Map<String, dynamic> json) {
    return MonthlyMoodSummary(
      totalEntries: json['total_entries'] ?? 0,
      averageScore: (json['average_score'] ?? 0.0).toDouble(),
      daysWithRecords: json['days_with_records'] ?? 0,
      totalDays: json['total_days'] ?? 0,
      trackingPercentage: (json['tracking_percentage'] ?? 0.0).toDouble(),
    );
  }
}

class MoodCalendarData {
  final double moodScore;
  final String dominantMood;
  final int totalEntries;
  final String emoji;

  MoodCalendarData({
    required this.moodScore,
    required this.dominantMood,
    required this.totalEntries,
    required this.emoji,
  });

  factory MoodCalendarData.fromJson(Map<String, dynamic> json) {
    return MoodCalendarData(
      moodScore: (json['mood_score'] ?? 0.0).toDouble(),
      dominantMood: json['dominant_mood'] ?? '',
      totalEntries: json['total_entries'] ?? 0,
      emoji: json['emoji'] ?? '😐',
    );
  }
}
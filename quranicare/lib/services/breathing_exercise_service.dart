import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BreathingExerciseService {
  static const String baseUrl = 'http://localhost:8000/api';
  String? _token;
  static final BreathingExerciseService _instance = BreathingExerciseService._internal();
  
  factory BreathingExerciseService() => _instance;
  
  BreathingExerciseService._internal();

  // Initialize the service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('user_token');
  }

  void setToken(String token) {
    _token = token;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('user_token', token);
    });
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ============= LARAVEL BACKEND INTEGRATION =============
  
  /// Get breathing categories from Laravel backend with mock fallback
  Future<List<BreathingCategoryModel>> getDynamicCategories() async {
    try {
      final url = Uri.parse('$baseUrl/breathing-exercises/categories');
      final response = await http.get(url, headers: _headers);
      
      print('Categories response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => BreathingCategoryModel.fromJson(json))
              .toList();
        }
      }
      
      // Fallback to mock data if Laravel backend fails
      return _getMockCategories();
    } catch (e) {
      print('Error getting categories from Laravel: $e');
      // Use mock data instead of Firebase to avoid platform issues
      return _getMockCategories();
    }
  }

  /// Get breathing exercises by category from Laravel backend
  Future<List<BreathingExerciseModel>> getDynamicExercisesByCategory(int categoryId) async {
    try {
      final url = Uri.parse('$baseUrl/breathing-exercises/category/$categoryId');
      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => BreathingExerciseModel.fromJson(json))
              .toList();
        }
      }
      
      return _getMockExercises(categoryId);
    } catch (e) {
      print('Error getting exercises from Laravel: $e');
      return _getMockExercises(categoryId);
    }
  }

  /// Get all dynamic exercises
  Future<List<BreathingExerciseModel>> getAllDynamicExercises() async {
    try {
      final url = Uri.parse('$baseUrl/breathing-exercises');
      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => BreathingExerciseModel.fromJson(json))
              .toList();
        }
      }
      
      return _getMockAllExercises();
    } catch (e) {
      print('Error getting all exercises from Laravel: $e');
      return _getMockAllExercises();
    }
  }

  /// Start breathing session in Laravel backend
  Future<BreathingSessionModel?> startDynamicSession(int exerciseId, int plannedDurationMinutes) async {
    try {
      final url = Uri.parse('$baseUrl/breathing-sessions');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode({
          'breathing_exercise_id': exerciseId,
          'planned_duration_minutes': plannedDurationMinutes,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return BreathingSessionModel.fromJson(data['data']);
        }
      }
      
      return _getMockSession(exerciseId, plannedDurationMinutes);
    } catch (e) {
      print('Error starting session: $e');
      return _getMockSession(exerciseId, plannedDurationMinutes);
    }
  }

  /// Complete breathing session in Laravel backend
  Future<bool> completeDynamicSession(int sessionId, int completedCycles, {String? notes}) async {
    try {
      final url = Uri.parse('$baseUrl/breathing-sessions/$sessionId/complete');
      final response = await http.put(
        url,
        headers: _headers,
        body: json.encode({
          'completed_cycles': completedCycles,
          'notes': notes,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error completing session: $e');
      return false;
    }
  }

  /// Get user session history from Laravel backend
  Future<List<BreathingSessionModel>> getDynamicSessionHistory() async {
    try {
      final url = Uri.parse('$baseUrl/breathing-sessions/history');
      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => BreathingSessionModel.fromJson(json))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error getting session history: $e');
      return [];
    }
  }

  // ============= DYNAMIC DATA MODELS FOR LARAVEL BACKEND =============

  /// Mock data methods for Laravel backend fallback
  List<BreathingCategoryModel> _getMockCategories() {
    return [
      BreathingCategoryModel(
        id: 1,
        name: 'Ketenangan',
        description: 'Teknik pernapasan dengan dzikir untuk menenangkan hati dan pikiran',
        icon: 'spa',
        color: '#10B981',
        isActive: true,
      ),
      BreathingCategoryModel(
        id: 2,
        name: 'Fokus',
        description: 'Meningkatkan konsentrasi dan fokus pikiran dengan dzikir',
        icon: 'center_focus_strong',
        color: '#3B82F6',
        isActive: true,
      ),
      BreathingCategoryModel(
        id: 3,
        name: 'Energi',
        description: 'Membangkitkan energi dan semangat dengan dzikir',
        icon: 'bolt',
        color: '#F59E0B',
        isActive: true,
      ),
      BreathingCategoryModel(
        id: 4,
        name: 'Tidur',
        description: 'Persiapan tidur yang berkualitas dengan dzikir',
        icon: 'bedtime',
        color: '#8B5CF6',
        isActive: true,
      ),
      BreathingCategoryModel(
        id: 5,
        name: 'Stress Relief',
        description: 'Meredakan stress dan kecemasan dengan dzikir',
        icon: 'self_improvement',
        color: '#EF4444',
        isActive: true,
      ),
      BreathingCategoryModel(
        id: 6,
        name: 'Meditasi',
        description: 'Meditasi dan kontemplasi spiritual dengan dzikir',
        icon: 'psychology',
        color: '#6366F1',
        isActive: true,
      ),
    ];
  }

  List<BreathingExerciseModel> _getMockExercises(int categoryId) {
    final allExercises = _getMockAllExercises();
    return allExercises.where((e) => e.breathingCategoryId == categoryId).toList();
  }

  List<BreathingExerciseModel> _getMockAllExercises() {
    return [
      // Ketenangan (ID: 1)
      BreathingExerciseModel(
        id: 1,
        breathingCategoryId: 1,
        name: 'Istighfar Breathing',
        description: 'Teknik pernapasan dengan membaca istighfar untuk ketenangan hati dan pikiran',
        dzikirText: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
        audioPath: null,
        inhaleDuration: 4,
        holdDuration: 4,
        exhaleDuration: 6,
        totalCycleDuration: 14,
        defaultRepetitions: 20,
        isActive: true,
      ),
      BreathingExerciseModel(
        id: 2,
        breathingCategoryId: 1,
        name: 'La Hawla Wa La Quwwata',
        description: 'Pernapasan dengan kalimat tauhid untuk meredakan kecemasan',
        dzikirText: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
        audioPath: null,
        inhaleDuration: 3,
        holdDuration: 2,
        exhaleDuration: 5,
        totalCycleDuration: 10,
        defaultRepetitions: 30,
        isActive: true,
      ),
      BreathingExerciseModel(
        id: 3,
        breathingCategoryId: 1,
        name: 'Salam Breathing',
        description: 'Teknik pernapasan dengan As-Salaam (Yang Maha Pemberi Keselamatan)',
        dzikirText: 'السَّلَامُ السَّلَامُ السَّلَامُ',
        audioPath: null,
        inhaleDuration: 5,
        holdDuration: 3,
        exhaleDuration: 7,
        totalCycleDuration: 15,
        defaultRepetitions: 15,
        isActive: true,
      ),

      // Fokus (ID: 2)
      BreathingExerciseModel(
        id: 4,
        breathingCategoryId: 2,
        name: 'Box Breathing Islami',
        description: 'Pernapasan kotak dengan tasbih untuk meningkatkan fokus',
        dzikirText: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
        audioPath: null,
        inhaleDuration: 4,
        holdDuration: 4,
        exhaleDuration: 4,
        totalCycleDuration: 16,
        defaultRepetitions: 25,
        isActive: true,
      ),
      BreathingExerciseModel(
        id: 5,
        breathingCategoryId: 2,
        name: 'Al-Hakim Concentration',
        description: 'Fokus dengan asma Al-Hakim (Yang Maha Bijaksana)',
        dzikirText: 'الْحَكِيمُ الْحَكِيمُ الْحَكِيمُ',
        audioPath: null,
        inhaleDuration: 3,
        holdDuration: 6,
        exhaleDuration: 3,
        totalCycleDuration: 12,
        defaultRepetitions: 20,
        isActive: true,
      ),

      // Energi (ID: 3)
      BreathingExerciseModel(
        id: 6,
        breathingCategoryId: 3,
        name: 'Al-Qawiyy Energy Boost',
        description: 'Berenergi dengan asma Al-Qawiyy (Yang Maha Kuat)',
        dzikirText: 'الْقَوِيُّ الْقَوِيُّ الْقَوِيُّ',
        audioPath: null,
        inhaleDuration: 2,
        holdDuration: 1,
        exhaleDuration: 2,
        totalCycleDuration: 5,
        defaultRepetitions: 50,
        isActive: true,
      ),
      BreathingExerciseModel(
        id: 7,
        breathingCategoryId: 3,
        name: 'Rapid Tahlil',
        description: 'Pernapasan cepat dengan La Ilaha Illa Allah untuk energi',
        dzikirText: 'لَا إِلَهَ إِلَّا اللَّهُ',
        audioPath: null,
        inhaleDuration: 1,
        holdDuration: 0,
        exhaleDuration: 2,
        totalCycleDuration: 3,
        defaultRepetitions: 100,
        isActive: true,
      ),

      // Tidur (ID: 4)
      BreathingExerciseModel(
        id: 8,
        breathingCategoryId: 4,
        name: 'Pre-Sleep Istighfar',
        description: 'Teknik pernapasan untuk tidur nyenyak dengan istighfar',
        dzikirText: 'أَسْتَغْفِرُ اللَّهَ أَسْتَغْفِرُ اللَّهَ أَسْتَغْفِرُ اللَّهَ',
        audioPath: null,
        inhaleDuration: 4,
        holdDuration: 2,
        exhaleDuration: 8,
        totalCycleDuration: 14,
        defaultRepetitions: 21,
        isActive: true,
      ),
      BreathingExerciseModel(
        id: 9,
        breathingCategoryId: 4,
        name: 'As-Sabuur Night Calm',
        description: 'Ketenangan malam dengan asma As-Sabuur (Yang Maha Sabar)',
        dzikirText: 'الصَّبُورُ الصَّبُورُ الصَّبُورُ',
        audioPath: null,
        inhaleDuration: 3,
        holdDuration: 3,
        exhaleDuration: 9,
        totalCycleDuration: 15,
        defaultRepetitions: 15,
        isActive: true,
      ),

      // Stress Relief (ID: 5)
      BreathingExerciseModel(
        id: 10,
        breathingCategoryId: 5,
        name: 'Tawakkal Breathing',
        description: 'Melepaskan stress dengan berserah diri kepada Allah',
        dzikirText: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
        audioPath: null,
        inhaleDuration: 5,
        holdDuration: 2,
        exhaleDuration: 8,
        totalCycleDuration: 15,
        defaultRepetitions: 20,
        isActive: true,
      ),
      BreathingExerciseModel(
        id: 11,
        breathingCategoryId: 5,
        name: 'Ya Rahman Stress Relief',
        description: 'Meredakan stress dengan asma Ar-Rahman (Yang Maha Pengasih)',
        dzikirText: 'يَا رَحْمَانُ يَا رَحْمَانُ يَا رَحْمَانُ',
        audioPath: null,
        inhaleDuration: 4,
        holdDuration: 1,
        exhaleDuration: 6,
        totalCycleDuration: 11,
        defaultRepetitions: 25,
        isActive: true,
      ),

      // Meditasi (ID: 6)
      BreathingExerciseModel(
        id: 12,
        breathingCategoryId: 6,
        name: 'Deep Dhikr Meditation',
        description: 'Meditasi mendalam dengan dzikir Allah',
        dzikirText: 'اللَّهُ اللَّهُ اللَّهُ',
        audioPath: null,
        inhaleDuration: 6,
        holdDuration: 6,
        exhaleDuration: 6,
        totalCycleDuration: 18,
        defaultRepetitions: 15,
        isActive: true,
      ),
      BreathingExerciseModel(
        id: 13,
        breathingCategoryId: 6,
        name: 'Al-Wadud Heart Opening',
        description: 'Membuka hati dengan asma Al-Wadud (Yang Maha Pencinta)',
        dzikirText: 'الْوَدُودُ الْوَدُودُ الْوَدُودُ',
        audioPath: null,
        inhaleDuration: 7,
        holdDuration: 3,
        exhaleDuration: 10,
        totalCycleDuration: 20,
        defaultRepetitions: 12,
        isActive: true,
      ),
      BreathingExerciseModel(
        id: 14,
        breathingCategoryId: 6,
        name: 'Ayat Kursi Breathing',
        description: 'Teknik pernapasan khusus dengan membaca Ayat Kursi dalam hati',
        dzikirText: 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
        audioPath: null,
        inhaleDuration: 8,
        holdDuration: 4,
        exhaleDuration: 12,
        totalCycleDuration: 24,
        defaultRepetitions: 10,
        isActive: true,
      ),
    ];
  }

  BreathingSessionModel _getMockSession(int exerciseId, int plannedDurationMinutes) {
    return BreathingSessionModel(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: 1,
      breathingExerciseId: exerciseId,
      plannedDurationMinutes: plannedDurationMinutes,
      actualDurationSeconds: null,
      completedCycles: 0,
      completed: false,
      notes: null,
      startedAt: DateTime.now(),
      completedAt: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

// ============= DYNAMIC DATA MODELS FOR LARAVEL BACKEND =============

class BreathingCategoryModel {
  final int id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final bool isActive;

  BreathingCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.isActive,
  });

  factory BreathingCategoryModel.fromJson(Map<String, dynamic> json) {
    return BreathingCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'air',
      color: json['color'] ?? '#6B7280',
      isActive: json['is_active'] ?? true,
    );
  }

  // Helper method to get color as Color object
  int get colorInt {
    String hexColor = color.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}

class BreathingExerciseModel {
  final int id;
  final int breathingCategoryId;
  final String name;
  final String description;
  final String dzikirText;
  final String? audioPath;
  final int inhaleDuration;
  final int holdDuration;
  final int exhaleDuration;
  final int totalCycleDuration;
  final int defaultRepetitions;
  final bool isActive;

  BreathingExerciseModel({
    required this.id,
    required this.breathingCategoryId,
    required this.name,
    required this.description,
    required this.dzikirText,
    this.audioPath,
    required this.inhaleDuration,
    required this.holdDuration,
    required this.exhaleDuration,
    required this.totalCycleDuration,
    required this.defaultRepetitions,
    required this.isActive,
  });

  factory BreathingExerciseModel.fromJson(Map<String, dynamic> json) {
    return BreathingExerciseModel(
      id: json['id'] ?? 0,
      breathingCategoryId: json['breathing_category_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      dzikirText: json['dzikir_text'] ?? '',
      audioPath: json['audio_path'],
      inhaleDuration: json['inhale_duration'] ?? 4,
      holdDuration: json['hold_duration'] ?? 4,
      exhaleDuration: json['exhale_duration'] ?? 4,
      totalCycleDuration: json['total_cycle_duration'] ?? 12,
      defaultRepetitions: json['default_repetitions'] ?? 10,
      isActive: json['is_active'] ?? true,
    );
  }

  // Helper methods for UI
  String get patternText {
    List<String> pattern = [];
    
    if (inhaleDuration > 0) {
      pattern.add('Tarik napas $inhaleDuration detik');
    }
    
    if (holdDuration > 0) {
      pattern.add('Tahan $holdDuration detik');
    }
    
    if (exhaleDuration > 0) {
      pattern.add('Hembuskan $exhaleDuration detik');
    }
    
    return pattern.join(' → ');
  }

  int get estimatedDurationMinutes {
    return ((totalCycleDuration * defaultRepetitions) / 60).ceil();
  }

  String get formattedDuration {
    return '$estimatedDurationMinutes menit';
  }
}

class BreathingSessionModel {
  final int id;
  final int userId;
  final int breathingExerciseId;
  final int plannedDurationMinutes;
  final int? actualDurationSeconds;
  final int completedCycles;
  final bool completed;
  final String? notes;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  BreathingSessionModel({
    required this.id,
    required this.userId,
    required this.breathingExerciseId,
    required this.plannedDurationMinutes,
    this.actualDurationSeconds,
    required this.completedCycles,
    required this.completed,
    this.notes,
    required this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BreathingSessionModel.fromJson(Map<String, dynamic> json) {
    return BreathingSessionModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      breathingExerciseId: json['breathing_exercise_id'] ?? 0,
      plannedDurationMinutes: json['planned_duration_minutes'] ?? 0,
      actualDurationSeconds: json['actual_duration_seconds'],
      completedCycles: json['completed_cycles'] ?? 0,
      completed: json['completed'] ?? false,
      notes: json['notes'],
      startedAt: DateTime.parse(json['started_at'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  double get actualDurationMinutes {
    return actualDurationSeconds != null ? actualDurationSeconds! / 60.0 : 0.0;
  }

  String get formattedActualDuration {
    if (actualDurationSeconds == null) return '0 menit';
    final minutes = (actualDurationSeconds! / 60).floor();
    final seconds = actualDurationSeconds! % 60;
    if (minutes > 0) {
      return '$minutes menit $seconds detik';
    } else {
      return '$seconds detik';
    }
  }
}
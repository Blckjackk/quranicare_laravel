import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/breathing_exercise.dart';

class BreathingExerciseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  final String _breathingExercisesCollection = 'breathing_exercises';
  final String _breathingCategoriesCollection = 'breathing_categories';
  final String _userBreathingSessionsCollection = 'user_breathing_sessions';
  final String _breathingAudioFilesCollection = 'breathing_audio_files';

  // ============= BREATHING EXERCISES CRUD =============
  
  /// Get all breathing exercises
  Stream<List<BreathingExercise>> getBreathingExercises() {
    return _firestore
        .collection(_breathingExercisesCollection)
        .where('is_active', isEqualTo: true)
        .orderBy('difficulty_level')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BreathingExercise.fromFirestore(doc))
            .toList());
  }

  /// Get breathing exercises by category
  Stream<List<BreathingExercise>> getBreathingExercisesByCategory(String category) {
    return _firestore
        .collection(_breathingExercisesCollection)
        .where('category', isEqualTo: category)
        .where('is_active', isEqualTo: true)
        .orderBy('difficulty_level')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BreathingExercise.fromFirestore(doc))
            .toList());
  }

  /// Get single breathing exercise by ID
  Future<BreathingExercise?> getBreathingExerciseById(String exerciseId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_breathingExercisesCollection)
          .doc(exerciseId)
          .get();
      
      if (doc.exists) {
        return BreathingExercise.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting breathing exercise: $e');
      return null;
    }
  }

  /// Add new breathing exercise
  Future<String?> addBreathingExercise(BreathingExercise exercise) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_breathingExercisesCollection)
          .add(exercise.toMap());
      
      // Update the document with its ID
      await docRef.update({'id': docRef.id});
      
      return docRef.id;
    } catch (e) {
      print('Error adding breathing exercise: $e');
      return null;
    }
  }

  /// Update breathing exercise
  Future<bool> updateBreathingExercise(BreathingExercise exercise) async {
    try {
      await _firestore
          .collection(_breathingExercisesCollection)
          .doc(exercise.id)
          .update(exercise.toMap());
      return true;
    } catch (e) {
      print('Error updating breathing exercise: $e');
      return false;
    }
  }

  /// Delete breathing exercise (soft delete)
  Future<bool> deleteBreathingExercise(String exerciseId) async {
    try {
      await _firestore
          .collection(_breathingExercisesCollection)
          .doc(exerciseId)
          .update({
        'is_active': false,
        'updated_at': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('Error deleting breathing exercise: $e');
      return false;
    }
  }

  // ============= CATEGORIES CRUD =============
  
  /// Get all breathing categories
  Stream<List<BreathingCategory>> getBreathingCategories() {
    return _firestore
        .collection(_breathingCategoriesCollection)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BreathingCategory.fromMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>
                }))
            .toList());
  }

  /// Add breathing category
  Future<String?> addBreathingCategory(BreathingCategory category) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_breathingCategoriesCollection)
          .add(category.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding breathing category: $e');
      return null;
    }
  }

  // ============= USER SESSIONS CRUD =============
  
  /// Save user breathing session
  Future<String?> saveBreathingSession(BreathingSession session) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_userBreathingSessionsCollection)
          .add(session.toMap());
      
      // Update with generated ID
      await docRef.update({'id': docRef.id});
      
      return docRef.id;
    } catch (e) {
      print('Error saving breathing session: $e');
      return null;
    }
  }

  /// Get user breathing sessions
  Stream<List<BreathingSession>> getUserBreathingSessions(String userId) {
    return _firestore
        .collection(_userBreathingSessionsCollection)
        .where('user_id', isEqualTo: userId)
        .orderBy('session_date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BreathingSession.fromMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>
                }))
            .toList());
  }

  /// Get user sessions for specific exercise
  Stream<List<BreathingSession>> getUserSessionsForExercise(
      String userId, String exerciseId) {
    return _firestore
        .collection(_userBreathingSessionsCollection)
        .where('user_id', isEqualTo: userId)
        .where('exercise_id', isEqualTo: exerciseId)
        .orderBy('session_date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BreathingSession.fromMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>
                }))
            .toList());
  }

  // ============= ANALYTICS & STATISTICS =============
  
  /// Get user breathing statistics
  Future<Map<String, dynamic>> getUserBreathingStats(String userId) async {
    try {
      QuerySnapshot sessions = await _firestore
          .collection(_userBreathingSessionsCollection)
          .where('user_id', isEqualTo: userId)
          .get();

      int totalSessions = sessions.docs.length;
      int completedSessions = sessions.docs
          .where((doc) => (doc.data() as Map<String, dynamic>)['session_stats']['is_completed'] == true)
          .length;
      
      double totalDuration = 0;
      for (var doc in sessions.docs) {
        var data = doc.data() as Map<String, dynamic>;
        totalDuration += (data['session_stats']['actual_duration'] ?? 0);
      }

      return {
        'total_sessions': totalSessions,
        'completed_sessions': completedSessions,
        'completion_rate': totalSessions > 0 ? (completedSessions / totalSessions * 100) : 0,
        'total_duration_minutes': totalDuration / 60,
        'average_session_duration': totalSessions > 0 ? (totalDuration / totalSessions) : 0,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {};
    }
  }

  /// Get most popular exercises
  Future<List<Map<String, dynamic>>> getMostPopularExercises([int limit = 5]) async {
    try {
      QuerySnapshot sessions = await _firestore
          .collection(_userBreathingSessionsCollection)
          .get();

      Map<String, int> exerciseCount = {};
      Map<String, String> exerciseNames = {};

      for (var doc in sessions.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String exerciseId = data['exercise_id'] ?? '';
        String exerciseName = data['exercise_name'] ?? '';
        
        if (exerciseId.isNotEmpty) {
          exerciseCount[exerciseId] = (exerciseCount[exerciseId] ?? 0) + 1;
          exerciseNames[exerciseId] = exerciseName;
        }
      }

      var sortedExercises = exerciseCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedExercises.take(limit).map((entry) => {
        'exercise_id': entry.key,
        'exercise_name': exerciseNames[entry.key] ?? '',
        'session_count': entry.value,
      }).toList();
    } catch (e) {
      print('Error getting popular exercises: $e');
      return [];
    }
  }

  // ============= SAMPLE DATA CREATION =============
  
  /// Create sample breathing exercises (untuk testing)
  Future<void> createSampleBreathingExercises() async {
    try {
      // Sample Exercise 1: Subhanallah Breathing
      BreathingExercise exercise1 = BreathingExercise(
        id: '',
        name: 'Subhanallah Breathing',
        description: 'Pernapasan dengan dzikir Subhanallah dan Alhamdulillah untuk ketenangan jiwa',
        category: 'basic',
        difficultyLevel: 1,
        totalDuration: 300, // 5 menit
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        audioConfig: AudioConfig(
          inhaleAudio: 'subhanallah.mp3',
          holdAudio: null,
          exhaleAudio: 'alhamdulillah.mp3',
          backgroundMusic: 'nature_sounds.mp3',
        ),
        dzikirText: DzikirText(
          inhaleText: 'سُبْحَانَ اللهِ',
          inhaleTranslation: 'Subhanallah',
          exhaleText: 'الْحَمْدُ للهِ',
          exhaleTranslation: 'Alhamdulillah',
        ),
        breathingPattern: BreathingPattern(
          inhaleDuration: 3,
          holdDuration: 2,
          exhaleDuration: 5,
          restDuration: 1,
          totalCycleDuration: 11,
        ),
        repetition: RepetitionSettings(
          cyclesPerSession: 27,
          totalSessions: 1,
          breakBetweenSessions: 60,
        ),
      );

      // Sample Exercise 2: La ilaha illallah Breathing
      BreathingExercise exercise2 = BreathingExercise(
        id: '',
        name: 'La ilaha illallah Breathing',
        description: 'Pernapasan dengan kalimat tauhid untuk memperkuat iman',
        category: 'intermediate',
        difficultyLevel: 2,
        totalDuration: 600, // 10 menit
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        audioConfig: AudioConfig(
          inhaleAudio: 'la_ilaha.mp3',
          holdAudio: 'silent.mp3',
          exhaleAudio: 'illallah.mp3',
          backgroundMusic: 'quran_background.mp3',
        ),
        dzikirText: DzikirText(
          inhaleText: 'لَا إِلٰهَ',
          inhaleTranslation: 'La ilaha',
          exhaleText: 'إِلَّا اللهُ',
          exhaleTranslation: 'illallah',
        ),
        breathingPattern: BreathingPattern(
          inhaleDuration: 4,
          holdDuration: 3,
          exhaleDuration: 6,
          restDuration: 2,
          totalCycleDuration: 15,
        ),
        repetition: RepetitionSettings(
          cyclesPerSession: 40,
          totalSessions: 1,
          breakBetweenSessions: 90,
        ),
      );

      // Sample Exercise 3: Allahu Akbar Breathing
      BreathingExercise exercise3 = BreathingExercise(
        id: '',
        name: 'Allahu Akbar Breathing',
        description: 'Pernapasan dengan takbir untuk menguatkan hati',
        category: 'advanced',
        difficultyLevel: 3,
        totalDuration: 900, // 15 menit
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        audioConfig: AudioConfig(
          inhaleAudio: 'allahu.mp3',
          holdAudio: 'peaceful_silence.mp3',
          exhaleAudio: 'akbar.mp3',
          backgroundMusic: 'islamic_instrumental.mp3',
        ),
        dzikirText: DzikirText(
          inhaleText: 'اللهُ',
          inhaleTranslation: 'Allahu',
          exhaleText: 'أَكْبَرُ',
          exhaleTranslation: 'Akbar',
        ),
        breathingPattern: BreathingPattern(
          inhaleDuration: 5,
          holdDuration: 4,
          exhaleDuration: 7,
          restDuration: 2,
          totalCycleDuration: 18,
        ),
        repetition: RepetitionSettings(
          cyclesPerSession: 50,
          totalSessions: 1,
          breakBetweenSessions: 120,
        ),
      );

      // Add exercises to Firestore
      await addBreathingExercise(exercise1);
      await addBreathingExercise(exercise2);
      await addBreathingExercise(exercise3);

      print('Sample breathing exercises created successfully!');
    } catch (e) {
      print('Error creating sample exercises: $e');
    }
  }

  /// Create sample categories
  Future<void> createSampleCategories() async {
    try {
      List<BreathingCategory> categories = [
        BreathingCategory(
          id: 'basic',
          name: 'Dasar',
          description: 'Latihan pernapasan untuk pemula dengan dzikir sederhana',
          icon: '🌱',
          color: '#4CAF50',
          order: 1,
        ),
        BreathingCategory(
          id: 'intermediate',
          name: 'Menengah',
          description: 'Latihan pernapasan untuk yang sudah terbiasa',
          icon: '🌿',
          color: '#2196F3',
          order: 2,
        ),
        BreathingCategory(
          id: 'advanced',
          name: 'Lanjutan',
          description: 'Latihan pernapasan untuk yang berpengalaman',
          icon: '🌳',
          color: '#9C27B0',
          order: 3,
        ),
      ];

      for (var category in categories) {
        await _firestore
            .collection(_breathingCategoriesCollection)
            .doc(category.id)
            .set(category.toMap());
      }

      print('Sample categories created successfully!');
    } catch (e) {
      print('Error creating sample categories: $e');
    }
  }
}
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/breathing_exercise_db_service.dart';
import '../models/breathing_exercise_db.dart';
import '../widgets/custom_youtube_player.dart';
import 'package:audioplayers/audioplayers.dart';

class BreathingExerciseDbScreen extends StatefulWidget {
  const BreathingExerciseDbScreen({super.key});

  @override
  State<BreathingExerciseDbScreen> createState() => _BreathingExerciseDbScreenState();
}

class _BreathingExerciseDbScreenState extends State<BreathingExerciseDbScreen> {
  final BreathingExerciseService _service = BreathingExerciseService();
  int _currentStep = 0; // 0: categories, 1: exercises, 2: session setup, 3: animation
  
  List<BreathingCategoryDb> _categories = [];
  List<BreathingExerciseDb> _exercises = [];
  BreathingCategoryDb? _selectedCategory;
  BreathingExerciseDb? _selectedExercise;
  BreathingSessionDb? _currentSession;
  
  // Session configuration
  int _selectedDurationMinutes = 5;
  int _plannedRepetitions = 5;
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final categories = await _service.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadExercises(BreathingCategoryDb category) async {
    setState(() {
      _isLoading = true;
      _error = '';
      _selectedCategory = category;
    });

    try {
      final exercises = await _service.getExercisesByCategory(category.id);
      setState(() {
        _exercises = exercises;
        _currentStep = 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _startSession() async {
    if (_selectedExercise == null) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Calculate repetitions based on selected duration
      _plannedRepetitions = _selectedExercise!.getRepetitionsForMinutes(_selectedDurationMinutes);
      
      final session = await _service.startSession(
        exerciseId: _selectedExercise!.id,
        plannedDurationMinutes: _selectedDurationMinutes,
        userId: 1, // TODO: Get from auth
      );
      
      setState(() {
        _currentSession = session;
        _currentStep = 3;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F8),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error.isNotEmpty
                ? _buildErrorWidget()
                : _buildCurrentScreen(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Terjadi Kesalahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _error = '';
                _currentStep = 0;
              });
              _loadCategories();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8FA68E),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Coba Lagi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentStep) {
      case 1:
        return _buildExercisesList();
      case 2:
        return _buildSessionSetup();
      case 3:
        return BreathingAnimationDbScreen(
          exercise: _selectedExercise!,
          session: _currentSession!,
          plannedRepetitions: _plannedRepetitions,
        );
      default:
        return _buildCategoriesList();
    }
  }

  Widget _buildCategoriesList() {
    return Column(
      children: [
        // Header
        _buildHeader('Pilih Kategori Latihan'),
        
        // Categories Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildCategoryCard(category);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesList() {
    return Column(
      children: [
        // Header
        _buildHeader('Pilih Jenis Latihan', showBack: true, onBack: () {
          setState(() {
            _currentStep = 0;
          });
        }),
        
        // Exercises List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _exercises.length,
            itemBuilder: (context, index) {
              final exercise = _exercises[index];
              return _buildExerciseCard(exercise);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSessionSetup() {
    return Column(
      children: [
        // Header
        _buildHeader('Atur Sesi Latihan', showBack: true, onBack: () {
          setState(() {
            _currentStep = 1;
          });
        }),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Selected Exercise Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D5A5A).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedExercise!.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5A5A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedExercise!.description ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Pola Pernapasan: ${_selectedExercise!.breathingCycleText}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8FA68E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Duration Selection
                _buildDurationSelector(),
                
                const SizedBox(height: 24),
                
                // Dzikir Text
                if (_selectedExercise!.dzikirText.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8FA68E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF8FA68E).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dzikir yang akan dibaca:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5A5A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedExercise!.dzikirText,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2D5A5A),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                
                const Spacer(),
                
                // Start Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _startSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8FA68E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Mulai Latihan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title, {bool showBack = false, VoidCallback? onBack}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
              onPressed: onBack,
            )
          else
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
              onPressed: () => Navigator.pop(context),
            ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF2D5A5A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BreathingCategoryDb category) {
    return GestureDetector(
      onTap: () => _loadExercises(category),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D5A5A).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF8FA68E).withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                _getCategoryIcon(category.icon),
                color: const Color(0xFF8FA68E),
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D5A5A),
              ),
              textAlign: TextAlign.center,
            ),
            if (category.description != null && category.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  category.description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BreathingExerciseDb exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedExercise = exercise;
              _currentStep = 2;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5A5A),
                        ),
                      ),
                    ),
                    if (exercise.hasAudio)
                      Icon(
                        exercise.isYouTubeAudio ? Icons.music_note : Icons.audiotrack,
                        color: const Color(0xFF8FA68E),
                        size: 20,
                      ),
                  ],
                ),
                if (exercise.description != null && exercise.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    exercise.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      exercise.breathingCycleText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8FA68E).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Default: ${exercise.defaultRepetitions} siklus',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2D5A5A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D5A5A).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Durasi Latihan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5A5A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [3, 5, 7, 10, 15].map((minutes) {
              final isSelected = _selectedDurationMinutes == minutes;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDurationMinutes = minutes;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF8FA68E) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${minutes}m',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          if (_selectedExercise != null)
            Text(
              'Estimasi ${_selectedExercise!.getRepetitionsForMinutes(_selectedDurationMinutes)} siklus pernapasan',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'peaceful':
        return Icons.self_improvement;
      case 'energy':
        return Icons.flash_on;
      case 'sleep':
        return Icons.bedtime;
      case 'focus':
        return Icons.center_focus_strong;
      default:
        return Icons.air;
    }
  }
}

// Breathing Animation Screen untuk database version
class BreathingAnimationDbScreen extends StatefulWidget {
  final BreathingExerciseDb exercise;
  final BreathingSessionDb session;
  final int plannedRepetitions;

  const BreathingAnimationDbScreen({
    super.key,
    required this.exercise,
    required this.session,
    required this.plannedRepetitions,
  });

  @override
  State<BreathingAnimationDbScreen> createState() => _BreathingAnimationDbScreenState();
}

class _BreathingAnimationDbScreenState extends State<BreathingAnimationDbScreen>
    with TickerProviderStateMixin {
  
  final BreathingExerciseService _service = BreathingExerciseService();
  late AnimationController _breathingController;
  late AnimationController _timerController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _timerAnimation;
  
  String _currentPhase = 'Bersiap...';
  bool _isRunning = false;
  bool _isPaused = false;
  int _completedCycles = 0;
  int _currentCycleStep = 0; // 0: inhale, 1: hold, 2: exhale
  late int _sessionDurationSeconds;
  int _elapsedSeconds = 0;
  
  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _hasBackgroundAudio = false;

  @override
  void initState() {
    super.initState();
    _sessionDurationSeconds = widget.session.plannedDurationMinutes * 60;
    _setupAnimations();
    _setupBackgroundAudio();
  }

  void _setupAnimations() {
    _breathingController = AnimationController(
      duration: Duration(seconds: widget.exercise.inhaleDuration),
      vsync: this,
    );
    
    _timerController = AnimationController(
      duration: Duration(seconds: _sessionDurationSeconds),
      vsync: this,
    );
    
    _breathingAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    _timerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_timerController);
    
    _breathingController.addStatusListener(_handleBreathingPhase);
    _timerController.addListener(_updateElapsedTime);
  }

  Future<void> _setupBackgroundAudio() async {
    if (widget.exercise.hasAudio && !widget.exercise.isYouTubeAudio) {
      try {
        await _audioPlayer.setSource(UrlSource(widget.exercise.audioPath!));
        setState(() {
          _hasBackgroundAudio = true;
        });
      } catch (e) {
        print('Error setting up audio: $e');
      }
    }
  }

  void _handleBreathingPhase(AnimationStatus status) {
    if (!_isRunning) return;
    
    if (status == AnimationStatus.completed) {
      _moveToNextPhase();
    }
  }

  void _moveToNextPhase() {
    setState(() {
      _currentCycleStep++;
      
      if (_currentCycleStep == 1) {
        // Hold phase
        _currentPhase = _service.getBreathingPhaseText(widget.exercise, 'hold');
        _breathingController.duration = Duration(seconds: widget.exercise.holdDuration);
        _breathingController.forward();
      } else if (_currentCycleStep == 2) {
        // Exhale phase
        _currentPhase = _service.getBreathingPhaseText(widget.exercise, 'exhale');
        _breathingController.duration = Duration(seconds: widget.exercise.exhaleDuration);
        _breathingController.reverse();
      } else {
        // Complete cycle, start new one
        _completedCycles++;
        _currentCycleStep = 0;
        
        if (_completedCycles >= widget.plannedRepetitions) {
          _completeSession();
        } else {
          _startNewCycle();
        }
      }
    });
  }

  void _startNewCycle() {
    setState(() {
      _currentPhase = _service.getBreathingPhaseText(widget.exercise, 'inhale');
      _breathingController.duration = Duration(seconds: widget.exercise.inhaleDuration);
    });
    _breathingController.forward();
  }

  void _updateElapsedTime() {
    setState(() {
      _elapsedSeconds = (_timerAnimation.value * _sessionDurationSeconds).round();
    });
  }

  void _toggleBreathing() {
    setState(() {
      if (!_isRunning) {
        _isRunning = true;
        _isPaused = false;
        _currentPhase = _service.getBreathingPhaseText(widget.exercise, 'inhale');
        _breathingController.forward();
        _timerController.forward();
        if (_hasBackgroundAudio) {
          _audioPlayer.resume();
        }
      } else if (_isPaused) {
        _isPaused = false;
        _breathingController.forward();
        _timerController.forward();
        if (_hasBackgroundAudio) {
          _audioPlayer.resume();
        }
      } else {
        _isPaused = true;
        _breathingController.stop();
        _timerController.stop();
        if (_hasBackgroundAudio) {
          _audioPlayer.pause();
        }
      }
    });
  }

  Future<void> _completeSession() async {
    _isRunning = false;
    _breathingController.stop();
    _timerController.stop();
    
    if (_hasBackgroundAudio) {
      _audioPlayer.stop();
    }

    try {
      await _service.completeSession(
        sessionId: widget.session.id,
        completedCycles: _completedCycles,
        actualDurationSeconds: _elapsedSeconds,
        notes: 'Sesi selesai dengan ${_completedCycles} siklus',
      );
      
      if (mounted) {
        _showCompletionDialog();
      }
    } catch (e) {
      print('Error completing session: $e');
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Selamat!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              size: 64,
              color: Color(0xFF8FA68E),
            ),
            const SizedBox(height: 16),
            Text('Anda telah menyelesaikan latihan pernapasan dengan ${_completedCycles} siklus'),
            const SizedBox(height: 8),
            Text('Durasi: ${(_elapsedSeconds / 60).toStringAsFixed(1)} menit'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _timerController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.exercise.name,
                      style: const TextStyle(
                        color: Color(0xFF2D5A5A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.exercise.dzikirText,
                      style: const TextStyle(
                        color: Color(0xFF8FA68E),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        
        // Progress and Timer
        Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Timer Display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTime(_elapsedSeconds),
                    style: const TextStyle(
                      color: Color(0xFF8FA68E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatTime(_sessionDurationSeconds),
                    style: TextStyle(
                      color: const Color(0xFF8FA68E).withOpacity(0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress Bar
              AnimatedBuilder(
                animation: _timerAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _timerAnimation.value,
                    backgroundColor: const Color(0xFF8FA68E).withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8FA68E)),
                    minHeight: 6,
                  );
                },
              ),
              const SizedBox(height: 16),
              // Cycle Counter
              Text(
                'Siklus: $_completedCycles / ${widget.plannedRepetitions}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        // Breathing Animation
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Breathing Circle with YouTube Player for audio exercises
                if (widget.exercise.isYouTubeAudio && widget.exercise.youTubeVideoId != null)
                  Container(
                    width: 200,
                    height: 200,
                    child: CustomYouTubePlayer(
                      videoId: widget.exercise.youTubeVideoId!,
                      autoPlay: _isRunning && !_isPaused,
                    ),
                  )
                else
                  AnimatedBuilder(
                    animation: _breathingAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 300,
                        height: 300,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow effect
                            Container(
                              width: 280 * _breathingAnimation.value,
                              height: 280 * _breathingAnimation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF8FA68E).withOpacity(0.4),
                                    blurRadius: 30 * _breathingAnimation.value,
                                    spreadRadius: 15 * _breathingAnimation.value,
                                  ),
                                ],
                              ),
                            ),
                            // Inner circle
                            Container(
                              width: 200 * _breathingAnimation.value,
                              height: 200 * _breathingAnimation.value,
                              decoration: const BoxDecoration(
                                color: Color(0xFF8FA68E),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.air,
                                size: 80 * _breathingAnimation.value,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                
                const SizedBox(height: 40),
                
                // Phase Text
                Text(
                  _currentPhase,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5A5A),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Control Button
                GestureDetector(
                  onTap: _toggleBreathing,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: const Color(0xFF8FA68E),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8FA68E).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRunning && !_isPaused ? Icons.pause : Icons.play_arrow,
                      color: const Color(0xFF8FA68E),
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../utils/asset_manager.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> {
  int _currentStep = 0; // 0: main, 1: session options, 2: exercise types, 3: animation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F8),
      body: SafeArea(
        child: _buildCurrentScreen(),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentStep) {
      case 1:
        return _buildSessionOptions();
      case 2:
        return _buildExerciseTypes();
      case 3:
        return const BreathingAnimationScreen();
      default:
        return _buildMainMenu();
    }
  }

  Widget _buildMainMenu() {
    return Column(
      children: [
        // Header with back button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Breathing Exercise',
                  style: TextStyle(
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
        ),
        
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lotus decoration
                Container(
                  width: 200,
                  height: 150,
                  child: CustomPaint(
                    painter: LotusPainter(),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Session options
                _buildSessionCard(
                  'Clear Mind',
                  'Pilih Jenis Latihan',
                  onTap: () => setState(() => _currentStep = 2),
                ),
                
                const SizedBox(height: 16),
                
                _buildSessionCard(
                  '7 Menit',
                  'Total Waktu Latihan',
                  onTap: () => setState(() => _currentStep = 1),
                ),
                
                const SizedBox(height: 16),
                
                _buildSessionCard(
                  'Murottal',
                  'Background Audio',
                  onTap: () => setState(() => _currentStep = 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(String title, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D5A5A).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A5A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8FA68E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionOptions() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
                onPressed: () => setState(() => _currentStep = 0),
              ),
              const Expanded(
                child: Text(
                  'Session Options',
                  style: TextStyle(
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
        ),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeOption('Inhale', '4 seconds'),
                const SizedBox(height: 20),
                _buildTimeOption('Hold', '4 seconds'),
                const SizedBox(height: 20),
                _buildTimeOption('Exhale', '4 seconds'),
                const SizedBox(height: 40),
                
                ElevatedButton(
                  onPressed: () => setState(() => _currentStep = 2),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8FA68E),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildTimeOption(String label, String time) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D5A5A),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF8FA68E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTypes() {
    final exercises = [
      'Clear Mind', 'Calmness', 'Relaxation', 'Energy', 'No Stress', 'Custom'
    ];
    
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
                onPressed: () => setState(() => _currentStep = 1),
              ),
              const Expanded(
                child: Text(
                  'Choose Exercise Type',
                  style: TextStyle(
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
        ),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: exercises.map((exercise) {
                return GestureDetector(
                  onTap: () => setState(() => _currentStep = 3),
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
                    child: Center(
                      child: Text(
                        exercise,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D5A5A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// Breathing Animation Screen (Image 4)
class BreathingAnimationScreen extends StatefulWidget {
  const BreathingAnimationScreen({super.key});

  @override
  State<BreathingAnimationScreen> createState() => _BreathingAnimationScreenState();
}

class _BreathingAnimationScreenState extends State<BreathingAnimationScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _breathingController;
  late AnimationController _timerController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _timerAnimation;
  
  int _totalTime = 10;
  String _currentPhase = 'Tarik Napas';
  bool _isRunning = false;
  
  @override
  void initState() {
    super.initState();
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _timerController = AnimationController(
      duration: Duration(seconds: _totalTime * 60),
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
    
    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentPhase = 'Hembuskan';
        });
        _breathingController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _currentPhase = 'Tarik Napas';
        });
        _breathingController.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _breathingController.dispose();
    _timerController.dispose();
    super.dispose();
  }
  
  void _toggleBreathing() {
    setState(() {
      _isRunning = !_isRunning;
    });
    
    if (_isRunning) {
      _breathingController.forward();
      _timerController.forward();
    } else {
      _breathingController.stop();
      _timerController.stop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with back button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Breathing Islami Exercise',
                  style: TextStyle(
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
        ),
        
        // Timer Progress
        Container(
          margin: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(
                '05:02',
                style: TextStyle(
                  color: const Color(0xFF8FA68E),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: AnimatedBuilder(
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
                ),
              ),
              Text(
                '10:00',
                style: TextStyle(
                  color: const Color(0xFF8FA68E).withOpacity(0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
                // Breathing Circle Animation
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
                          // Heart image with color overlay
                          Container(
                            width: 200 * _breathingAnimation.value,
                            height: 200 * _breathingAnimation.value,
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF8FA68E), // Sage green color
                                BlendMode.srcATop,
                              ),
                              child: Image.asset(
                                AssetManager.heartIcon, // Heart icon
                                width: 200 * _breathingAnimation.value,
                                height: 200 * _breathingAnimation.value,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback heart shape
                                  return Container(
                                    width: 200 * _breathingAnimation.value,
                                    height: 200 * _breathingAnimation.value,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF8FA68E),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.favorite,
                                      size: 100 * _breathingAnimation.value,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
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
                
                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Previous
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8FA68E),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    
                    // Play/Pause
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
                        ),
                        child: Icon(
                          _isRunning ? Icons.pause : Icons.play_arrow,
                          color: const Color(0xFF8FA68E),
                          size: 40,
                        ),
                      ),
                    ),
                    
                    // Next
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8FA68E),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.skip_next,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Painters
class LotusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8FA68E).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw lotus petals
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180);
      final x = centerX + 60 * math.cos(angle);
      final y = centerY + 40 * math.sin(angle);
      
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 40, height: 80),
        paint,
      );
    }
    
    // Draw center circle
    canvas.drawCircle(
      Offset(centerX, centerY),
      30,
      paint..color = const Color(0xFF2D5A5A).withOpacity(0.8),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BreathingCirclePainter extends CustomPainter {
  final double progress;

  BreathingCirclePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 3;
    final currentRadius = maxRadius * progress;

    // Outer circle (light)
    final outerPaint = Paint()
      ..color = const Color(0xFF8FA68E).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, currentRadius + 20, outerPaint);

    // Inner circle (main)
    final innerPaint = Paint()
      ..color = const Color(0xFF8FA68E)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, currentRadius, innerPaint);

    // Center number
    final textPainter = TextPainter(
      text: TextSpan(
        text: '3',
        style: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(BreathingCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

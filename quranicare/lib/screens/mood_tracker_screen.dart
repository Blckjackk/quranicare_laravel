import 'package:flutter/material.dart';
import 'dart:math' as math;

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  int selectedMoodIndex = 2; // Default to neutral (middle)
  bool isSpinning = false;

  final List<MoodOption> moods = [
    MoodOption(
      emoji: '😢',
      label: 'Sangat Sedih',
      color: const Color(0xFFFF6B6B),
      angle: 0,
    ),
    MoodOption(
      emoji: '😔',
      label: 'Sedih',
      color: const Color(0xFFFF8E53),
      angle: 72,
    ),
    MoodOption(
      emoji: '😐',
      label: 'Biasa Saja',
      color: const Color(0xFFFFD93D),
      angle: 144,
    ),
    MoodOption(
      emoji: '😊',
      label: 'Senang',
      color: const Color(0xFF6BCF7F),
      angle: 216,
    ),
    MoodOption(
      emoji: '😁',
      label: 'Sangat Senang',
      color: const Color(0xFF4ECDC4),
      angle: 288,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (isSpinning) return;
    
    setState(() {
      isSpinning = true;
    });

    _rotationController.reset();
    _rotationController.forward().then((_) {
      // Random selection after spin
      final random = math.Random();
      setState(() {
        selectedMoodIndex = random.nextInt(moods.length);
        isSpinning = false;
      });
    });
  }

  void _saveMood() {
    // Save mood logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mood "${moods[selectedMoodIndex].label}" berhasil disimpan!'),
        backgroundColor: const Color(0xFF8FA68E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    
    Navigator.pop(context, moods[selectedMoodIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8F8),
              Color(0xFFE8F5E8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2D5A5A).withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF2D5A5A),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Bagaimana Perasaan\nKamu Hari Ini??',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5A5A),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Current Mood Display
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: moods[selectedMoodIndex].color.withOpacity(0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: moods[selectedMoodIndex].color.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          moods[selectedMoodIndex].emoji,
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              Text(
                moods[selectedMoodIndex].label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: moods[selectedMoodIndex].color,
                ),
              ),

              const SizedBox(height: 60),

              // Mood Wheel
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _spinWheel,
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF2D5A5A),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: CustomPaint(
                              painter: MoodWheelPainter(
                                moods: moods,
                                selectedIndex: selectedMoodIndex,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Pointer indicator
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF8FA68E),
                  shape: BoxShape.circle,
                ),
              ),

              // Save Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveMood,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8FA68E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFF8FA68E).withOpacity(0.3),
                    ),
                    child: const Text(
                      'Simpan Mood Saya',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MoodOption {
  final String emoji;
  final String label;
  final Color color;
  final double angle;

  MoodOption({
    required this.emoji,
    required this.label,
    required this.color,
    required this.angle,
  });
}

class MoodWheelPainter extends CustomPainter {
  final List<MoodOption> moods;
  final int selectedIndex;

  MoodWheelPainter({
    required this.moods,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    const sweepAngle = 2 * math.pi / 5; // 72 degrees per section
    
    for (int i = 0; i < moods.length; i++) {
      final mood = moods[i];
      final startAngle = i * sweepAngle - math.pi / 2; // Start from top
      
      // Draw sector
      final paint = Paint()
        ..color = mood.color
        ..style = PaintingStyle.fill;
      
      final path = Path();
      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
      );
      path.lineTo(center.dx, center.dy);
      path.close();
      
      canvas.drawPath(path, paint);
      
      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      
      canvas.drawPath(path, borderPaint);
      
      // Draw emoji
      final emojiAngle = startAngle + sweepAngle / 2;
      final emojiRadius = radius * 0.7;
      final emojiX = center.dx + emojiRadius * math.cos(emojiAngle);
      final emojiY = center.dy + emojiRadius * math.sin(emojiAngle);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: mood.emoji,
          style: const TextStyle(fontSize: 32),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          emojiX - textPainter.width / 2,
          emojiY - textPainter.height / 2,
        ),
      );
    }
    
    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 30, centerPaint);
    
    final centerBorderPaint = Paint()
      ..color = const Color(0xFF8FA68E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    canvas.drawCircle(center, 30, centerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

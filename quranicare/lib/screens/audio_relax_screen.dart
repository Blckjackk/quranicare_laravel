import 'package:flutter/material.dart';
import 'dart:math' as math;

class AudioRelaxScreen extends StatefulWidget {
  const AudioRelaxScreen({super.key});

  @override
  State<AudioRelaxScreen> createState() => _AudioRelaxScreenState();
}

class _AudioRelaxScreenState extends State<AudioRelaxScreen> {
  int _currentScreen = 0; // 0: main, 1: category, 2: player
  String _selectedCategory = '';
  String _selectedAudio = '';

  final List<AudioCategory> _categories = [
    AudioCategory(
      name: 'Nasheed',
      image: 'assets/nasheed_bg.jpg',
      color: const Color(0xFF2D5A5A),
      audios: [
        AudioTrack(name: 'Muhammad Al Muqit', duration: '4:32'),
        AudioTrack(name: 'Sholawat Badar', duration: '3:45'),
        AudioTrack(name: 'Syair I\'irof', duration: '5:12'),
        AudioTrack(name: 'Sholawat Nariyah', duration: '3:28'),
        AudioTrack(name: 'Kun Anta', duration: '4:15'),
        AudioTrack(name: 'My Hope', duration: '3:52'),
        AudioTrack(name: 'The Way of Tears', duration: '4:08'),
        AudioTrack(name: 'Weeding Nasheed', duration: '3:33'),
      ],
    ),
    AudioCategory(
      name: 'Dzikir dan Doa',
      image: 'assets/dzikir_bg.jpg',
      color: const Color(0xFF8FA68E),
      audios: [
        AudioTrack(name: 'Hasan Al Basma', duration: '8:45'),
        AudioTrack(name: 'Merdu Bacaan Al Matsurat Dzikir Pagi', duration: '12:30'),
        AudioTrack(name: 'Dzikir Petang', duration: '10:15'),
        AudioTrack(name: 'Asmaul Husna', duration: '6:20'),
        AudioTrack(name: 'Istighfar 100x', duration: '5:45'),
      ],
    ),
    AudioCategory(
      name: 'Murottal',
      image: 'assets/quran_bg.jpg',
      color: const Color(0xFF2D5A5A),
      audios: [
        AudioTrack(name: 'Surah Al Fatihah', duration: '1:30'),
        AudioTrack(name: 'Surah Al Baqarah', duration: '87:45'),
        AudioTrack(name: 'Surah Ali Imran', duration: '58:32'),
        AudioTrack(name: 'Surah An Nisa', duration: '67:12'),
        AudioTrack(name: 'Surah Al Maidah', duration: '48:25'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F8),
      body: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case 1:
        return _buildCategoryScreen();
      case 2:
        return _buildPlayerScreen();
      default:
        return _buildMainScreen();
    }
  }

  // Main Screen (Image 1)
  Widget _buildMainScreen() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Audio Relax Islami',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5A5A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance the back button
              ],
            ),
          ),

          // Headphones Icon
          Container(
            width: 120,
            height: 120,
            margin: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: const Color(0xFF8FA68E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Headphones main body
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D5A5A),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                // Left ear cup
                Positioned(
                  left: 15,
                  child: Container(
                    width: 25,
                    height: 35,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE67E22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // Right ear cup
                Positioned(
                  right: 15,
                  child: Container(
                    width: 25,
                    height: 35,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE67E22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category.name;
                      _currentScreen = 1;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5A5A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [
                                category.color.withOpacity(0.8),
                                category.color,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: category.color.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Background pattern
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: AudioWavePainter(category.color),
                                ),
                              ),
                              // Category text overlay
                              Center(
                                child: Text(
                                  category.name.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Category Screen (Image 2)
  Widget _buildCategoryScreen() {
    final category = _categories.firstWhere((cat) => cat.name == _selectedCategory);
    
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
                  onPressed: () => setState(() => _currentScreen = 0),
                ),
                const Expanded(
                  child: Text(
                    'Audio Relax Islami',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5A5A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF8FA68E).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF8FA68E)),
            ),
            child: Text(
              _selectedCategory,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8FA68E),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Featured Audio Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  category.color.withOpacity(0.8),
                  category.color,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: category.color.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: AudioWavePainter(Colors.white.withOpacity(0.3)),
                  ),
                ),
                // Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _selectedCategory.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+ RAIN',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MUHAMMAD AL MUQIT',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Audio List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: category.audios.length,
              itemBuilder: (context, index) {
                final audio = category.audios[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAudio = audio.name;
                      _currentScreen = 2;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2D5A5A).withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Green indicator line
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8FA68E),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Audio info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                audio.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D5A5A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                audio.duration,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF8FA68E).withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Play icon
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8FA68E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Color(0xFF8FA68E),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Lainnya button
          Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Lainnya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8FA68E),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 30,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8FA68E),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Player Screen (Image 3)
  Widget _buildPlayerScreen() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
                  onPressed: () => setState(() => _currentScreen = 1),
                ),
                const Expanded(
                  child: Text(
                    'Audio Relax Islami',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5A5A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF8FA68E).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF8FA68E)),
            ),
            child: Text(
              _selectedCategory,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8FA68E),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Album Art
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2D5A5A),
                  Color(0xFF8FA68E),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D5A5A).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: AudioWavePainter(Colors.white.withOpacity(0.2)),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _selectedCategory.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+ RAIN',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Currently Playing
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D5A5A).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              _selectedAudio.isNotEmpty ? _selectedAudio : 'Sholawat Badar',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D5A5A),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 40),

          // Audio Visualizer
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 150,
            child: CustomPaint(
              painter: AudioVisualizerPainter(),
              size: Size.infinite,
            ),
          ),

          const SizedBox(height: 40),

          // Audio Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Shuffle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D5A5A).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shuffle,
                  color: Color(0xFF8FA68E),
                  size: 24,
                ),
              ),
              
              // Previous
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF8FA68E),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8FA68E).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              
              // Play/Pause
              Container(
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
                      color: const Color(0xFF8FA68E).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.pause,
                  color: Color(0xFF8FA68E),
                  size: 40,
                ),
              ),
              
              // Next
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF8FA68E),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8FA68E).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.skip_next,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              
              // Repeat
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D5A5A).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.repeat,
                  color: Color(0xFF8FA68E),
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Progress Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                const Text(
                  '06:02',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8FA68E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8FA68E).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.6,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF8FA68E),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  '10:00',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8FA68E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Description Card
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hikmah Ketenangan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5A5A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sholawat Badar bukan sekadar lagu religi, ia adalah penawar hati, tempat kita menemukan kedalamaan saat dunia terasa rumit. Melantunkannya mengingatkan kita untuk bersyukur dengan kehidupan, dan mengusir pikiran negatif. Ini adalah cara kita mengasihkannya mental, menemukan harapan, dan hidup dengan penuh tenang.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data Models
class AudioCategory {
  final String name;
  final String image;
  final Color color;
  final List<AudioTrack> audios;

  AudioCategory({
    required this.name,
    required this.image,
    required this.color,
    required this.audios,
  });
}

class AudioTrack {
  final String name;
  final String duration;

  AudioTrack({
    required this.name,
    required this.duration,
  });
}

// Custom Painters
class AudioWavePainter extends CustomPainter {
  final Color color;

  AudioWavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    for (int i = 0; i < size.width; i += 20) {
      final y = size.height / 2 + math.sin((i / size.width) * 4 * math.pi) * 20;
      if (i == 0) {
        path.moveTo(i.toDouble(), y);
      } else {
        path.lineTo(i.toDouble(), y);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AudioVisualizerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8FA68E)
      ..style = PaintingStyle.fill;

    final paintLight = Paint()
      ..color = const Color(0xFF8FA68E).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final barWidth = size.width / 50;
    final random = math.Random(42); // Fixed seed for consistent pattern
    
    for (int i = 0; i < 50; i++) {
      final height = random.nextDouble() * size.height;
      final x = i * barWidth;
      
      // Use different opacity based on position for wave effect
      final normalizedPos = i / 50.0;
      final wave = math.sin(normalizedPos * math.pi);
      final currentPaint = wave > 0.5 ? paint : paintLight;
      
      canvas.drawRect(
        Rect.fromLTWH(x, size.height - height, barWidth - 2, height),
        currentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

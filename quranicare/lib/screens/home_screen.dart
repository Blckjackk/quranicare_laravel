import 'package:flutter/material.dart';
import 'mood_tracker_screen.dart';
import '../utils/asset_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _selectedMood = -1; // -1 means no mood selected

  final List<MoodData> _moods = [
    MoodData(emoji: AssetManager.moodSad, color: const Color(0xFF8FA68E), label: 'Sedih'),
    MoodData(emoji: AssetManager.moodDown, color: const Color(0xFF8FA68E), label: 'Down'),
    MoodData(emoji: AssetManager.moodNeutral, color: const Color(0xFF8FA68E), label: 'Biasa'),
    MoodData(emoji: AssetManager.moodHappy, color: const Color(0xFF8FA68E), label: 'Senang'),
    MoodData(emoji: AssetManager.moodHappy, color: const Color(0xFF8FA68E), label: 'Bahagia'),
  ];

  final List<FeatureData> _features = [
    FeatureData(
      icon: Icons.favorite, // Heart icon seperti mockup
      color: const Color(0xFFE74C3C), // Red color seperti mockup
      title: 'Breathing Islami Exercise',
      iconData: Icons.favorite,
      assetPath: AssetManager.heartIcon,
    ),
    FeatureData(
      icon: Icons.headphones,
      color: const Color(0xFF27AE60), // Green color seperti mockup
      title: 'Audio Relax Islami',
      iconData: Icons.headphones,
      assetPath: AssetManager.headphoneIcon,
    ),
    FeatureData(
      icon: Icons.menu_book, // Book icon seperti mockup
      color: const Color(0xFFF39C12), // Yellow/orange color seperti mockup
      title: 'Jurnal Refleksi Al-Quran',
      iconData: Icons.menu_book,
      assetPath: AssetManager.quranIcon, // Menggunakan Asset Alquran.png
    ),
    FeatureData(
      icon: Icons.circle, // Tasbih/prayer beads
      color: const Color(0xFFE67E22), // Orange color seperti mockup
      title: 'Dzikir dan Doa Ketenangan',
      iconData: Icons.circle,
      assetPath: AssetManager.tasbihIcon,
    ),
  ];

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Handle navigation based on selected index
    switch (index) {
      case 0: // Home - already here
        break;
      case 1: // Al-Quran
        Navigator.pushNamed(context, '/alquran');
        break;
      case 2: // Qalbu Chat
        Navigator.pushNamed(context, '/qalbu-chat');
        break;
      case 3: // Profile
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile feature coming soon...'),
            backgroundColor: Color(0xFF8FA68E),
          ),
        );
        break;
    }
  }

  void _selectMood(int index) {
    setState(() {
      _selectedMood = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8F8), // Very light teal
              Color(0xFFE8F5E8), // Light sage green
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Header with greeting and profile
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assalamualaikum',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8FA68E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ahmad Rifai',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5A5A),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/notification');
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8FA68E),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8FA68E).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Mood Tracker Card
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MoodTrackerScreen(),
                      ),
                    );
                    
                    // If user selected a mood, update the display
                    if (result != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Mood "${result.label}" telah disimpan!'),
                          backgroundColor: const Color(0xFF8FA68E),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2D5A5A).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Bagaimana Perasaanmu Hari Ini?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5A5A),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // Mood Selection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _moods.asMap().entries.map((entry) {
                            int index = entry.key;
                            MoodData mood = entry.value;
                            bool isSelected = _selectedMood == index;

                            return GestureDetector(
                              onTap: () => _selectMood(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF8FA68E) : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF8FA68E) : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: const Color(0xFF8FA68E).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ] : null,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    mood.emoji,
                                    width: isSelected ? 32 : 28,
                                    height: isSelected ? 32 : 28,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback to text if image not found
                                      return Text(
                                        mood.label.substring(0, 1),
                                        style: TextStyle(
                                          fontSize: isSelected ? 26 : 24,
                                          color: const Color(0xFF2D5A5A),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.touch_app,
                              size: 16,
                              color: const Color(0xFF8FA68E),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedMood == -1 ? 'Tap untuk mood tracker lengkap' : 'Tap lagi untuk detail mood tracker',
                              style: TextStyle(
                                fontSize: 12,
                                color: _selectedMood == -1 ? const Color(0xFF8FA68E) : const Color(0xFF2D5A5A),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Features Title
                const Text(
                  'Fitur Utama',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5A5A),
                  ),
                ),

                const SizedBox(height: 16),

                // Features Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: _features.map((feature) {
                    return GestureDetector(
                      onTap: () {
                        // Handle feature tap based on feature title
                        if (feature.title == 'Breathing Islami Exercise') {
                          Navigator.pushNamed(context, '/breathing-exercise');
                        } else if (feature.title == 'Audio Relax Islami') {
                          Navigator.pushNamed(context, '/audio-relax');
                        } else if (feature.title == 'Jurnal Refleksi Al-Quran') {
                          Navigator.pushNamed(context, '/jurnal-refleksi');
                        } else if (feature.title == 'Dzikir dan Doa Ketenangan') {
                          Navigator.pushNamed(context, '/doa-dzikir');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Membuka ${feature.title}...'),
                              backgroundColor: const Color(0xFF8FA68E),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2D5A5A).withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Direct PNG image tanpa background container seperti chatbot
                              Container(
                                width: 60,
                                height: 60,
                                child: feature.assetPath != null 
                                  ? Image.asset(
                                      feature.assetPath!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.contain, // Preserve PNG transparency
                                      errorBuilder: (context, error, stackTrace) {
                                        // Fallback dengan background warna jika gambar error
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: feature.color,
                                            borderRadius: BorderRadius.circular(30),
                                            boxShadow: [
                                              BoxShadow(
                                                color: feature.color.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            feature.iconData,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: feature.color,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: feature.color.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        feature.iconData,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                feature.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D5A5A),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                // Quranic Psychology Learning Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2D5A5A),
                        Color(0xFF8FA68E),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D5A5A).withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Islamic decoration icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            Icons.auto_stories,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Quranic Psychology Learning',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Pelajari kesehatan mental dari perspektif Islam dan Al-Quran dengan pendekatan psikologi modern',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to Quranic Psychology Learning
                              Navigator.pushNamed(context, '/quranic-psychology');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Pelajari Sekarang',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 100), // Space for bottom navigation
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D5A5A).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_filled, 'Home'),
                _buildNavItem(1, Icons.book, 'Al-Quran'),
                _buildNavItem(2, Icons.chat_bubble, 'Qalbu Chat'),
                _buildNavItem(3, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8FA68E).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF8FA68E) : const Color(0xFF999999),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF8FA68E) : const Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data models
class MoodData {
  final String emoji;
  final Color color;
  final String label;

  MoodData({
    required this.emoji,
    required this.color,
    required this.label,
  });
}

class FeatureData {
  final IconData icon;
  final Color color;
  final String title;
  final IconData iconData;
  final String? assetPath;

  FeatureData({
    required this.icon,
    required this.color,
    required this.title,
    required this.iconData,
    this.assetPath,
  });
}

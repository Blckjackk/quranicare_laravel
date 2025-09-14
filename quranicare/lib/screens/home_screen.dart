import 'package:flutter/material.dart';
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
    MoodData(emoji: AssetManager.moodSad, color: const Color(0xFF2C6E49), label: 'Sedih'),
    MoodData(emoji: AssetManager.moodDown, color: const Color(0xFF2C6E49), label: 'Down'),
    MoodData(emoji: AssetManager.moodNeutral, color: const Color(0xFF2C6E49), label: 'Biasa'),
    MoodData(emoji: AssetManager.moodHappy, color: const Color(0xFF2C6E49), label: 'Senang'),
    MoodData(emoji: AssetManager.moodHappy, color: const Color(0xFF2C6E49), label: 'Bahagia'),
  ];

  final List<FeatureData> _features = [
    FeatureData(
      icon: Icons.favorite,
      color: const Color(0xFF2C6E49),
      title: 'Breathing Islami Exercise',
      iconData: Icons.favorite,
      assetPath: AssetManager.heartIcon,
    ),
    FeatureData(
      icon: Icons.headphones,
      color: const Color(0xFF2C6E49),
      title: 'Audio Relax Islami',
      iconData: Icons.headphones,
      assetPath: AssetManager.headphoneIcon,
    ),
    FeatureData(
      icon: Icons.menu_book,
      color: const Color(0xFF2C6E49),
      title: 'Jurnal Refleksi Al-Quran',
      iconData: Icons.menu_book,
      assetPath: AssetManager.quranIcon,
    ),
    FeatureData(
      icon: Icons.circle,
      color: const Color(0xFF2C6E49),
      title: 'Dzikir dan Doa Ketenangan',
      iconData: Icons.circle,
      assetPath: AssetManager.tasbihIcon,
    ),
  ];

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0: // Home
        break;
      case 1: // Al-Quran
        Navigator.pushNamed(context, '/alquran');
        break;
      case 2: // Qalbu Chat
        Navigator.pushNamed(context, '/qalbu-chat');
        break;
      case 3: // Profile
        _showProfileMenu();
        break;
    }
  }

  void _selectMood(int index) {
    setState(() {
      _selectedMood = index;
    });
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileOption(Icons.person, 'Edit Profile', () {}),
            _buildProfileOption(Icons.settings, 'Pengaturan', () {}),
            _buildProfileOption(Icons.help, 'Bantuan', () {}),
            _buildProfileOption(Icons.info, 'Tentang Aplikasi', () {}),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF2C6E49).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF2C6E49),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF2C6E49),
      ),
      onTap: onTap,
    );
  }

  String _getFeatureSubtitle(String title) {
    switch (title) {
      case 'Breathing Islami Exercise':
        return 'Latihan pernapasan untuk ketenangan jiwa';
      case 'Audio Relax Islami':
        return 'Audio relaksasi dengan murottal dan dzikir';
      case 'Jurnal Refleksi Al-Quran':
        return 'Tulis refleksi dari ayat Al-Quran';
      case 'Dzikir dan Doa Ketenangan':
        return 'Kumpulan dzikir dan doa harian';
      default:
        return 'Fitur untuk kesehatan mental Islami';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Clean light background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Clean Header with Islamic greeting
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2C6E49), // Main green dari mockup
                      Color(0xFF1B5E20), // Darker green
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2C6E49).withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Profile Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Greeting Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Assalamualaikum',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            'Ahmad Rifai',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Notification Bell
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/notification');
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE74C3C),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Clean Mood Tracker Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C6E49),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.mood,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Bagaimana Perasaanmu Hari Ini?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

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
                            width: isSelected ? 58 : 52,
                            height: isSelected ? 58 : 52,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2C6E49) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(isSelected ? 29 : 26),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: const Color(0xFF2C6E49).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
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
                                  return Text(
                                    mood.label.substring(0, 1),
                                    style: TextStyle(
                                      fontSize: isSelected ? 24 : 20,
                                      color: isSelected ? Colors.white : const Color(0xFF333333),
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

                    // Helper text
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C6E49).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _selectedMood == -1 ? 'Pilih mood untuk tracking lengkap' : 'Mood tracker tersimpan!',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2C6E49),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Features Section
              const Text(
                'Fitur Utama',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),

              const SizedBox(height: 16),

              // Clean Features Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: _features.map((feature) {
                  return GestureDetector(
                    onTap: () {
                      if (feature.title == 'Breathing Islami Exercise') {
                        Navigator.pushNamed(context, '/breathing-exercise');
                      } else if (feature.title == 'Audio Relax Islami') {
                        Navigator.pushNamed(context, '/audio-relax');
                      } else if (feature.title == 'Jurnal Refleksi Al-Quran') {
                        Navigator.pushNamed(context, '/jurnal-refleksi');
                      } else if (feature.title == 'Dzikir dan Doa Ketenangan') {
                        Navigator.pushNamed(context, '/doa-dzikir');
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Feature icon
                            Container(
                              width: 60,
                              height: 60,
                              child: feature.assetPath != null 
                                ? Image.asset(
                                    feature.assetPath!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2C6E49),
                                          borderRadius: BorderRadius.circular(30),
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
                                      color: const Color(0xFF2C6E49),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Icon(
                                      feature.iconData,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                            ),

                            const SizedBox(height: 12),

                            // Feature title
                            Text(
                              feature.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 4),

                            // Feature subtitle
                            Text(
                              _getFeatureSubtitle(feature.title),
                              style: TextStyle(
                                fontSize: 10,
                                color: const Color(0xFF333333).withOpacity(0.6),
                                height: 1.2,
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

              const SizedBox(height: 24),

              // Quranic Psychology Learning Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2C6E49),
                      Color(0xFF1B5E20),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2C6E49).withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Islamic decoration icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.auto_stories,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Quranic Psychology Learning',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Pelajari kesehatan mental dari perspektif Islam dan Al-Quran dengan pendekatan psikologi modern',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Action button
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/quranic-psychology');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
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
          color: isSelected ? const Color(0xFF2C6E49).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2C6E49) : const Color(0xFF999999),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF2C6E49) : const Color(0xFF999999),
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
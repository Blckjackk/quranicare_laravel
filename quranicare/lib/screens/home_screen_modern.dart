import 'package:flutter/material.dart';
import '../utils/asset_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _selectedMood = -1;
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;

  final List<MoodData> _moods = [
    MoodData(emoji: AssetManager.moodSad, color: const Color(0xFF6366f1), label: 'Sedih'),
    MoodData(emoji: AssetManager.moodDown, color: const Color(0xFF8b5cf6), label: 'Down'),
    MoodData(emoji: AssetManager.moodNeutral, color: const Color(0xFF06b6d4), label: 'Biasa'),
    MoodData(emoji: AssetManager.moodHappy, color: const Color(0xFF10b981), label: 'Senang'),
    MoodData(emoji: AssetManager.moodHappy, color: const Color(0xFFf59e0b), label: 'Bahagia'),
  ];

  final List<FeatureData> _features = [
    FeatureData(
      icon: Icons.air,
      color: const Color(0xFF06b6d4),
      title: 'Breathing Islami',
      subtitle: 'Teknik nafas untuk ketenangan',
      iconData: Icons.air,
      assetPath: AssetManager.heartIcon,
      gradientColors: [Color(0xFF06b6d4), Color(0xFF0891b2)],
    ),
    FeatureData(
      icon: Icons.headphones_outlined,
      color: const Color(0xFF8b5cf6),
      title: 'Audio Relax',
      subtitle: 'Murottal & musik relaksasi',
      iconData: Icons.headphones_outlined,
      assetPath: AssetManager.headphoneIcon,
      gradientColors: [Color(0xFF8b5cf6), Color(0xFF7c3aed)],
    ),
    FeatureData(
      icon: Icons.menu_book_outlined,
      color: const Color(0xFF10b981),
      title: 'Jurnal Refleksi',
      subtitle: 'Refleksi dari Al-Quran',
      iconData: Icons.menu_book_outlined,
      assetPath: AssetManager.quranIcon,
      gradientColors: [Color(0xFF10b981), Color(0xFF059669)],
    ),
    FeatureData(
      icon: Icons.circle_outlined,
      color: const Color(0xFFf59e0b),
      title: 'Dzikir & Doa',
      subtitle: 'Kumpulan dzikir harian',
      iconData: Icons.circle_outlined,
      assetPath: AssetManager.tasbihIcon,
      gradientColors: [Color(0xFFf59e0b), Color(0xFFd97706)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutQuart),
    );
    
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeOutQuart),
    );
    
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0: break;
      case 1: Navigator.pushNamed(context, '/alquran'); break;
      case 2: Navigator.pushNamed(context, '/qalbu-chat'); break;
      case 3: _showProfileMenu(); break;
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
        child: Icon(icon, color: const Color(0xFF2C6E49), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF2C6E49)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Modern Animated Header
              AnimatedBuilder(
                animation: _headerAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - _headerAnimation.value)),
                    child: Opacity(
                      opacity: _headerAnimation.value,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1e293b), Color(0xFF334155)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1e293b).withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6366f1).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Assalamualaikum',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Text(
                                    'Ahmad Rifai',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/notification'),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    const Center(
                                      child: Icon(
                                        Icons.notifications_none_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Color(0xFFef4444), Color(0xFFdc2626)],
                                          ),
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
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Modern Mood Tracker
              AnimatedBuilder(
                animation: _cardAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - _cardAnimation.value)),
                    child: Opacity(
                      opacity: _cardAnimation.value,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF6366f1).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.mood_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mood Check',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1e293b),
                                        ),
                                      ),
                                      Text(
                                        'Bagaimana perasaanmu hari ini?',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF64748b),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: _moods.asMap().entries.map((entry) {
                                int index = entry.key;
                                MoodData mood = entry.value;
                                bool isSelected = _selectedMood == index;

                                return GestureDetector(
                                  onTap: () => _selectMood(index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
                                    width: isSelected ? 62 : 56,
                                    height: isSelected ? 62 : 56,
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(colors: [mood.color, mood.color.withOpacity(0.8)])
                                          : null,
                                      color: isSelected ? null : const Color(0xFFf1f5f9),
                                      borderRadius: BorderRadius.circular(isSelected ? 20 : 18),
                                      boxShadow: isSelected ? [
                                        BoxShadow(
                                          color: mood.color.withOpacity(0.4),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ] : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        mood.emoji,
                                        width: isSelected ? 36 : 32,
                                        height: isSelected ? 36 : 32,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Text(
                                            mood.label.substring(0, 1),
                                            style: TextStyle(
                                              fontSize: isSelected ? 28 : 24,
                                              color: isSelected ? Colors.white : const Color(0xFF64748b),
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

                            const SizedBox(height: 20),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: _selectedMood == -1 
                                    ? const LinearGradient(colors: [Color(0xFFe2e8f0), Color(0xFFcbd5e1)])
                                    : LinearGradient(colors: [
                                        _moods[_selectedMood].color.withOpacity(0.1),
                                        _moods[_selectedMood].color.withOpacity(0.05),
                                      ]),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedMood == -1 
                                      ? const Color(0xFFe2e8f0)
                                      : _moods[_selectedMood].color.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _selectedMood == -1 ? Icons.touch_app_rounded : Icons.check_circle_rounded,
                                    size: 16,
                                    color: _selectedMood == -1 
                                        ? const Color(0xFF64748b)
                                        : _moods[_selectedMood].color,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedMood == -1 
                                        ? 'Pilih mood untuk tracking' 
                                        : 'Mood tersimpan!',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _selectedMood == -1 
                                          ? const Color(0xFF64748b)
                                          : _moods[_selectedMood].color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Modern Section Title
              AnimatedBuilder(
                animation: _cardAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 10 * (1 - _cardAnimation.value)),
                    child: Opacity(
                      opacity: _cardAnimation.value,
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Fitur Utama',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1e293b),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Modern Features Grid
              AnimatedBuilder(
                animation: _cardAnimation,
                builder: (context, child) {
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: _features.asMap().entries.map((entry) {
                      int index = entry.key;
                      FeatureData feature = entry.value;
                      
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 800 + (index * 100)),
                        curve: Curves.easeOutQuart,
                        transform: Matrix4.identity()
                          ..translate(0.0, 30 * (1 - _cardAnimation.value)),
                        child: Opacity(
                          opacity: _cardAnimation.value,
                          child: GestureDetector(
                            onTap: () {
                              if (feature.title.contains('Breathing')) {
                                Navigator.pushNamed(context, '/breathing-exercise');
                              } else if (feature.title.contains('Audio')) {
                                Navigator.pushNamed(context, '/audio-relax');
                              } else if (feature.title.contains('Jurnal')) {
                                Navigator.pushNamed(context, '/jurnal-refleksi');
                              } else if (feature.title.contains('Dzikir')) {
                                Navigator.pushNamed(context, '/doa-dzikir');
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.1),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: feature.gradientColors,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: feature.color.withOpacity(0.3),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: feature.assetPath != null 
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            child: Image.asset(
                                              feature.assetPath!,
                                              width: 64,
                                              height: 64,
                                              fit: BoxFit.cover,
                                              color: Colors.white,
                                              colorBlendMode: BlendMode.srcIn,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Icon(
                                                  feature.iconData,
                                                  color: Colors.white,
                                                  size: 32,
                                                );
                                              },
                                            ),
                                          )
                                        : Icon(
                                            feature.iconData,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                    ),

                                    const SizedBox(height: 16),

                                    Text(
                                      feature.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1e293b),
                                        letterSpacing: 0.2,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      feature.subtitle,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748b),
                                        height: 1.3,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Modern Quranic Psychology Card
              AnimatedBuilder(
                animation: _cardAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - _cardAnimation.value)),
                    child: Opacity(
                      opacity: _cardAnimation.value,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1e293b), Color(0xFF334155)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1e293b).withOpacity(0.25),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF10b981), Color(0xFF059669)],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10b981).withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.auto_stories_rounded,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                'Quranic Psychology',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 12),

                              const Text(
                                'Jelajahi kesehatan mental dari perspektif Al-Quran dengan pendekatan psikologi modern yang terintegrasi',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 20),

                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/quranic-psychology'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF10b981), Color(0xFF059669)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10b981).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Mulai Belajar',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 16,
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
                    ),
                  );
                },
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModernNavItem(0, Icons.home_rounded, 'Home'),
                _buildModernNavItem(1, Icons.book_rounded, 'Al-Quran'),
                _buildModernNavItem(2, Icons.chat_bubble_rounded, 'Qalbu Chat'),
                _buildModernNavItem(3, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? const LinearGradient(colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)])
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF6366f1).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF64748b),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF64748b),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data Models
class MoodData {
  final String emoji;
  final Color color;
  final String label;

  MoodData({required this.emoji, required this.color, required this.label});
}

class FeatureData {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final IconData iconData;
  final String? assetPath;
  final List<Color> gradientColors;

  FeatureData({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.iconData,
    this.assetPath,
    required this.gradientColors,
  });
}
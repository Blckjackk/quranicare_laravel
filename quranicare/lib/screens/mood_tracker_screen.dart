import 'package:flutter/material.dart';
import '../widgets/mood_selector_widget.dart';
import '../services/mood_service.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  MoodOption? _selectedMood;
  bool _isLoading = false;
  final MoodService _moodService = MoodService();

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onMoodSelected(MoodOption mood) {
    setState(() {
      _selectedMood = mood;
    });
  }

  void _saveMood() async {
    if (_selectedMood == null) {
      _showErrorSnackBar('Silakan pilih mood terlebih dahulu');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Get token from auth service/storage - for demo purposes using placeholder
      const String userToken = 'demo_token'; 
      
      final result = await _moodService.saveMood(
        token: userToken,
        mood: _selectedMood!,
        moodDate: DateTime.now(),
        moodTime: DateTime.now(),
      );

      if (result['success']) {
        _showSuccessSnackBar('Mood "${_selectedMood!.label}" berhasil disimpan!');
        Navigator.pop(context, _selectedMood);
      } else {
        _showErrorSnackBar(result['message'] ?? 'Gagal menyimpan mood');
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
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
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
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
                    if (_selectedMood != null)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: _selectedMood!.color.withOpacity(0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _selectedMood!.color.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _selectedMood!.emoji,
                            style: const TextStyle(fontSize: 60),
                          ),
                        ),
                      ),
                    
                    if (_selectedMood == null)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '😐',
                            style: TextStyle(
                              fontSize: 60,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    Text(
                      _selectedMood?.label ?? 'Pilih mood Anda',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _selectedMood?.color ?? Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Mood Selector Widget
                    Expanded(
                      child: Center(
                        child: MoodSelectorWidget(
                          onMoodSelected: _onMoodSelected,
                          initialMood: _selectedMood,
                        ),
                      ),
                    ),

                    // Save Button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveMood,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedMood?.color ?? const Color(0xFF8FA68E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 8,
                            shadowColor: (_selectedMood?.color ?? const Color(0xFF8FA68E)).withOpacity(0.3),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
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
              );
            },
          ),
        ),
      ),
    );
  }
}

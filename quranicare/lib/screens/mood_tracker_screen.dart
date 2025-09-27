import 'package:flutter/material.dart';
import '../widgets/mood_spinner_widget.dart';
import '../services/mood_service.dart';
import '../services/auth_service.dart';

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
  bool _canSelectMood = true;
  bool _hasSelectedToday = false;
  final MoodService _moodService = MoodService();
  final AuthService _authService = AuthService();

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
    _checkTodayMood();
  }

  void _checkTodayMood() async {
    try {
      // Get token from auth service
      final userToken = await _authService.getToken();
      
      if (userToken == null) {
        print('⚠️ No auth token available');
        setState(() {
          _hasSelectedToday = false;
          _canSelectMood = true;
        });
        return;
      }
      
      // Test connection first
      final connectionTest = await _moodService.testConnection();
      print('🔍 Connection test: ${connectionTest['message']}');
      
      final result = await _moodService.getTodayMoods(token: userToken);
      
      if (result['success'] && result['data'] != null) {
        final data = result['data'];
        final totalEntries = data['total_entries'] ?? 0;
        
        setState(() {
          _hasSelectedToday = totalEntries > 0;
          _canSelectMood = totalEntries == 0;
        });
        
        if (totalEntries > 0) {
          print('✅ User already selected mood today (${totalEntries} entries)');
        } else {
          print('⭕ User hasn\'t selected mood today');
        }
      } else {
        print('⚠️ Failed to get today moods: ${result['message']}');
        setState(() {
          _hasSelectedToday = false;
          _canSelectMood = true;
        });
      }
    } catch (e) {
      print('❌ Error checking today mood: $e');
      // If error, allow selection
      setState(() {
        _hasSelectedToday = false;
        _canSelectMood = true;
      });
    }
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

    if (!_canSelectMood) {
      _showErrorSnackBar('Anda sudah memilih mood hari ini');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get token from auth service
      final userToken = await _authService.getToken();
      
      if (userToken == null) {
        _showErrorSnackBar('Tidak ada token autentikasi. Silakan login kembali.');
        return;
      }
      
      print('💾 Saving mood: ${_selectedMood!.type} (${_selectedMood!.label})');
      
      final result = await _moodService.saveMoodByType(
        token: userToken,
        moodType: _selectedMood!.type,
        moodDate: DateTime.now(),
        moodTime: DateTime.now(),
        notes: 'Dipilih menggunakan spinner wheel',
      );

      print('📋 Save result: ${result['success']} - ${result['message']}');

      if (result['success']) {
        _showSuccessSnackBar('Mood "${_selectedMood!.label}" berhasil disimpan!');
        
        // Update state to prevent multiple selections
        setState(() {
          _hasSelectedToday = true;
          _canSelectMood = false;
        });
        
        // Don't pop immediately, let user see the success message
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context, _selectedMood);
          }
        });
      } else {
        String errorMsg = result['message'] ?? 'Gagal menyimpan mood';
        
        if (result['status_code'] == 422 && result['errors'] != null) {
          // Handle validation errors
          final errors = result['errors'];
          if (errors is Map) {
            final errorMessages = <String>[];
            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                errorMessages.add(value.first.toString());
              }
            });
            if (errorMessages.isNotEmpty) {
              errorMsg = errorMessages.join(', ');
            }
          }
        }
        
        _showErrorSnackBar(errorMsg);
      }
    } catch (e) {
      print('❌ Exception saving mood: $e');
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

                    // Mood Spinner Widget
                    Expanded(
                      child: Center(
                        child: MoodSpinnerWidget(
                          onMoodSelected: _onMoodSelected,
                          initialMood: _selectedMood,
                          canSpin: _canSelectMood,
                        ),
                      ),
                    ),

                    // Save Button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Show selected mood info
                          if (_selectedMood != null && _canSelectMood)
                            Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _selectedMood!.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedMood!.color,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_selectedMood!.imagePath != null)
                                    ClipOval(
                                      child: Image.asset(
                                        _selectedMood!.imagePath!,
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Text(
                                            _selectedMood!.emoji,
                                            style: const TextStyle(fontSize: 20),
                                          );
                                        },
                                      ),
                                    )
                                  else
                                    Text(
                                      _selectedMood!.emoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Mood: ${_selectedMood!.label}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedMood!.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Save button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (_isLoading || !_canSelectMood || _selectedMood == null) ? null : _saveMood,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedMood?.color ?? const Color(0xFF8FA68E),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade400,
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
                                  : Text(
                                      !_canSelectMood 
                                          ? 'Sudah Memilih Hari Ini' 
                                          : _selectedMood == null 
                                              ? 'Pilih Mood Dulu'
                                              : 'Simpan Mood Saya',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
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

import 'package:flutter/material.dart';
import 'auth/sign_in_screen.dart';
import '../utils/asset_manager.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding data
  final List<OnboardingData> _pages = [
    OnboardingData(
      arabicText: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      description: 'QuraniCare hadir sebagai pendamping spiritual Anda. Temukan ketenangan melalui wisdom Al-Qur\'an.',
    ),
    OnboardingData(
      arabicText: 'وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ وَرَحْمَةٌ',
      description: 'Rasakan kedamaian melalui murottal yang menyejukkan, dzikir yang menenangkan, dan breathing exercise Islami yang membawa ketenangan jiwa dan raga.',
    ),
    OnboardingData(
      arabicText: 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
      description: 'Saksikan transformasi diri melalui tracking yang bermakna. Bangun habits positif dan lihat bagaimana setiap langkah kecil membawa Anda menuju sakinah yang hakiki.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to sign in screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    // Navigate to sign in screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
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
              Color(0xFFF8F9FA), // Very light gray at top
              Color(0xFFE8F5E8), // Light mint green
              Color(0xFFD4F4DD), // Soft green at bottom
            ],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top section with logo - Made more responsive with reduced spacing
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.015, // Reduced from 0.04 to maintain content position
                ),
                child: Column(
                  children: [
                    // Logo - Made 2x larger again while maintaining content position
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final screenHeight = MediaQuery.of(context).size.height;
                        final logoSize = screenHeight * 0.45; // 45% of screen height (2x larger again)
                        final minSize = 400.0; // 2x larger from previous 280px
                        final maxSize = 520.0; // 2x larger from previous 400px
                        final finalSize = logoSize.clamp(minSize, maxSize);
                        
                        return Image.asset(
                          AssetManager.quranicareLogo,
                          width: finalSize,
                          height: finalSize,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to original icon if image fails to load
                            return Container(
                              width: finalSize,
                              height: finalSize,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D5A5A),
                                borderRadius: BorderRadius.circular(finalSize * 0.15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: finalSize * 0.12,
                                    offset: Offset(0, finalSize * 0.06),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.menu_book_rounded,
                                    size: finalSize * 0.5,
                                    color: Colors.white,
                                  ),
                                  Positioned(
                                    top: finalSize * 0.16,
                                    right: finalSize * 0.2,
                                    child: Container(
                                      width: finalSize * 0.13,
                                      height: finalSize * 0.13,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(finalSize * 0.065),
                                      ),
                                      child: Icon(
                                        Icons.brightness_2,
                                        size: finalSize * 0.08,
                                        color: const Color(0xFF2D5A5A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // Removed QuraniCare brand text as requested
                  ],
                ),
              ),

              // PageView content - Made more responsive with content moved up
              Expanded(
                child: Transform.translate(
                  offset: Offset(0, -MediaQuery.of(context).size.height * 0.08), // Move content up by 8% of screen height
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final screenHeight = MediaQuery.of(context).size.height;
                          final screenWidth = MediaQuery.of(context).size.width;
                          
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08, // 8% of screen width
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: screenHeight * 0.02),
                                  
                                  // Arabic text with responsive styling
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.04,
                                      horizontal: screenWidth * 0.05,
                                    ),
                                    child: Text(
                                      _pages[index].arabicText,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: screenWidth * 0.08, // Increased from 0.065
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF2D5A5A),
                                        height: 1.8,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: screenHeight * 0.03),

                                  // White card container for description - More responsive
                                  Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.05,
                                    ),
                                    padding: EdgeInsets.all(screenWidth * 0.05),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.95),
                                      borderRadius: BorderRadius.circular(screenWidth * 0.08),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 25,
                                          offset: const Offset(0, 15),
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        // Progress indicator with responsive sizing
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(_pages.length, (dotIndex) {
                                            return AnimatedContainer(
                                              duration: const Duration(milliseconds: 300),
                                              margin: EdgeInsets.symmetric(
                                                horizontal: screenWidth * 0.015,
                                              ),
                                              height: 4,
                                              width: dotIndex == index 
                                                  ? screenWidth * 0.1 
                                                  : screenWidth * 0.03,
                                              decoration: BoxDecoration(
                                                color: dotIndex == index 
                                                    ? const Color(0xFF8FA68E) 
                                                    : const Color(0xFFD0D0D0),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            );
                                          }),
                                        ),

                                        SizedBox(height: screenHeight * 0.03),

                                        // Description text with responsive styling
                                        Text(
                                          _pages[index].description,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.045, // Increased from 0.038
                                            color: const Color(0xFF8FA68E),
                                            height: 1.6,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // Bottom navigation buttons - Made more responsive
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                  bottom: MediaQuery.of(context).size.height * 0.025,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final buttonSize = screenWidth * 0.14; // 14% of screen width
                    final minButtonSize = 50.0;
                    final maxButtonSize = 70.0;
                    final finalButtonSize = buttonSize.clamp(minButtonSize, maxButtonSize);
                    
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip button with responsive styling
                        TextButton(
                          onPressed: _skipOnboarding,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 0, 
                              vertical: screenWidth * 0.03,
                            ),
                          ),
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05, // Increased from 0.045
                              color: const Color(0xFF8FA68E),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        // Navigation arrows with responsive styling
                        Row(
                          children: [
                            // Previous arrow (only show after first page)
                            if (_currentPage > 0)
                              GestureDetector(
                                onTap: _previousPage,
                                child: Container(
                                  width: finalButtonSize,
                                  height: finalButtonSize,
                                  margin: EdgeInsets.only(right: screenWidth * 0.03),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8FA68E),
                                    borderRadius: BorderRadius.circular(finalButtonSize / 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8FA68E).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                    size: finalButtonSize * 0.35,
                                  ),
                                ),
                              ),

                            // Next arrow with responsive styling
                            GestureDetector(
                              onTap: _nextPage,
                              child: Container(
                                width: finalButtonSize,
                                height: finalButtonSize,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8FA68E),
                                  borderRadius: BorderRadius.circular(finalButtonSize / 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF8FA68E).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _currentPage == _pages.length - 1 
                                      ? Icons.check 
                                      : Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: _currentPage == _pages.length - 1 
                                      ? finalButtonSize * 0.4 
                                      : finalButtonSize * 0.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Data model for onboarding pages
class OnboardingData {
  final String arabicText;
  final String description;

  OnboardingData({
    required this.arabicText,
    required this.description,
  });
}

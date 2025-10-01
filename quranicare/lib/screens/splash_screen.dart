import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_screen.dart';
import '../utils/asset_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    
    // Auto navigate after 3 seconds (optional)
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const OnboardingScreen())
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Top spacing
                const SizedBox(height: 80),
                
                // Main content area
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo - Made much larger like onboarding
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final screenHeight = MediaQuery.of(context).size.height;
                          final logoSize = screenHeight * 0.35; // 35% of screen height (same as onboarding)
                          final minSize = 280.0; // Large minimum size
                          final maxSize = 400.0; // Large maximum size
                          final finalSize = logoSize.clamp(minSize, maxSize);
                          
                          return Image.asset(
                            AssetManager.quranicareLogo,
                            width: finalSize,
                            height: finalSize,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to icon if image fails to load
                              return Container(
                                width: finalSize,
                                height: finalSize,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2D5A5A),
                                  borderRadius: BorderRadius.circular(finalSize * 0.18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: finalSize * 0.14,
                                      offset: Offset(0, finalSize * 0.07),
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
                      
                      const SizedBox(height: 25), // Reduced spacing after logo
                      
                      // QuraniCare brand text
                      Column(
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Qurani',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D5A5A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'CARE',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w300,
                                    color: Color(0xFF2D5A5A),
                                    letterSpacing: 3.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Subtitle
                          Text(
                            'Your companion for Quranic journey',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Loading indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF2D5A5A).withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Let's Start Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (context) => const OnboardingScreen())
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2D5A5A),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27.5),
                        ),
                      ),
                      child: const Text(
                        'Let\'s Start',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Bottom spacing
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

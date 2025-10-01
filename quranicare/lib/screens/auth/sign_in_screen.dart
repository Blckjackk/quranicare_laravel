import 'package:flutter/material.dart';
import 'sign_up_screen.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../utils/asset_manager.dart';
import '../admin/admin_dashboard_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isAdminLogin = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail(String email) {
    setState(() {
      if (email.isEmpty) {
        _emailError = null;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailError = 'Invalid Email Address!!!';
      } else {
        _emailError = null;
      }
    });
  }

  void _signIn() async {
    if (_formKey.currentState!.validate() && _emailError == null) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isAdminLogin) {
          // Admin Login
          final result = await _adminService.login(
            _emailController.text.trim(),
            _passwordController.text,
          );

          if (mounted) {
            setState(() {
              _isLoading = false;
            });

            if (result['success']) {
              // Navigate to admin dashboard
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminDashboardScreen(admin: result['admin']),
                ),
              );
            } else {
              // Show admin login error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message']),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          // Regular User Login
          final result = await _authService.login(
            _emailController.text.trim(),
            _passwordController.text,
          );

          if (mounted) {
            setState(() {
              _isLoading = false;
            });

            if (result['success']) {
              // Navigate to user home screen
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              // Show user login error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message']),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
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
              Color(0xFFF8F9FA),
              Color(0xFFE8F5E8),
              Color(0xFFD4F4DD),
            ],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10), // Minimal top spacing
                  
                  // Sign In title
                  const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF8FA68E),
                      letterSpacing: 1.0,
                    ),
                  ),
                  
                  const SizedBox(height: 20), // Reduced spacing

                  // Logo - Large but doesn't affect layout positioning
                  Transform.scale(
                    scale: 2.2, // Scale logo 2.2x larger (about 4-5x total from current)
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final screenHeight = MediaQuery.of(context).size.height;
                        final logoSize = screenHeight * 0.22; // 22% of screen height (base size)
                        final minSize = 180.0; // Base minimum size
                        final maxSize = 280.0; // Base maximum size
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
                  ),

                  const SizedBox(height: 15), // Adequate spacing after logo

                  const SizedBox(height: 8), // Reduced spacing before email label

                  // Email Address
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8FA68E),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10), // Reduced spacing

                  // Email Input Field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white.withOpacity(0.9),
                      border: Border.all(
                        color: _emailError != null 
                            ? Colors.orange 
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: _validateEmail,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: const Color(0xFF8FA68E),
                          size: 20,
                        ),
                        hintText: 'Enter your email...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Email Error Message
                  if (_emailError != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.orange, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _emailError!,
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20), // Reduced spacing between email and password

                  // Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8FA68E),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10), // Reduced spacing

                  // Password Input Field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: const Color(0xFF8FA68E),
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF999999),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        hintText: 'Enter your password...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 15), // Reduced spacing

                  // Admin Login Toggle
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _isAdminLogin,
                          onChanged: (value) {
                            setState(() {
                              _isAdminLogin = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFF8FA68E),
                          checkColor: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                color: _isAdminLogin 
                                    ? const Color(0xFF8FA68E) 
                                    : Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Login as Admin',
                                style: TextStyle(
                                  color: _isAdminLogin 
                                      ? const Color(0xFF8FA68E) 
                                      : Colors.grey[700],
                                  fontWeight: _isAdminLogin 
                                      ? FontWeight.w600 
                                      : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20), // Reduced spacing

                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8FA68E),
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: const Color(0xFF8FA68E).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27.5),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isAdminLogin) 
                                  const Icon(
                                    Icons.admin_panel_settings,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                if (_isAdminLogin) const SizedBox(width: 8),
                                Text(
                                  _isAdminLogin ? 'Sign In as Admin' : 'Sign In',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward,
                                  size: 18,
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20), // Reduced spacing

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF8FA68E),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      GestureDetector(
                        onTap: _navigateToSignUp,
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2D5A5A),
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15), // Reduced spacing

                  // Forgot Password
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: const Text(
                      'Forgot Password',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2D5A5A),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), // Reduced spacing

                  // Admin Login Hint
                  if (_isAdminLogin)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8FA68E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF8FA68E).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                color: const Color(0xFF8FA68E),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Admin Login',
                                style: TextStyle(
                                  color: const Color(0xFF8FA68E),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Email: admin@quranicare.com\nPassword: admin123',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

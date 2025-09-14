import 'package:flutter/material.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
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

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isLoading = false;
      });

      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');
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
                  const SizedBox(height: 40),
                  
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
                  
                  const SizedBox(height: 50),

                  // Logo container
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D5A5A),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                        Positioned(
                          top: 20,
                          right: 25,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.brightness_2,
                              size: 10,
                              color: Color(0xFF2D5A5A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // QuraniCare brand text
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Qurani',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5A5A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'CARE',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF2D5A5A),
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),

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

                  const SizedBox(height: 12),

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

                  const SizedBox(height: 30),

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

                  const SizedBox(height: 12),

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

                  const SizedBox(height: 50),

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
                                const Text(
                                  'Sign In',
                                  style: TextStyle(
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

                  const SizedBox(height: 30),

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

                  const SizedBox(height: 20),

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

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

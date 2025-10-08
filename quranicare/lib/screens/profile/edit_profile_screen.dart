import 'package:flutter/material.dart';
import '../../services/user_profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingProfile = true;
  
  final UserProfileService _profileService = UserProfileService();
  String _fullName = 'Loading...';
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      print('👤 Loading user profile for edit screen...');
      final userData = await _profileService.getUserProfile();
      
      if (userData != null && mounted) {
        setState(() {
          _userProfile = userData;
          _fullName = userData['name'] ?? 'User';
          
          // Populate form fields with real data
          _usernameController.text = userData['name'] ?? '';
          _phoneController.text = userData['phone'] ?? ''; // Assuming phone field exists
          _emailController.text = userData['email'] ?? '';
          
          _isLoadingProfile = false;
        });
        print('✅ Profile loaded for edit screen: $_fullName');
      } else if (mounted) {
        // Fallback to hardcoded data
        setState(() {
          _fullName = 'User';
          _usernameController.text = 'Azzam Struggle';
          _phoneController.text = '087867099987';
          _emailController.text = 'azzamtugel@gmail.com';
          _isLoadingProfile = false;
        });
        print('⚠️ Failed to load profile for edit screen, using fallback');
      }
    } catch (e) {
      print('❌ Error loading profile for edit screen: $e');
      if (mounted) {
        // Fallback to hardcoded data
        setState(() {
          _fullName = 'User';
          _usernameController.text = 'Azzam Struggle';
          _phoneController.text = '087867099987';
          _emailController.text = 'azzamtugel@gmail.com';
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void _updateProfile() async {
    // Validate required fields
    if (_usernameController.text.trim().isEmpty) {
      _showErrorMessage('Nama tidak boleh kosong');
      return;
    }
    
    if (_emailController.text.trim().isEmpty) {
      _showErrorMessage('Email tidak boleh kosong');
      return;
    }

    // Validate password confirmation if password is provided
    if (_passwordController.text.trim().isNotEmpty) {
      if (_passwordController.text != _passwordConfirmationController.text) {
        _showErrorMessage('Password dan konfirmasi password tidak sama');
        return;
      }
      if (_passwordController.text.length < 6) {
        _showErrorMessage('Password harus minimal 6 karakter');
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('📤 Updating profile...');
      
      final result = await _profileService.updateProfile(
        name: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim().isEmpty ? null : _passwordController.text.trim(),
        passwordConfirmation: _passwordConfirmationController.text.trim().isEmpty ? null : _passwordConfirmationController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          // Use the Islamic message from API response if available
          String successMessage = result['message'] ?? 'Barakallahu fiik! Profile berhasil diperbarui';
          if (result['alhamdulillah'] != null) {
            successMessage = result['alhamdulillah'];
          }
          
          _showSuccessMessage(successMessage);
          
          // Refresh profile data
          await _loadUserProfile();
          
          // Navigate back
          Navigator.pop(context);
        } else {
          String errorMessage = result['message'] ?? 'Update failed';
          
          // Use Islamic guidance messages if available
          if (result['bismillah'] != null) {
            errorMessage = '${result['message']}\n${result['bismillah']}';
          } else if (result['istighfar'] != null) {
            errorMessage = '${result['message']}\n${result['istighfar']}';
          }
          
          // Handle validation errors
          if (result['errors'] != null) {
            final errors = result['errors'] as Map<String, dynamic>;
            final errorMessages = <String>[];
            
            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                errorMessages.add(value.first.toString());
              }
            });
            
            if (errorMessages.isNotEmpty) {
              errorMessage = '${result['message'] ?? 'Validation failed'}\n${errorMessages.join(', ')}';
            }
          }
          
          _showErrorMessage(errorMessage);
        }
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('Terjadi kesalahan: $e');
      }
    }
  }

  void _showSuccessMessage(String message) {
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

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
                    const Expanded(
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5A5A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 40), // Balance for back button
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Profile Picture
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF8FA68E),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2D5A5A).withOpacity(0.15),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(17),
                              child: Image.asset(
                                'assets/images/profile_placeholder.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8FA68E).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Color(0xFF8FA68E),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                // Handle image selection
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8FA68E),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Name (Display only)
                      _isLoadingProfile
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D5A5A)),
                              ),
                            )
                          : Text(
                              _fullName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D5A5A),
                              ),
                            ),

                      const SizedBox(height: 40),

                      // Username Field
                      _buildInputField(
                        label: 'Username',
                        controller: _usernameController,
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 20),

                      // Phone Field
                      _buildInputField(
                        label: 'Phone',
                        controller: _phoneController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 20),

                      // Email Field
                      _buildInputField(
                        label: 'Email Address',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 20),

                      // Password Field (Optional)
                      _buildInputField(
                        label: 'New Password (Optional)',
                        controller: _passwordController,
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),

                      const SizedBox(height: 20),

                      // Password Confirmation Field (Optional)
                      _buildInputField(
                        label: 'Confirm Password',
                        controller: _passwordConfirmationController,
                        icon: Icons.lock_reset_outlined,
                        isPassword: true,
                      ),

                      const SizedBox(height: 60),

                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8FA68E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFF8FA68E).withOpacity(0.3),
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
                                  'Update',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8FA68E),
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2D5A5A),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF8FA68E),
              ),
              hintText: 'Masukkan $label',
              hintStyle: TextStyle(
                color: const Color(0xFF64748b).withOpacity(0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
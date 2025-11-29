// sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();

  bool obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    fullNameCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 32, bottom: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF2453A6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'JasTip',
                style: GoogleFonts.pacifico(fontSize: 40, color: Colors.white),
              ),
            ),

            // FORM
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      label: 'Email',
                      hint: 'example@mail.com',
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    _buildTextField(
                      label: 'Full Name',
                      hint: 'Budi susila',
                      controller: fullNameCtrl,
                    ),
                    const SizedBox(height: 18),
                    _buildPasswordField(),
                    const SizedBox(height: 28),
                    _buildSignUpButton(),
                    const SizedBox(height: 32),
                    _buildBottomText(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.white)),
        const SizedBox(height: 6),

        // >>> INI YANG PENTING
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          cursorColor: Colors.black,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black, // paksa teks hitam
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: Colors.grey.shade400, width: .5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(
                color: Color(0xFF5F63FF),
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(fontSize: 13, color: Colors.white),
        ),
        const SizedBox(height: 6),

        // >>> INI JUGA DIPAKSA HITAM
        TextField(
          controller: passwordCtrl,
          obscureText: obscure,
          cursorColor: Colors.black,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black, // paksa teks hitam
          ),
          decoration: InputDecoration(
            hintText: '●●●●●●●●●●●',
            hintStyle: TextStyle(fontSize: 16, color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: Colors.grey.shade400, width: .5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(
                color: Color(0xFF5F63FF),
                width: 1.2,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[700],
              ),
              onPressed: () {
                setState(() {
                  obscure = !obscure;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5F63FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : const Text('Sign Up'),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    // Validasi input
    final email = emailCtrl.text.trim();
    final fullName = fullNameCtrl.text.trim();
    final password = passwordCtrl.text;

    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('Please enter a valid email address', Colors.red);
      return;
    }

    if (fullName.isEmpty) {
      _showSnackBar('Please enter your full name', Colors.red);
      return;
    }

    if (password.isEmpty || password.length < 6) {
      _showSnackBar('Password must be at least 6 characters', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Sign up dengan Supabase
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (!mounted) return;

      if (response.user != null) {
        // Sukses! Kembali ke Sign In untuk login (tanpa verifikasi email)
        _showSnackBar(
          'Account created. Please sign in to continue.',
          Colors.green,
        );

        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      } else {
        // Gagal create user
        _showSnackBar(
          'Registration failed. Please try again.',
          Colors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      // Parse error message untuk user-friendly
      String errorMessage = 'Sign up failed';
      
      if (e.toString().contains('User already registered')) {
        errorMessage = 'Email already registered. Please sign in instead.';
      } else if (e.toString().contains('Invalid email')) {
        errorMessage = 'Please enter a valid email address.';
      } else if (e.toString().contains('weak password')) {
        errorMessage = 'Password is too weak. Use at least 6 characters.';
      } else {
        errorMessage = 'Sign up failed: ${e.toString()}';
      }
      
      _showSnackBar(errorMessage, Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildBottomText() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GestureDetector(
          onTap: () {
            // Kembali ke halaman Sign In
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: const Text.rich(
            TextSpan(
              text: 'Have Account? ',
              style: TextStyle(fontSize: 13, color: Colors.white70),
              children: [
                TextSpan(
                  text: 'Sign In',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

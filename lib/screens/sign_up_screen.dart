// sign_up_screen.dart
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailPhoneCtrl = TextEditingController();
  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  bool obscure = true;

  @override
  void dispose() {
    emailPhoneCtrl.dispose();
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
              child: const Text(
                'JasTip',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
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
                      label: 'Email or Mobile Phone',
                      hint: 'Budi123@mail.com',
                      controller: emailPhoneCtrl,
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
        onPressed: () {
          // Validasi input
          if (emailPhoneCtrl.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter your email or phone'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          
          if (fullNameCtrl.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter your full name'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          
          if (passwordCtrl.text.isEmpty || passwordCtrl.text.length < 6) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password must be at least 6 characters'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Jika validasi sukses, tampilkan pesan dan navigasi ke home
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome, ${fullNameCtrl.text}! Account created successfully.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Navigasi ke home setelah sign up sukses
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacementNamed(context, '/home');
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5F63FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: const Text('Sign Up'),
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

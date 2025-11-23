import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailPhoneCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  bool obscure = true;
  String? selectedBlock;
  String? selectedRoom;

  final List<String> blocks = ['A', 'B', 'C', 'D'];
  final List<String> rooms = ['101', '102', '201', '202'];

  @override
  void dispose() {
    emailPhoneCtrl.dispose();
    nameCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Widget _header() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1F4592),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      alignment: Alignment.center,
      child: Text('JasTip',
          style: GoogleFonts.pacifico(
            color: Colors.white,
            fontSize: 40,
          )),
    );
  }

  Widget _chipGroup(List<String> data, String? selected, void Function(String) onTap) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: data.map((val) {
        final active = val == selected;
        return ChoiceChip(
          label: Text(val),
          selected: active,
          onSelected: (_) => onTap(val),
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFF5F63D9),
          labelStyle: TextStyle(
            color: active ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 28),
              const Text('Email or Mobile Phone', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(controller: emailPhoneCtrl, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              const Text('Full Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(controller: nameCtrl),
              const SizedBox(height: 20),
              const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(
                controller: passwordCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility : Icons.visibility_off, color: Colors.black87),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Alamat Asrama', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              _chipGroup(blocks, selectedBlock, (v) => setState(() => selectedBlock = v)),
              const SizedBox(height: 12),
              _chipGroup(rooms, selectedRoom, (v) => setState(() => selectedRoom = v)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // For now simply navigate to login
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Sign Up'),
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Have Account? ',
                      style: TextStyle(color: Colors.white70),
                      children: [
                        TextSpan(text: 'Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

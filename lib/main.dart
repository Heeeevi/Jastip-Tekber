import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORT SCREEN UMUM ---
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/home_screen.dart';
import 'screens/orders_screen.dart';

// --- IMPORT DARI LOCAL (FITUR SELLER YANG ANDA BUAT) ---
import 'screens/create_seller_profile_page.dart';
import 'screens/seller_profile_page.dart';
import 'screens/seller_dashboard_screen.dart';


// --- IMPORT DARI REMOTE (FITUR BUYER DARI GITHUB) ---
// Pastikan file-file ini ada di folder screens setelah pull
import 'screens/favorites_screen.dart';


void main() {
  runApp(const JasTipApp());
}

class JasTipApp extends StatelessWidget {
  const JasTipApp({super.key});

  static const Color _bgDark = Color(0xFF0E1118);
  static const Color _brandBlue = Color(0xFF1F4592);
  static const Color _primaryAccent = Color(0xFF5F63D9);

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark();

    return MaterialApp(
      title: 'JasTip',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: _bgDark,
        colorScheme: base.colorScheme.copyWith(
          primary: _primaryAccent,
          secondary: _brandBlue,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(color: Colors.black54),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(
          base.textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),

      initialRoute: '/',

      routes: {
        // --- RUTE UMUM ---
        '/': (_) => const LoginScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/home': (_) => const HomeScreen(),
        '/orders': (_) => const OrdersScreen(),

        // --- RUTE SELLER (LOCAL) ---
        '/create-seller-profile': (_) => const CreateSellerProfilePage(),
        '/seller-profile': (_) => const SellerProfilePage(),
        '/seller-dashboard': (_) => const SellerDashboardScreen(),

        // --- RUTE BUYER (REMOTE) ---
        '/favorites': (_) => const FavoritesScreen(),
      },
    );
  }
}

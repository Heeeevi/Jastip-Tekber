import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/buyer_dashboard_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/home_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/seller_dashboard_page.dart';
import 'screens/favorites_screen.dart';
import 'screens/order_status_screen.dart';

void main() {
  runApp(const JasTipApp());
}

class JasTipApp extends StatelessWidget {
  const JasTipApp({super.key});

  static const Color _bgDark = Color(0xFF0E1118); // near-black navy
  static const Color _brandBlue = Color(0xFF1F4592); // header blue
  static const Color _primaryAccent = Color(0xFF5F63D9); // button purple

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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
          bodyColor: Colors.white, 
          displayColor: Colors.white
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
     
      initialRoute: '/', 
      routes: {
       
        '/': (_) => const LoginScreen(), 
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/home': (_) => const HomeScreen(),
        '/orders': (_) => const OrdersScreen(),
        '/seller-dashboard': (_) => const SellerDashboardPage(),
        '/favorites': (_) => const FavoritesScreen(),
        '/buyer-dashboard': (_) => const BuyerDashboardScreen(),
        '/order-status': (context) => const OrderStatusScreen(),
      },
    );
  }
}

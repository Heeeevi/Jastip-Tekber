import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- IMPORT SCREEN UMUM ---
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/home_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/search_screen.dart';
import 'screens/order_status_screen.dart';
import 'screens/menu_chat.dart';
import 'screens/chat_conversation_screen.dart';

// --- IMPORT DARI LOCAL (FITUR SELLER YANG ANDA BUAT) ---
import 'screens/create_seller_profile_page.dart';
import 'screens/seller_profile_page.dart';
import 'screens/seller_dashboard_screen.dart';

// --- IMPORT DARI REMOTE (FITUR BUYER DARI GITHUB) ---
// Pastikan file-file ini ada di folder screens setelah pull
import 'screens/favorites_screen.dart';

// Global Supabase client getter
final supabase = Supabase.instance.client;

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://lhnjwhnvawqzmoqwcadx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxobmp3aG52YXdxem1vcXdjYWR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxNjE2NTcsImV4cCI6MjA3OTczNzY1N30.q3BAMawFbMUe-v1tM_ZcZaZCmC2-jnNitS0q2JSnZeU',
  );

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

  initialRoute: '/login',

      onGenerateRoute: (settings) {
        // Handle routes dengan parameter
        if (settings.name == '/create-seller-profile') {
          final args = settings.arguments as Map<String, dynamic>?;
          final isSeller = args?['isSeller'] ?? false;
          return MaterialPageRoute(
            builder: (_) => CreateSellerProfilePage(isSeller: isSeller),
            settings: settings, // Pass settings to preserve arguments
          );
        }

        // Handle seller-profile route with arguments
        if (settings.name == '/seller-profile') {
          return MaterialPageRoute(
            builder: (_) => const SellerProfilePage(),
            settings: settings, // IMPORTANT: Pass settings to preserve arguments!
          );
        }

        // Handle chat-conversation route with arguments
        if (settings.name == '/chat-conversation') {
          return MaterialPageRoute(
            builder: (_) => const ChatConversationScreen(),
            settings: settings, // Pass settings to preserve arguments
          );
        }

        // Routes biasa tanpa parameter
        final routes = <String, WidgetBuilder>{
          '/': (_) => const LoginScreen(),
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignUpScreen(),
          '/home': (_) => const HomeScreen(),
          '/orders': (_) => const OrdersScreen(),
          '/add-item': (_) => const AddItemPage(),
          '/seller-dashboard': (_) => const SellerDashboardScreen(),
          '/favorites': (_) => const FavoritesScreen(),
          '/search': (_) => const SearchScreen(),
          '/order-status': (_) => const OrderStatusScreen(),
          '/chat': (_) => const ChatScreen(),
        };

        final builder = routes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(builder: builder);
        }

        // Route not found
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      },
    );
  }
}

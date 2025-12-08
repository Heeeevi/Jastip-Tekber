import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/favorites_screen.dart';
import 'package:flutter_application_2/services/supabase_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int currentIndex = 1; // Orders tab
  final _svc = SupabaseService();
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _svc.fetchActiveOrders();
      setState(() {
        _orders = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _onBottomTap(int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(pageBuilder: (_, __, ___) => const HomeScreen(), transitionDuration: Duration.zero),
        );
        break;
      case 1:
        // already here
        break;
      case 2:
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const FavoritesScreen(), transitionDuration: Duration.zero,
        ),
      );
      break;
      case 3:
        // placeholders
        break;
    }
  }

  PreferredSizeWidget _topBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        },
        icon: const Icon(Icons.chevron_left),
      ),
      centerTitle: true,
      title: Text('JasTip', style: GoogleFonts.pacifico(fontSize: 24)),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.notifications_none),
        )
      ],
    );
  }

  Widget _orderTile(Map<String, dynamic> o) {
    final seller = (o['sellers'] is Map) ? o['sellers'] as Map<String, dynamic> : null;
    final name = seller?['display_name']?.toString() ?? 'Seller';
    final status = o['status']?.toString() ?? 'pending';
    final price = (o['total_price'] as num?)?.toInt() ?? 0;
  // sellerId not used directly here (kept via order map for detail)
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(order: o),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1F26),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 24, backgroundImage: AssetImage('assets/images/seller1.jpg')),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(o['delivery_address']?.toString() ?? '-', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C89C6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(status, style: const TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('Rp$price', style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _topBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: _orders.isEmpty
                      ? const ListTile(title: Text('No active orders'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 4, bottom: 24),
                          itemCount: _orders.length,
                          itemBuilder: (_, i) => _orderTile(_orders[i]),
                        ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onBottomTap,
        backgroundColor: const Color(0xFF14171D),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5F63D9),
        unselectedItemColor: Colors.white60,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'orders_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  bool buyerMode = true;

  final categories = [
    {'icon': Icons.local_fire_department, 'label': 'Fast Food'},
    {'icon': Icons.ramen_dining, 'label': 'Noodles'},
    {'icon': Icons.cake, 'label': 'Desserts'},
    {'icon': Icons.local_bar, 'label': 'Drinks'},
  ];

  final sellers = [
    {'name': 'Alan Walker', 'block': 'A', 'open': true},
    {'name': 'John Alex', 'block': 'C', 'open': true},
    {'name': 'John Doe', 'block': 'D', 'open': false},
  ];

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey.shade700,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text(
          'JasTip',
          style: GoogleFonts.pacifico(fontSize: 28, color: Colors.white),
        ),
        const Spacer(),
        Stack(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Text('2', style: TextStyle(fontSize: 10)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _toggleBuyerSeller() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F22),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill('Buyer', buyerMode, () {
            // Sudah di Buyer mode, tidak perlu navigasi
            setState(() => buyerMode = true);
          }),
          const SizedBox(width: 4),
          _pill('Seller', !buyerMode, () {
            // Navigasi ke Dashboard Seller menggunakan pushReplacement
            Navigator.pushReplacementNamed(context, '/seller-dashboard');
          }),
        ],
      ),
    );
  }

  Widget _pill(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF5F63D9) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search seller, food or dom blocks...',
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1C1F26),
        prefixIcon: const Icon(Icons.search, color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _sellerCard(Map<String, dynamic> seller) {
    final open = seller['open'] as bool;
    // MODIFIKASI: Menambahkan GestureDetector untuk navigasi ke Profil Seller
    return GestureDetector(
      onTap: () {
        // Membuka halaman seller_profile_page.dart
        Navigator.pushNamed(context, '/seller-profile');
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1F26),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade600,
              child: const Icon(Icons.person),
            ),
            const SizedBox(height: 8),
            Text(
              seller['name'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: open ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                open ? 'Open' : 'Closed',
                style: const TextStyle(fontSize: 10),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Blok ${seller['block']}',
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navigasi ke profil seller
                  Navigator.pushNamed(context, '/seller-profile');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Follow'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoriesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((c) {
        return Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF1C1F26),
              child: Icon(c['icon'] as IconData, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 6),
            Text(c['label'] as String, style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }

  Widget _activeOrderCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            // Menggunakan NetworkImage agar bisa langsung dijalankan tanpa aset lokal
            child: Image.network(
              'https://picsum.photos/id/292/800/600',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5F63D9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '15 Orders',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Closes in 45 min',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bakso Keputih',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    SizedBox(width: 4),
                    Text('4.8 | Korean', style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Delivery: 6:00 - 7:00 PM',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Order'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildHeader(),
          const SizedBox(height: 18),
          Row(children: [_toggleBuyerSeller(), const Spacer()]),
          const SizedBox(height: 18),
          _searchBar(),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Popular Sellers',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              TextButton(onPressed: () {}, child: const Text('See All')),
            ],
          ),
          SizedBox(
            height: 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sellers.length,
              padding: const EdgeInsets.only(left: 4),
              itemBuilder: (c, i) => _sellerCard(sellers[i]),
            ),
          ),
          const SizedBox(height: 28),
          _categoriesRow(),
          const SizedBox(height: 32),
          const Text(
            'Active Purchase Orders',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          _activeOrderCard(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  BottomNavigationBar _bottomNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        // --- LOGIKA NAVIGASI YANG DIGABUNGKAN ---
        switch (i) {
          case 0:
            // Sudah di Home
            setState(() => currentIndex = i);
            break;
          case 1:
            // Ke Orders Screen
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const OrdersScreen(),
                transitionDuration: Duration.zero,
              ),
            );
            break;
          case 2:
            // Ke Favorites Screen (Fitur dari Remote)
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const FavoritesScreen(),
                transitionDuration: Duration.zero,
              ),
            );
            break;
          case 3:
            // Placeholder Chat
            setState(() => currentIndex = i);
            break;
        }
      },
      backgroundColor: const Color(0xFF14171D),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF5F63D9),
      unselectedItemColor: Colors.white60,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chat',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _bodyContent(), bottomNavigationBar: _bottomNav());
  }
}

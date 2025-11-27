import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/seller_dashboard_page.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  int _currentIndex = 0;
  bool _isBuyerActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1523),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1523),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'JasTip',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.person, color: Colors.white),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications, color: Colors.white),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: const Center(
                    child: Text(
                      '2',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: _bottomNavBar(),
    );
  }

  Widget _getBody() {
    // Placeholder untuk tiap tab BottomNavigationBar
    switch (_currentIndex) {
      case 0:
        return _dashboardContent();
      case 1:
        return const Center(
            child: Text('Orders Page',
                style: TextStyle(color: Colors.white, fontSize: 20)));
      case 2:
        return const Center(
            child: Text('Favorites Page',
                style: TextStyle(color: Colors.white, fontSize: 20)));
      case 3:
        return const Center(
            child: Text('Chat Page',
                style: TextStyle(color: Colors.white, fontSize: 20)));
      default:
        return _dashboardContent();
    }
  }

  Widget _dashboardContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _topSwitchButton('Buyer', _isBuyerActive),
                const SizedBox(width: 10),
                _topSwitchButton('Seller', !_isBuyerActive),
              ],
            ),
            const SizedBox(height: 16),
            _searchField(),
            const SizedBox(height: 20),
            _titleRow('Popular Sellers'),
            const SizedBox(height: 10),
            _horizontalSellers(),
            const SizedBox(height: 20),
            _categoryRow(),
            const SizedBox(height: 20),
            const Text(
              "Active Purchase Orders",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _activeOrderCard(),
          ],
        ),
      ),
    );
  }

  //pindah halaman
  Widget _topSwitchButton(String text, bool active) {
  return GestureDetector(
    onTap: () {
      if (text == 'Seller') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SellerDashboardPage()),
        );
      } else {
        setState(() {
          _isBuyerActive = true;
        });
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF6C63FF) : const Color(0xFF1E2433),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

  Widget _searchField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2433),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search seller, food or dom blocks...',
          hintStyle: TextStyle(color: Colors.white54),
          prefixIcon: Icon(Icons.search, color: Colors.white54),
          border: InputBorder.none,
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _titleRow(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const Text('See All', style: TextStyle(color: Colors.blueAccent)),
      ],
    );
  }

  Widget _horizontalSellers() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2433),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage('assets/images/seller1.jpg'),
                ),
                const SizedBox(height: 10),
                const Text('Seller Name',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.green, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Open',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(height: 6),
                const Text('Blok A', style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E3A59),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Text('Follow', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

    Widget _categoryRow() {
    final categories = [
      {'name': 'Fast Food', 'image': 'assets/images/fastfood.jpg'},
      {'name': 'Noodles', 'image': 'assets/images/noodles.jpg'},
      {'name': 'Desserts', 'image': 'assets/images/desserts.jpg'},
      {'name': 'Drinks', 'image': 'assets/images/drinks.jpg'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: categories
          .map(
            (e) => Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(e['image']!),
                ),
                const SizedBox(height: 6),
                Text(e['name']!, style: const TextStyle(color: Colors.white)),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _activeOrderCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2433),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.asset('assets/images/bakso.jpeg',
                height: 180, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bakso Keputih',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 18),
                    SizedBox(width: 6),
                    Text('4.8 | Korean', style: TextStyle(color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Delivery: 6:00 - 7:00 PM',
                    style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12)),
                      child:
                          const Text('15 Orders', style: TextStyle(color: Colors.white)),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text('Order',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF1E2433),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
      ],
    );
  }
}
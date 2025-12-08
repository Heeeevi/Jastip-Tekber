import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'favorites_screen.dart';
import 'chat.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  //TAMBAHAN — current index supaya sama seperti FavoritesScreen
  int currentIndex = 0;

  //TAMBAHAN — handler untuk navigator
  void _onBottomTap(int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/orders');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/favorites');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/chat');
        break;
    }
  }

  List<String> history = [
    "ayam geprek joder",
    "Gacoan",
    "nasi padang goyang lidah",
    "ayam bakar Pak D",
  ];

  List<Map<String, dynamic>> results = [
    {
      "name": "Ramen",
      "delivery": "6:00 - 7:00 PM",
      "rating": 4.8,
      "category": "Korean",
      "isOnline": true,
      "closing": "Closes in 45 min"
    },
    {
      "name": "Bakso Keputih",
      "delivery": "6:00 - 7:00 PM",
      "rating": 4.8,
      "category": "Korean",
      "isOnline": true,
      "closing": "Closes in 45 min"
    },
  ];

  List<Map<String, dynamic>> filteredResults = [];

  @override
  void initState() {
    super.initState();
    filteredResults = results;
  }

  void search(String query) {
    setState(() {
      final q = query.toLowerCase();
      filteredResults = results.where((item) {
        final name = item["name"]?.toString().toLowerCase() ?? "";
        return name.contains(q);
      }).toList();
    });
  }

  Widget _buildHistoryItem(String text) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        search(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF5F63D9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildResultCard(Map item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                color: Colors.grey.shade800,
                child: Image.asset(
                  item['image'] ?? 'assets/images/placeholder.jpeg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey.shade800),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5F63D9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item["closing"] ?? "Closes in 45 min",
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              if (item["isOnline"] == true)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Online",
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["name"] ?? "Restaurant",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      "${item['rating'] ?? 4.8} | ${item['category'] ?? 'Food'}",
                      style: const TextStyle(
                          fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Delivery: ${item['delivery'] ?? '6:00 - 7:00 PM'}",
                  style:
                      const TextStyle(fontSize: 13, color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.search),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search seller or food...",
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                  onChanged: search,
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(), // <-- biar enak scrollnya
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Riwayat pencarian",
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  history.map((h) => _buildHistoryItem(h)).toList(),
            ),

            const SizedBox(height: 20),
            Text("Hasil pencarian ${filteredResults.length}",
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            ...filteredResults
                .map((item) => _buildResultCard(item)),
          ],
        ),
      ),

      //PENGGANTI BOTTOM BAR LAMA — SAMA PERSIS DENGAN FAVORITESSCREEN
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onBottomTap,
        backgroundColor: const Color(0xFF14171D),
        selectedItemColor: const Color(0xFF5F63D9),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: "Orders"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Favorites"),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
        ],
      ),
    );
  }
}

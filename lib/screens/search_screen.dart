import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

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
      filteredResults = results
          .where((item) =>
              item["name"].toLowerCase().contains(query.toLowerCase()))
          .toList();
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
        child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
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
          // Image with status badge
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5F63D9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item["closing"] ?? "Closes in 45 min",
                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              if (item["isOnline"] == true)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Online",
                      style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["name"] ?? "Restaurant",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      "${item['rating'] ?? 4.8} | ${item['category'] ?? 'Food'}",
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Delivery: ${item['delivery'] ?? '6:00 - 7:00 PM'}",
                  style: const TextStyle(fontSize: 13, color: Colors.white54),
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
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search seller or food...",
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // History Section
            const Text("Riwayat pencarian", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: history.map((h) => _buildHistoryItem(h)).toList(),
            ),

            const SizedBox(height: 20),
            Text("Hasil pencarian ${filteredResults.length}",
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            ...filteredResults.map((item) => _buildResultCard(item)),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Home"),
            _buildNavItem(Icons.receipt_long, "Orders"),
            _buildNavItem(Icons.favorite_border, "Favorites"),
            _buildNavItem(Icons.chat_bubble_outline, "Chat"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: const Color(0xFF5F63D9)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF5F63D9), fontWeight: FontWeight.w500)),
      ],
    );
  }
}

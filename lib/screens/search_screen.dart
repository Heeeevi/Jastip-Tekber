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
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(text, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  Widget _buildResultCard(Map item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item["name"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text("Delivery: ${item['delivery']}", style: TextStyle(color: Colors.grey.shade700)),
          Row(
            children: [
              Text("${item['rating']} | ${item['category']}"),
              const SizedBox(width: 8),
              if (item["isOnline"]) Text("Online", style: const TextStyle(color: Colors.green)),
            ],
          ),
          Text(item["closing"], style: TextStyle(color: Colors.red.shade400)),
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
            ...history.map((h) => _buildHistoryItem(h)).toList(),

            const SizedBox(height: 20),
            Text("Hasil pencarian ${filteredResults.length}",
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            ...filteredResults.map((item) => _buildResultCard(item)).toList(),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.home, size: 28),
            Icon(Icons.receipt, size: 28),
            Icon(Icons.favorite, size: 28),
            Icon(Icons.chat, size: 28),
          ],
        ),
      ),
    );
  }
}

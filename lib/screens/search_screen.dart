import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart'; 

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseService _svc = SupabaseService(); // Panggil Service

  int currentIndex = 0;
  bool _isLoading = false; // Loading state

  // List Hasil Pencarian (Dari Database)
  List<Map<String, dynamic>> filteredResults = [];

  // List Riwayat (Masih Hardcode/Local sementara)
  List<String> history = [
    "ayam geprek",
    "nasi padang",
    "bakso",
  ];

  void _onBottomTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home'); // Pakai replacement biar ga numpuk
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

  // --- FUNGSI SEARCH KE DATABASE ---
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        filteredResults = [];
      });
      return;
    }

    setState(() => _isLoading = true);

    // Panggil fungsi search dari SupabaseService
    final data = await _svc.searchProducts(query);

    if (mounted) {
      setState(() {
        filteredResults = data;
        _isLoading = false;
      });
    }
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

  // --- BUILD CARD HASIL (DATA DARI DB) ---
  Widget _buildResultCard(Map<String, dynamic> item) {
    // Ambil data dari Relation (Join Table)
    final seller = item['sellers'] ?? {};
    final sellerName = seller['display_name'] ?? 'Unknown Seller';
    final deliveryTime = seller['delivery_time'] ?? '20-30 min';
    final isOnline = seller['is_online'] ?? false;
    final rating = seller['rating'] ?? 0.0;
    
    // Data Produk
    final imageUrl = item['image_url']; 

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
        color: const Color(0xFF1C1F26), // Tambah warna bg card
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
                // Logika Gambar: Kalau ada URL pakai Network, kalau null pakai Placeholder
                child: imageUrl != null && imageUrl.toString().isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.broken_image, color: Colors.white54)),
                      )
                    : const Center(child: Icon(Icons.fastfood, size: 50, color: Colors.white24)),
              ),
              
              // Badge Close In (Dummy / bisa ambil dari DB field 'closing_time' kalau ada)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5F63D9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Open Now", 
                    style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              if (isOnline)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
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

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Produk
                Text(
                  item["name"] ?? "Unknown Food",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                
                // Rating & Kategori
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      "$rating | ${item['category'] ?? 'Food'}",
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Seller Name & Delivery
                Text(
                  "By $sellerName • Est: $deliveryTime",
                  style: const TextStyle(fontSize: 13, color: Colors.white54),
                ),
                const SizedBox(height: 4),
                
                // Harga
                Text(
                  "Rp ${item['price']}",
                  style: const TextStyle(fontSize: 14, color: Color(0xFF5F63D9), fontWeight: FontWeight.bold),
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
      backgroundColor: const Color(0xFF14171D), // Bg Gelap
      appBar: AppBar(
        backgroundColor: const Color(0xFF14171D),
        elevation: 0,
        toolbarHeight: 140,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 14),
            _buildSearchBar(),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RIWAYAT (Hardcode)
            if (filteredResults.isEmpty && _searchController.text.isEmpty) ...[
              const Text("Riwayat pencarian", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: history.map((h) => _buildHistoryItem(h)).toList(),
              ),
            ],

            const SizedBox(height: 20),
            
            // HASIL PENCARIAN
            if (_searchController.text.isNotEmpty)
              Text("Hasil pencarian (${filteredResults.length})",
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
            
            const SizedBox(height: 10),

            // Indikator Loading
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFF5F63D9)))
            else if (filteredResults.isEmpty && _searchController.text.isNotEmpty)
               const Padding(
                 padding: EdgeInsets.only(top: 20),
                 child: Center(child: Text("Tidak ada produk ditemukan", style: TextStyle(color: Colors.white54))),
               )
            else
              ...filteredResults.map((item) => _buildResultCard(item)),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onBottomTap,
        backgroundColor: const Color(0xFF14171D),
        selectedItemColor: const Color(0xFF5F63D9),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white, // Ganti putih biar kontras
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.black54),
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
              onChanged: search, // Trigger search pas ngetik
              onSubmitted: search, // Trigger search pas enter
            ),
          ),
          // Tombol Clear
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                search('');
              },
              child: const Icon(Icons.close, color: Colors.black54),
            )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // --- SAMA SEPERTI KODEMU, CUMA UPDATE NOTIFIKASI BIAR ILANG MERAHNYA ---
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          GestureDetector(
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade700,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
          const Spacer(),
          Text(
            'JasTip',
            style: GoogleFonts.pacifico(fontSize: 28, color: Colors.white),
          ),
          const Spacer(),
          // Ikon Notifikasi Bersih
          const Icon(Icons.notifications_none, color: Colors.white),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AllSellersScreen extends StatefulWidget {
  const AllSellersScreen({super.key});

  @override
  State<AllSellersScreen> createState() => _AllSellersScreenState();
}

class _AllSellersScreenState extends State<AllSellersScreen> {
  List<Map<String, dynamic>> _allSellers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllSellers();
  }

  Future<void> _fetchAllSellers() async {
    try {
      final data = await Supabase.instance.client
          .from('sellers')
          .select()
          .order('rating', ascending: false); // Ambil SEMUA, urut rating

      if (mounted) {
        setState(() {
          _allSellers = List<Map<String, dynamic>>.from(data as List);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419), // Samakan tema gelap
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1419),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Top Sellers',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allSellers.isEmpty
              ? const Center(child: Text('No sellers found', style: TextStyle(color: Colors.white)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _allSellers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final seller = _allSellers[index];
                    return _buildSellerListTile(seller);
                  },
                ),
    );
  }

  Widget _buildSellerListTile(Map<String, dynamic> seller) {
    final displayName = seller['display_name'] ?? 'Seller';
    final block = seller['block'] ?? '-';
    final isOpen = seller['is_online'] ?? false;
    final rating = (seller['rating'] as num?)?.toDouble() ?? 0.0;

    return GestureDetector(
      onTap: () {
        // Navigasi ke Profil Seller
        Navigator.pushNamed(context, '/seller-profile', arguments: {
          'seller': seller,
          'seller_id': seller['id'].toString()
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1F26),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Avatar
            const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            
            // Info Seller
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOpen ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                            fontSize: 10,
                            color: isOpen ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_on, size: 12, color: Colors.grey),
                      Text(
                        ' Blok $block',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Rating Badge
            Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Rating', style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
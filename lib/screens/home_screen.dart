import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final categories = [
    {'icon': Icons.local_fire_department, 'label': 'Fast Food'},
    {'icon': Icons.ramen_dining, 'label': 'Noodles'},
    {'icon': Icons.cake, 'label': 'Desserts'},
    {'icon': Icons.local_bar, 'label': 'Drinks'},
  ];
  // Category browsing
  final List<String> _categories = [
    'Fast Food',
    'Noodles',
    'Desserts',
    'Drinks',
  ];
  String? _selectedCategory;
  bool _loadingCategoryProducts = false;
  List<Map<String, dynamic>> _categoryProducts = [];
  String? _categoryError;

  // Sellers fetched from Supabase
  List<Map<String, dynamic>> sellers = [];
  bool _loadingSellers = false;
  List<Map<String, dynamic>> _activeOrders = [];
  bool _loadingOrders = false;
  // ALL Products from all sellers
  List<Map<String, dynamic>> _allProducts = [];
  bool _loadingAllProducts = false;

  @override
  void initState() {
    super.initState();
    _loadSellers();
    _loadActiveOrders();
    _loadAllProducts();
  }

  Future<void> _loadSellers() async {
    setState(() => _loadingSellers = true);
    try {
      final data = await SupabaseService().fetchSellers(limit: 10);
      if (mounted) setState(() => sellers = data);
    } catch (_) {
      if (mounted) setState(() => sellers = []);
    } finally {
      if (mounted) setState(() => _loadingSellers = false);
    }
  }

  Future<void> _loadActiveOrders() async {
    setState(() => _loadingOrders = true);
    try {
      final data = await SupabaseService().fetchActiveOrders();
      if (mounted) setState(() => _activeOrders = data);
    } catch (_) {
      if (mounted) setState(() => _activeOrders = []);
    } finally {
      if (mounted) setState(() => _loadingOrders = false);
    }
  }

  Future<void> _loadAllProducts() async {
    setState(() => _loadingAllProducts = true);
    try {
      final data = await SupabaseService().getAllProducts(limit: 50);
      if (mounted) setState(() => _allProducts = data);
    } catch (_) {
      if (mounted) setState(() => _allProducts = []);
    } finally {
      if (mounted) setState(() => _loadingAllProducts = false);
    }
  }

  Future<void> _loadCategoryProducts(String category) async {
    setState(() {
      _selectedCategory = category;
      _loadingCategoryProducts = true;
      _categoryError = null;
    });
    try {
      final products = await SupabaseService().getProductsByCategory(category);
      _categoryProducts = products;
    } catch (e) {
      _categoryError = 'Failed to load products: $e';
    } finally {
      _loadingCategoryProducts = false;
      if (mounted) setState(() {});
    }
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            // Navigasi ke halaman Edit Profile (Buyer mode)
            Navigator.pushNamed(
              context,
              '/create-seller-profile',
              arguments: {'isSeller': false},
            );
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade700,
            child: const Icon(Icons.person, color: Colors.white),
          ),
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You have 2 new notifications'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
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
        // Logout Button
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'logout') {
              _showLogoutDialog();
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Logout', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await _handleLogout();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logging out...'),
          duration: Duration(seconds: 1),
        ),
      );

  // Sign out from Supabase
  await SupabaseService().signOut();

      // Navigate to login screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false, // Remove all previous routes
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          _pill('Buyer', true, null), // Active di Buyer mode
          const SizedBox(width: 4),
          _pill('Seller', false, () async {
            // Check if seller profile exists; if not prompt to create
            final service = SupabaseService();
            final existing = await service.getCurrentSellerProfile();
            if (existing == null) {
              String name = '';
              String block = 'A';
              final created = await showDialog<bool>(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    title: const Text('Create Seller Profile'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Store Name',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: const TextStyle(color: Colors.black),
                          onChanged: (v) => name = v.trim(),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: block,
                          decoration: const InputDecoration(labelText: 'Block'),
                          items: ['A','B','C','D','E']
                              .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                              .toList(),
                          onChanged: (v) => block = v ?? 'A',
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (name.isEmpty) return;
                          Navigator.pop(ctx, true);
                        },
                        child: const Text('Create'),
                      )
                    ],
                  );
                },
              );
              if (created == true) {
                try {
                  await service.ensureSellerProfile(displayName: name, block: block);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Seller profile "$name" created.')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed: $e')),
                    );
                  }
                  return; // Abort navigation on failure
                }
              } else {
                return; // Cancelled
              }
            }
            // Navigate to seller dashboard
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/seller-dashboard');
            }
          }),
        ],
      ),
    );
  }

  Widget _pill(String label, bool active, VoidCallback? onTap) {
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
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Search feature coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      readOnly: true, // Sementara read-only sampai search diimplementasi
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
       onSubmitted: (value) {
        Navigator.pushNamed(context, '/search');
      },
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _sellerCard(Map<String, dynamic> seller) {
    final open = (seller['is_online'] as bool?) ?? false;
    final displayName = (seller['display_name'] as String?) ?? (seller['name'] as String? ?? 'Seller');
    final block = (seller['block'] as String?) ?? '-';
    // MODIFIKASI: Menambahkan GestureDetector untuk navigasi ke Profil Seller
    return GestureDetector(
      onTap: () {
        // Buka halaman profil toko dengan data seller yang dipilih
        print('[HomeScreen] Seller card tapped: ${seller['display_name']}');
        print('[HomeScreen] Seller ID: ${seller['id']}');
        print('[HomeScreen] Seller data: $seller');
        Navigator.pushNamed(
          context,
          '/seller-profile',
          arguments: {
            'seller': seller,
            'seller_id': seller['id']?.toString(),
          },
        );
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
              displayName,
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
              'Blok $block',
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navigasi ke profil seller (kirim argumen juga)
                  print('[HomeScreen] Follow button tapped: ${seller['display_name']}');
                  print('[HomeScreen] Seller ID: ${seller['id']}');
                  Navigator.pushNamed(
                    context,
                    '/seller-profile',
                    arguments: {
                      'seller': seller,
                      'seller_id': seller['id']?.toString(),
                    },
                  );
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
    if (_loadingOrders) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ));
    }
    if (_activeOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1F26),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Active Purchase Orders',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Text(
              'No orders here — want to order now?',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }
    final o = _activeOrders.first;
    final seller = o['sellers'] as Map<String, dynamic>?;
    final sellerName = seller?['display_name']?.toString() ?? 'Seller';
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
            child: Image.network(
              'https://picsum.photos/id/292/800/600',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 150,
                  color: const Color(0xFF2A2D35),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: const Color(0xFF5F63D9),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: const Color(0xFF2A2D35),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white54,
                      size: 40,
                    ),
                  ),
                );
              },
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
                Text(
                  sellerName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                    onPressed: () { Navigator.pushReplacementNamed(context, '/orders'); },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('View'),
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
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View all sellers feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('See All'),
              ),
            ],
          ),
          SizedBox(
            height: 210,
            child: _loadingSellers
                ? const Center(child: CircularProgressIndicator())
                : (sellers.isEmpty
                    ? const Center(child: Text('No sellers yet'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: sellers.length,
                        padding: const EdgeInsets.only(left: 4),
                        itemBuilder: (c, i) => _sellerCard(sellers[i]),
                      )),
          ),
          const SizedBox(height: 28),
          _categoriesRow(),
          const SizedBox(height: 32),
          // ALL PRODUCTS SECTION (Main listing dari semua seller)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Available Items from Sellers',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAllProductsSection(),
          const SizedBox(height: 28),
          _buildCategorySection(),
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

  Widget _buildAllProductsSection() {
    if (_loadingAllProducts) {
      return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
    }
    if (_allProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No items available yet. Sellers can add products from Seller Dashboard.', style: TextStyle(color: Colors.white70)),
      );
    }
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _allProducts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, idx) {
          final p = _allProducts[idx];
          final seller = p['sellers'] as Map<String, dynamic>?;
          final sellerName = seller?['display_name'] ?? 'Seller';
          final rating = (seller?['rating'] as num?)?.toDouble() ?? 0.0;
          return GestureDetector(
            onTap: () {
              // Quick order dengan delivery prompt
              _createQuickOrder(p);
            },
            child: Container(
              width: 180,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1F26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image placeholder
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(Icons.fastfood, size: 40, color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p['name'] ?? 'Item',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.store, size: 12, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          sellerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  if (rating > 0) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                  ],
                  const Spacer(),
                  Text(
                    'Rp ${(p['price'] ?? 0).toString()}',
                    style: const TextStyle(color: Color(0xFF5F63D9), fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _createQuickOrder(p),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5F63D9),
                        minimumSize: const Size(double.infinity, 32),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Order Now', style: TextStyle(fontSize: 12)),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Browse by Category',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _categories.map((c) {
            final selected = c == _selectedCategory;
            return ChoiceChip(
              label: Text(c),
              selected: selected,
              onSelected: (_) => _loadCategoryProducts(c),
            );
          }).toList(),
        ),
        if (_selectedCategory != null) ...[
          const SizedBox(height: 12),
          Text(
            '$_selectedCategory Products',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (_loadingCategoryProducts)
            const Center(child: CircularProgressIndicator())
          else if (_categoryError != null)
            Text(_categoryError!, style: const TextStyle(color: Colors.red))
          else if (_categoryProducts.isEmpty)
            const Text('No products found in this category.')
          else
            SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categoryProducts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, idx) {
                  final p = _categoryProducts[idx];
                  final seller = p['sellers'] as Map<String, dynamic>?;
                  return Container(
                    width: 160,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['name'] ?? 'Unnamed',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          seller != null ? seller['display_name'] ?? 'Seller' : 'Seller',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const Spacer(),
                        Text(
                          'Rp ${(p['price'] ?? 0).toString()}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        ElevatedButton(
                          onPressed: () {
                            // Quick order create workflow (single item order)
                            _createQuickOrder(p);
                          },
                          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 32)),
                          child: const Text('Order'),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
        ]
      ],
    );
  }

  Future<void> _createQuickOrder(Map<String, dynamic> product) async {
    try {
      final order = await SupabaseService().createOrder(
        sellerId: product['seller_id'].toString(),
        totalPrice: (product['price'] as num?)?.toDouble() ?? 0.0,
      );
      await SupabaseService().addOrderItem(
        orderId: order['id'],
        productId: product['id'],
        quantity: 1,
        price: (product['price'] as num?)?.toDouble() ?? 0.0,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created!')),
        );
        _loadActiveOrders(); // refresh active orders
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create order: $e')),
        );
      }
    }
  }

  BottomNavigationBar _bottomNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        // Navigasi konsisten dengan screen lainnya
        switch (i) {
          case 0:
            // Sudah di Home
            break;
          case 1:
            // Ke Orders Screen
            Navigator.pushReplacementNamed(context, '/orders');
            break;
          case 2:
            // Ke Favorites Screen
            Navigator.pushReplacementNamed(context, '/favorites');
            break;
          case 3:
            // Pindah ke ChatScreen (hindari replacement untuk mengurangi lag)
            Navigator.pushNamed(context, '/chat');
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
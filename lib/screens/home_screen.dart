import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../services/supabase_service.dart';
import 'orders_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  int _visibleCount = 10;

  // --- 1. STATE UNTUK SCROLL CONTROLLER ---
  final ScrollController _scrollController = ScrollController();
  bool _showScrollButton = false;

  // State untuk Filter Kategori
  String? _selectedCategory;
  bool _isLoadingFeed = false;

  // Data List
  List<Map<String, dynamic>> _sellers = [];
  List<Map<String, dynamic>> _feedProducts = []; // Ini List Utama (Active Orders)

  // Data Kategori Hardcode (Sesuai Desain)
  final categories = [
    {'icon': Icons.local_fire_department, 'label': 'Fast Food'},
    {'icon': Icons.ramen_dining, 'label': 'Noodles'},
    {'icon': Icons.cake, 'label': 'Desserts'},
    {'icon': Icons.local_bar, 'label': 'Drinks'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();

    // --- 2. LISTENER SCROLL (Untuk tombol Back to Top) ---
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showScrollButton) {
        setState(() => _showScrollButton = true);
      } else if (_scrollController.offset <= 300 && _showScrollButton) {
        setState(() => _showScrollButton = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Jangan lupa dispose controller
    super.dispose();
  }

  Future<void> _loadData() async {
    // Load sellers dan produk sekaligus
    await Future.wait([
      _loadSellers(),
      _loadFeedProducts(),
    ]);
  }

  Future<void> _loadSellers() async {
    try {
      // MODIFIKASI: Ambil seller diurutkan berdasarkan rating tertinggi (descending)
      final data = await Supabase.instance.client
          .from('sellers')
          .select()
          .order('rating', ascending: false) // Rating tertinggi di kiri
          .limit(5);
          
      if (mounted) {
        setState(() {
          _sellers = List<Map<String, dynamic>>.from(data as List);
        });
      }
    } catch (_) {
      // Silent error
    }
  }

  // FUNGSI UTAMA: Mengambil Produk (Feed) dengan Filter
  Future<void> _loadFeedProducts({String? category}) async {
    setState(() => _isLoadingFeed = true);
    try {
      // PERBAIKAN: Menggunakan Supabase.instance.client agar tidak error merah
      var query = Supabase.instance.client
          .from('products')
          .select('*, sellers:seller_id(display_name, rating, delivery_time)')
          .eq('is_available', true); // Hanya ambil yang tersedia

      // Jika ada kategori dipilih, tambahkan filter
      if (category != null) {
        // Asumsi kolom 'category' di DB menyimpan string nama kategori
        query = query.ilike('category', '%$category%');
      }

      final data = await query;
      
      if (mounted) {
        setState(() {
          // Konversi aman untuk mencegah error TypeError
          _feedProducts = List<Map<String, dynamic>>.from(data as List);
        });
      }
    } catch (e) {
      print('Error loading feed: $e');
    } finally {
      if (mounted) setState(() => _isLoadingFeed = false);
    }
  }

  // Logic saat ikon kategori diklik
  void _onCategorySelected(String categoryLabel) {
    setState(() {
      _visibleCount = 10;
      if (_selectedCategory == categoryLabel) {
        _selectedCategory = null; // Matikan filter (Show All)
      } else {
        _selectedCategory = categoryLabel; // Aktifkan filter
      }
    });
    // Reload data sesuai filter baru
    _loadFeedProducts(category: _selectedCategory);
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
          const SnackBar(content: Text('Order created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  // --- 3. LOGIC POP UP BUAT TOKO (Jika belum punya) ---
 // --- 3. LOGIC POP UP BUAT TOKO (YANG SUDAH DIRAPIKAN) ---
  void _showCreateStoreDialog() {
    String storeName = '';
    String block = 'A'; // Default value

    showDialog(
      context: context,
      barrierDismissible: false, // User gabisa tutup paksa klik luar (opsional)
      builder: (context) {
        // PENTING: StatefulBuilder supaya Dropdown bisa berubah tampilan saat dipilih
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C1F26), // Background Gelap
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Create Your Store',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  // --- INPUT STORE NAME ---
                  TextField(
                    style: const TextStyle(color: Colors.black), // PENTING: Teks jadi Hitam
                    onChanged: (val) => storeName = val,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Store Name',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30), // Bulat lonjong
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // --- DROPDOWN LOCATION ---
                  DropdownButtonFormField<String>(
                    value: block,
                    dropdownColor: Colors.white, // Background menu dropdown putih
                    style: const TextStyle(color: Colors.black, fontSize: 16), // Teks pilihan Hitam
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    items: ['A', 'B', 'C', 'D', 'E'].map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(
                          'Blok $e',
                          style: const TextStyle(color: Colors.black), // Teks item Hitam
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        block = val!;
                      });
                    },
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              actions: [
                Row(
                  children: [
                    // Tombol Cancel
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tombol Create
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (storeName.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter store name')),
                            );
                            return;
                          }
                          
                          try {
                            // Panggil service
                            await SupabaseService().ensureSellerProfile(
                              displayName: storeName,
                              block: block,
                            );
                            if (mounted) {
                              Navigator.pop(context); // Tutup dialog
                              Navigator.pushReplacementNamed(context, '/seller-dashboard'); 
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5F63D9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Create Store'),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        );
      },
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: const Color(0xFF1C1F26),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person, color: Colors.white),
                        title: const Text('Edit Buyer Profile', style: TextStyle(color: Colors.white)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            '/create-seller-profile',
                            arguments: {'isSeller': false},
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Logout', style: TextStyle(color: Colors.red)),
                        onTap: () async {
                          Navigator.pop(context);
                          await SupabaseService().signOut();
                          if (mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/login', (route) => false);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
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

        // --- 5. KANAN: NOTIFIKASI ---
        Stack(
          children: [
            const Icon(Icons.notifications_none, color: Colors.white),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center),
              ),
            )
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
          _pill('Buyer', true, null),
          const SizedBox(width: 4),
          _pill('Seller', false, () async {
            // --- 4. LOGIC CHECK SELLER PROFILE SEBELUM MASUK DASHBOARD ---
            try {
              final existing = await SupabaseService().getCurrentSellerProfile();
              if (existing != null) {
                // Sudah punya toko, langsung masuk
                if(mounted) Navigator.pushReplacementNamed(context, '/seller-dashboard');
              } else {
                // Belum punya, tampilkan pop up buat toko
                _showCreateStoreDialog();
              }
            } catch (e) {
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
      readOnly: true,
      onTap: () {
         //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Search coming soon')));
         Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
      decoration: InputDecoration(
        hintText: 'Mau makan apa hari ini?',
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

  Widget _sellerAvatar(Map<String, dynamic> seller) {
    final displayName = seller['display_name'] ?? 'Seller';
    final isOpen = seller['is_online'] ?? false;
    final block = seller['block'] ?? '-';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/seller-profile', arguments: {
          'seller': seller,
          'seller_id': seller['id'].toString()
        });
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1F26),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isOpen ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4)
              ),
              child: Text(isOpen ? 'Open' : 'Closed', style: TextStyle(fontSize: 10, color: isOpen ? Colors.green : Colors.red)),
            ),
             const SizedBox(height: 4),
             Text('Blok $block', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // WIDGET KATEGORI (FILTER)
  Widget _buildCategories() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((c) {
        final isSelected = _selectedCategory == c['label'];
        return GestureDetector(
          onTap: () => _onCategorySelected(c['label'] as String),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF5F63D9) : const Color(0xFF1C1F26),
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                ),
                child: Icon(c['icon'] as IconData, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                c['label'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF5F63D9) : Colors.white,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // WIDGET FEED CARD UTAMA (BIG CARD)
  Widget _buildBigProductCard(Map<String, dynamic> product) {
    final seller = product['sellers'] as Map<String, dynamic>?;
    final sellerName = seller?['display_name'] ?? 'Unknown Seller';
    final price = product['price'] ?? 0;
    
    // --- DUMMY DATA ---
    const closesIn = "45 min"; 
    const orderCount = 15; 
    // ------------------

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar & Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: Colors.grey.shade800,
                  child: const Center(child: Icon(Icons.fastfood, size: 50, color: Colors.white24)),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5F63D9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Closes in $closesIn', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF8F0), 
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('$orderCount Orders', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          
          // Info Produk
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] ?? 'Product Name',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "4.8 | $sellerName", 
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Rp $price",
                         style: const TextStyle(fontSize: 14, color: Color(0xFF5F63D9), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _createQuickOrder(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F63D9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  ),
                  child: const Text('Order', style: TextStyle(color: Colors.white)),
                )
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
      // --- 5. TOMBOL FLOAT UNTUK SCROLL KE ATAS ---
      floatingActionButton: _showScrollButton
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              backgroundColor: const Color(0xFF5F63D9),
              mini: true,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,

     body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildHeader(),
            const SizedBox(height: 18),

            Center(child: _toggleBuyerSeller()), 
            // -------------------------------------

            const SizedBox(height: 18),
            _searchBar(),
            const SizedBox(height: 26),
            // Popular Sellers Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Popular Sellers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                TextButton(onPressed: (){Navigator.pushNamed(context, '/all-sellers');}, child: const Text('See All')),
              ],
            ),
            
            // Seller List
            SizedBox(
              height: 130,
              child: _sellers.isEmpty 
                  ? const Center(child: Text("No sellers"))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _sellers.length,
                      itemBuilder: (c, i) => _sellerAvatar(_sellers[i]),
                    ),
            ),

            const SizedBox(height: 24),
            // Kategori Filter
            _buildCategories(),
            
            const SizedBox(height: 24),
            // Header Active Purchase Orders
            const Text('Active Purchase Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // FEED UTAMA
            if (_isLoadingFeed) 
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            else if (_feedProducts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(color: const Color(0xFF1C1F26), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                     const Icon(Icons.search_off, size: 40, color: Colors.grey),
                     const SizedBox(height: 10),
                     Text(
                       _selectedCategory == null 
                         ? "No active orders available" 
                         : "No $_selectedCategory orders found", 
                       style: const TextStyle(color: Colors.grey)
                     ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), 
                itemCount: _feedProducts.length > _visibleCount
                    ? _visibleCount + 1
                    : _feedProducts.length,
                itemBuilder: (context, index) {
                  // Cek apakah ini index terakhir (tempat tombol See More)
                  if (_feedProducts.length > _visibleCount && index == _visibleCount) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _visibleCount += 10; // Tambah 10 produk lagi
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF5F63D9)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: const Text(
                            'See More',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  // Render Produk Biasa
                  return _buildBigProductCard(_feedProducts[index]);
                },
              ),
              
             const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) {
           if(i == 1) Navigator.pushReplacementNamed(context, '/orders');
           // dll..
        },
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
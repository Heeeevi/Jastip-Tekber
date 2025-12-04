import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';

// --- WARNA KONSTANTA (Sesuai Desain) ---
const Color kBgDark = Color(0xFF0E1118);
const Color kCardColor = Color(0xFF1E232F);
const Color kPrimaryAccent = Color(0xFF5F63D9); // Ungu tombol
const Color kSuccessColor = Color(0xFF4CAF50); // Hijau Setujui
const Color kErrorColor = Color(0xFFE53935); // Merah Tolak
const Color kTextWhite = Colors.white;
const Color kTextGrey = Colors.white54;

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  // State untuk Tab Pesanan (0: New, 1: Preparing, 2: Completed)
  int _selectedTabIndex = 0;
  final _svc = SupabaseService();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _products = [];
  Map<String, dynamic>? _sellerProfile;
  // online update flag removed (inline logic)

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() { _loading = true; _error = null; });
    try {
      // Ensure seller profile exists silently
      _sellerProfile = await _svc.getCurrentSellerProfile();
      if (_sellerProfile == null) {
        // If not exists, show prompt message (not auto-create here to avoid accidental seller creation)
        _error = 'Seller profile not found. Create one first from Home screen.';
        _products = [];
        _orders = [];
      } else {
        await _loadOrders();
        await _loadProducts();
      }
    } catch (e) {
      _error = 'Failed to load: $e';
    } finally {
      _loading = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _loadOrders() async {
    // Load all seller orders (we will group client-side)
    final data = await _svc.fetchSellerOrders();
    _orders = data;
  }

  Future<void> _loadProducts() async {
    final sellerId = _svc.getCurrentUser()?.id;
    if (sellerId == null) return;
    final data = await _svc.getProductsBySeller(sellerId);
    _products = data;
  }

  List<Map<String,dynamic>> _filteredOrdersForTab() {
    const newStatuses = ['pending','confirmed'];
    const prepStatuses = ['preparing','ready','delivering'];
    const doneStatuses = ['completed','cancelled'];
    switch (_selectedTabIndex) {
      case 0: return _orders.where((o) => newStatuses.contains(o['status'])).toList();
      case 1: return _orders.where((o) => prepStatuses.contains(o['status'])).toList();
      case 2: return _orders.where((o) => doneStatuses.contains(o['status'])).toList();
      default: return [];
    }
  }

  int _countTodayOrders() {
    final today = DateTime.now();
    return _orders.where((o) {
      final created = DateTime.tryParse(o['created_at'] ?? '');
      if (created == null) return false;
      return created.year == today.year && created.month == today.month && created.day == today.day;
    }).length;
  }

  int _countActiveOrders() {
    return _orders.where((o) => !['completed','cancelled'].contains(o['status'])).length;
  }

  Future<void> _changeOrderStatus(int orderId, String newStatus) async {
    try {
      await _svc.updateOrderStatus(orderId: orderId, status: newStatus);
      await _loadOrders();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed update status: $e')));
      }
    }
  }

  // Online toggle handled inline; legacy method removed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDark,
      // AppBar custom sederhana
      appBar: AppBar(
        backgroundColor: kBgDark,
        elevation: 0,
        // MODIFIKASI: Mengubah Icon statis menjadi IconButton agar bisa diklik
        leading: IconButton(
          icon: const Icon(Icons.person_outline, color: kTextWhite),
          onPressed: () {
            // Navigasi ke halaman Edit Profile Seller (dengan parameter isSeller: true)
            Navigator.pushNamed(
              context,
              '/create-seller-profile',
              arguments: {'isSeller': true},
            );
          },
        ),
        title: Text(
          "JasTip",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: kTextWhite,
                ),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          // Logout Button
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: kTextWhite),
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
      ),

      // Menggunakan SingleChildScrollView agar seluruh halaman bisa discroll
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. BUYER / SELLER TOGGLE
            Center(child: _buildRoleToggle()),
            const SizedBox(height: 24),

            // 2. DASHBOARD OVERVIEW
            Text(
              "Dashboard Overview",
              style: GoogleFonts.inter(
                color: kTextWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 3. STATS CARDS
            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
            else ...[
              Row(
                children: [
                  Expanded(child: _buildStatCard("Today's Orders", _countTodayOrders().toString())),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard("Active Orders", _countActiveOrders().toString())),
                ],
              ),
              const SizedBox(height: 30),
              // 4. ORDER MANAGEMENT SECTION
              Text(
                "Order Management",
                style: GoogleFonts.inter(
                  color: kTextWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDynamicTabBar(),
              const SizedBox(height: 20),
              _buildOrderListContent(),
              const SizedBox(height: 30),
              // 5. MENU MANAGEMENT SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Menu Management",
                    style: GoogleFonts.inter(
                      color: kTextWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/add-item');
                      await _loadProducts();
                      if (mounted) setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      "Add Item",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildProductsList(),
            ],
            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),

      // Bottom Nav Bar dengan Navigasi
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Seller Dashboard = Home untuk Seller
        backgroundColor: kBgDark,
        selectedItemColor: kPrimaryAccent,
        unselectedItemColor: kTextGrey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              // Sudah di Seller Dashboard (Home untuk Seller)
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
              // Placeholder Chat (belum ada screen)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat feature coming soon!')),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Chat",
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  // Fungsi Helper untuk menentukan konten Tab Order
  Widget _buildOrderListContent() {
    final data = _filteredOrdersForTab();
    if (data.isEmpty) {
      return const Text('No orders for this section', style: TextStyle(color: kTextGrey));
    }
    return Column(
      children: data.map((o) => _buildOrderCardDynamic(o)).toList(),
    );
  }

  Widget _buildOrderCardDynamic(Map<String, dynamic> order) {
    final buyer = order['buyer'] as Map<String, dynamic>?;
    final buyerName = buyer?['full_name'] ?? 'Buyer';
    final status = order['status'] ?? 'pending';
    final id = order['id'];
    final total = order['total_price'];
    final createdAt = order['created_at'] ?? '';
    final dt = DateTime.tryParse(createdAt);
    final createdStr = dt != null ? '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}' : createdAt;
    return Container(
      margin: const EdgeInsets.only(bottom:16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kCardColor,borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildOrderHeader('Order #$id', buyerName, createdStr, buyer?['dom_block'], buyer?['room_number']),
          const Padding(padding: EdgeInsets.symmetric(vertical:12), child: Divider(color: Colors.white12)),
          _buildOrderTotal('Rp${total.toString()}'),
          const SizedBox(height:12),
          _buildStatusButtons(id, status),
        ],
      ),
    );
  }

  Widget _buildRoleToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton("Buyer", false, () {
            // Navigasi kembali ke Home (Buyer Mode)
            Navigator.pushReplacementNamed(context, '/home');
          }),
          _buildToggleButton("Seller", true, null),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isActive, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.inter(color: kTextGrey, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.inter(
              color: kTextWhite,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicTabBar() {
    final newCount = _orders.where((o) => ['pending','confirmed'].contains(o['status'])).length;
    final prepCount = _orders.where((o) => ['preparing','ready','delivering'].contains(o['status'])).length;
    final doneCount = _orders.where((o) => ['completed','cancelled'].contains(o['status'])).length;
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kTextGrey, width: 0.5))),
      child: Row(children: [
        _buildTabItem('New ($newCount)',0),
        _buildTabItem('Preparing ($prepCount)',1),
        _buildTabItem('Completed ($doneCount)',2),
      ]),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: isSelected
                ? const Border(
                    bottom: BorderSide(color: kPrimaryAccent, width: 2),
                  )
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: isSelected ? kPrimaryAccent : kTextGrey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // --- ORDER CARD (TAB: NEW) ---
  // Legacy mock methods retained (unused) removed in dynamic version
  // Legacy placeholder widgets removed.

  // Helper khusus untuk item completed agar tidak duplikasi kode
  // Legacy unused widgets removed

  // --- Helper Widgets Shared ---

  Widget _buildOrderHeader(String orderId, String customerName, String created, String? block, String? room) {
    final loc = [if(block!=null) 'Block $block', if(room!=null) 'Room $room'].join(', ');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(orderId, style: GoogleFonts.inter(color: kTextWhite, fontSize: 16)),
          const SizedBox(height:4),
          Text(created, style: GoogleFonts.inter(color: kTextGrey, fontSize: 10)),
        ]),
        Row(children:[
          const CircleAvatar(backgroundColor: Colors.grey, radius:16),
          const SizedBox(width:8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children:[
            Text(customerName, style: GoogleFonts.inter(color: kTextWhite, fontWeight: FontWeight.bold)),
            if(loc.isNotEmpty) Text(loc, style: GoogleFonts.inter(color: kTextGrey, fontSize:10)),
          ]),
        ]),
      ],
    );
  }

// GANTI FUNGSI INI
  Widget _buildStatusButtons(int orderId, String currentStatus) {
    // 1. Tampilan jika order sudah selesai atau dibatalkan (Final State)
    if (['completed', 'cancelled'].contains(currentStatus)) {
      final isSuccess = currentStatus == 'completed';
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSuccess ? kSuccessColor.withOpacity(0.2) : kErrorColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSuccess ? kSuccessColor : kErrorColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.cancel,
              color: isSuccess ? kSuccessColor : kErrorColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isSuccess ? 'ORDER COMPLETED' : 'ORDER CANCELLED',
              style: TextStyle(
                color: isSuccess ? kSuccessColor : kErrorColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
    }

    // 2. Tentukan Langkah Selanjutnya (Sequential Logic)
    String? nextStatus;
    String actionLabel = '';
    Color buttonColor = kPrimaryAccent; // Default Ungu

    switch (currentStatus) {
      case 'pending':
        nextStatus = 'confirmed';
        actionLabel = 'Terima Pesanan'; // Confirm
        break;
      case 'confirmed':
        nextStatus = 'preparing';
        actionLabel = 'Mulai Masak/Siapkan'; // Start
        break;
      case 'preparing':
        nextStatus = 'ready';
        actionLabel = 'Pesanan Siap (Ready)'; // Ready
        buttonColor = Colors.orange; // Pembeda warna
        break;
      case 'ready':
        nextStatus = 'delivering';
        actionLabel = 'Antar Pesanan (Deliver)'; // Deliver
        buttonColor = Colors.blue;
        break;
      case 'delivering':
        nextStatus = 'completed';
        actionLabel = 'Selesaikan Pesanan'; // Complete
        buttonColor = kSuccessColor;
        break;
      default:
        nextStatus = null;
    }

    // 3. Render Tampilan Status Bar & Tombol
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A. Tampilan Status Saat Ini (Mirip Dropdown tapi Read-only)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: kTextGrey, size: 16),
              const SizedBox(width: 8),
              Text(
                'Status: ${currentStatus.toUpperCase()}',
                style: const TextStyle(color: kTextWhite, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),

        // B. Tombol Aksi (Next Step & Cancel)
        Row(
          children: [
            // Tombol Utama (Next Step)
            if (nextStatus != null)
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _changeOrderStatus(orderId, nextStatus!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                      fontSize: 13
                    ),
                  ),
                ),
              ),

            // Spacer jika ada tombol next
            if (nextStatus != null) const SizedBox(width: 10),

            // Tombol Cancel (Merah)
            // Hanya muncul jika status belum 'delivering' (supaya tidak cancel saat di jalan)
            if (currentStatus != 'delivering')
              SizedBox(
                width: 100, // Lebar fixed agar rapi
                child: OutlinedButton(
                  onPressed: () => _changeOrderStatus(orderId, 'cancelled'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kErrorColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Tolak',
                    style: TextStyle(color: kErrorColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductsList() {
    if (_products.isEmpty) {
      return const Text('No products yet. Add one.', style: TextStyle(color: kTextGrey));
    }
    return Column(children: _products.map((p){
      final available = p['is_available'] == true;
      return Container(
        margin: const EdgeInsets.only(bottom:12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: kCardColor, borderRadius: BorderRadius.circular(16)),
        child: Row(children:[
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Text(p['name'] ?? 'Item', style: GoogleFonts.inter(color: kTextWhite, fontWeight: FontWeight.bold)),
            if(p['category']!=null) Text(p['category'], style: GoogleFonts.inter(color: kTextGrey, fontSize:11)),
            const SizedBox(height:6),
            Row(children:[Switch(
              value: available,
              activeColor: kPrimaryAccent,
              onChanged: (v) async {
                try {
                  await _svc.updateProduct(productId: p['id'], isAvailable: v);
                  p['is_available'] = v;
                  if (mounted) setState(() {});
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed update product: $e')));
                }
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ), const SizedBox(width:6), Text(available? 'Available':'Unavailable', style: TextStyle(color: available? kSuccessColor: Colors.red, fontSize:11))])
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children:[
            Text('Rp${(p['price'] ?? 0).toString()}', style: GoogleFonts.inter(color: kTextWhite, fontWeight: FontWeight.bold)),
          ])
        ]),
      );
    }).toList());
  }

  Widget _buildOrderTotal(String total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Total",
          style: GoogleFonts.inter(
            color: kTextWhite,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          total,
          style: GoogleFonts.inter(
            color: kTextWhite,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // Removed legacy menu/item row helpers (replaced by dynamic products list)

  // Legacy icon action removed.

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
}

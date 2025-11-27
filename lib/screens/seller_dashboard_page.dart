import 'package:flutter/material.dart';
import 'buyer_dashboard_screen.dart';
import 'add_item_screen.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  // State untuk status pesanan (di tab Preparing)
  String _currentStatus = "menuju restoran";
  
  // State untuk Tab (0: New, 1: Preparing, 2: Completed)
  int _selectedTabIndex = 2; 
  
  // State untuk Switch
  bool _isOffline = true;
  bool _isMenuAvailable = true;

  // Daftar opsi status (Simple aja, warnanya doang)
  final List<Map<String, dynamic>> _statusOptions = [
    {'label': 'menuju restoran', 'color': const Color(0xFF5E6575)},
    {'label': 'Diproses Resto', 'color': const Color(0xFF2F80ED)},
    {'label': 'menuju titik antar', 'color': const Color(0xFFF2C94C)},
    {'label': 'pesanan sampai', 'color': const Color(0xFF27AE60)},
  ];

  // Helper safe color
  Color _getStatusColor(String statusLabel) {
    var option = _statusOptions.firstWhere(
      (element) => element['label'] == statusLabel,
      orElse: () => {'color': const Color(0xFF383E4E)}, 
    );
    return option['color'] ?? const Color(0xFF383E4E);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141724),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _buildRoleToggle()),
            const SizedBox(height: 24),

            _buildSectionHeader("Dashboard Overview", withOfflineSwitch: true),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard("Today's Orders", "20")),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard("Active Orders", "5")),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionHeader("Order Management"),
            const SizedBox(height: 12),
            _buildCustomTabBar(),
            const SizedBox(height: 16),

            // LOGIKA GANTI TAMPILAN BERDASARKAN TAB
            _buildOrderListContent(),
            
            const SizedBox(height: 24),

            // Bagian Menu Management
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Menu Management",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddItemPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5A6BF2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("Add Item", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )

              ],
            ),
            const SizedBox(height: 16),
            _buildMenuCard(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- LOGIC SWITCHER CONTENT ---
  Widget _buildOrderListContent() {
    if (_selectedTabIndex == 1) {
      // Tampilan Tab Preparing
      return _buildPreparingOrderCard();
    } else if (_selectedTabIndex == 2) {
      // Tampilan Tab Completed
      return Column(
        children: [
          _buildCompletedOrderCard("Selesai", const Color(0xFF27AE60)), // Hijau
          const SizedBox(height: 16),
          _buildCompletedOrderCard("Dibatalkan", const Color(0xFFEB5757)), // Merah
        ],
      );
    } else {
      // Tampilan Tab New
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const Text("No new orders", style: TextStyle(color: Colors.grey)),
      );
    }
  }

  // --- WIDGET BUILDERS ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.grey[800],
          child: const Icon(Icons.person_outline, color: Colors.white),
        ),
      ),
      title: const Center(child: Text("JasTip", style: TextStyle(fontWeight: FontWeight.bold))),
      actions: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {},
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Text('2', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        )
      ],
    );
  }

  //pindah halaman ke buyer
  Widget _buildRoleToggle() {
  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFF202533),
      borderRadius: BorderRadius.circular(25),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            // Navigasi balik ke BuyerDashboardScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BuyerDashboardScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.transparent, // Bisa diatur sesuai active
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Buyer",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF5A6BF2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "Seller",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildSectionHeader(String title, {bool withOfflineSwitch = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        if (withOfflineSwitch)
          Row(
            children: [
              Switch(
                value: _isOffline,
                onChanged: (val) => setState(() => _isOffline = val),
                activeColor: Colors.white,
                activeTrackColor: Colors.grey,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.white24,
              ),
              const Text("Offline", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
      ],
    );
  }

  Widget _buildStatCard(String title, String count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF202533),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Row(
      children: [
        _buildTabItem("New (3)", 0),
        const SizedBox(width: 20),
        _buildTabItem("Preparing (2)", 1),
        const SizedBox(width: 20),
        _buildTabItem("Completed (15)", 2),
      ],
    );
  }

  Widget _buildTabItem(String text, int index) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: IntrinsicWidth( 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelected ? const Color(0xFF5A6BF2) : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                color: const Color(0xFF5A6BF2),
              )
          ],
        ),
      ),
    );
  }

  // --- KARTU TAB PREPARING (Dropdown & Cancel) ---
  Widget _buildPreparingOrderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF202533),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(),
          const Divider(color: Colors.white24, height: 24),
          _buildOrderItem("1x Nasi Goreng", "Rp15.000"),
          _buildOrderItem("1x Es Teh", "Rp5.000"),
          const SizedBox(height: 8),
          _buildTotalRow(),
          const SizedBox(height: 16),

          // Tombol Aksi (Status Dropdown & Cancel)
          Row(
            children: [
              Expanded(flex: 2, child: _buildStatusDropdown()),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEB5757),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text("Cancel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- KARTU TAB COMPLETED (Tombol Full Width) ---
  Widget _buildCompletedOrderCard(String statusText, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF202533),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(),
          const Divider(color: Colors.white24, height: 24),
          _buildOrderItem("1x Nasi Goreng", "Rp15.000"),
          _buildOrderItem("1x Es Teh", "Rp5.000"),
          const SizedBox(height: 8),
          _buildTotalRow(),
          const SizedBox(height: 16),

          // Tombol Status Statis Full Width
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              statusText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Order #0001", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("April 20, 2025 | 10:00 AM", style: TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
        Row(
          children: [
            const CircleAvatar(backgroundColor: Colors.grey, radius: 14), 
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text("Michael", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                Text("Block A, Room 302", style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text("Total", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text("Rp20.000", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return PopupMenuButton<String>(
      offset: const Offset(0, -10),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (String newValue) {
        setState(() {
          _currentStatus = newValue;
        });
      },
      itemBuilder: (BuildContext context) {
        return _statusOptions.map((option) {
          String label = option['label'];
          Color color = option['color'] ?? Colors.blue; 

          return PopupMenuItem<String>(
            value: label,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            height: 40,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "Status: $label",
                style: const TextStyle(
                  color: Colors.white, // <--- FORCE WHITE HERE
                  fontWeight: FontWeight.bold,
                  fontSize: 12
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _getStatusColor(_currentStatus), 
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        child: Text(
          "Status: $_currentStatus",
          style: const TextStyle(
            color: Colors.white, // <--- FORCE WHITE HERE
            fontWeight: FontWeight.w600
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildOrderItem(String name, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
          Text(price, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildMenuCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF202533),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage("https://images.unsplash.com/photo-1512058564366-18510be2db19?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Nasi Goreng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Rp15000", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const Text("Rice", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 40,
                      child: Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _isMenuAvailable,
                          onChanged: (v) => setState(() => _isMenuAvailable = v),
                          activeColor: const Color(0xFF5A6BF2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Available", 
                      style: TextStyle(color: _isMenuAvailable ? Colors.green : Colors.grey, fontSize: 10)
                    ),
                    const Spacer(),
                    _buildIconBtn(Icons.edit, Colors.grey),
                    const SizedBox(width: 8),
                    _buildIconBtn(Icons.delete, Colors.grey),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white12,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF141724),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF5A6BF2),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      currentIndex: 1, 
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Orders"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: "Favorites"),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
      ],
    );
  }
}
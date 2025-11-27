import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
            Row(
              children: [
                Expanded(child: _buildStatCard("Today's Orders", "20")),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard("Active Orders", "5")),
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
            _buildCustomTabBar(),
            const SizedBox(height: 20),

            // --- LOGIC SWITCH KONTEN BERDASARKAN TAB ---
            // Bagian ini menentukan widget apa yang muncul berdasarkan _selectedTabIndex
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
                  onPressed: () {
                    Navigator.pushNamed(context, '/add-item');
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
            const SizedBox(height: 16),
            _buildMenuItemCard(),
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
    switch (_selectedTabIndex) {
      case 0:
        return _buildNewOrderCard(); // Tampilan Tab New
      case 1:
        return _buildPreparingOrderCard(); // Tampilan Tab Preparing
      case 2:
        return _buildCompletedOrderCard(); // Tampilan Tab Completed
      default:
        return const SizedBox();
    }
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

  Widget _buildCustomTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kTextGrey, width: 0.5)),
      ),
      child: Row(
        children: [
          _buildTabItem("New (3)", 0),
          _buildTabItem("Preparing (2)", 1),
          _buildTabItem("Completed (15)", 2),
        ],
      ),
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
  Widget _buildNewOrderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildOrderHeader("Order #0002", "Michael"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white12),
          ),
          _buildOrderItemRow("1x Joder", "Rp20000"),
          const SizedBox(height: 8),
          _buildOrderItemRow("1x Es Teh", "Rp5000"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white12),
          ),
          _buildOrderTotal("Rp25000"),
          const SizedBox(height: 16),
          // Buttons untuk New Order
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kErrorColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Tolak",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSuccessColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Setujui",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- ORDER CARD (TAB: PREPARING) ---
  Widget _buildPreparingOrderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildOrderHeader("Order #0001", "Michael"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white12),
          ),
          _buildOrderItemRow("1x Nasi Goreng", "Rp15.000"),
          const SizedBox(height: 8),
          _buildOrderItemRow("1x Es Teh", "Rp5.000"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white12),
          ),
          _buildOrderTotal("Rp20.000"),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white12,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Status: menuju restoran",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kErrorColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- ORDER CARD (TAB: COMPLETED) ---
  Widget _buildCompletedOrderCard() {
    // Karena di desain ada 2 contoh (Selesai & Dibatalkan), kita bungkus dalam Column
    return Column(
      children: [
        // CONTOH 1: Status Selesai (Tombol Hijau Full)
        _buildCompletedCardItem(
          statusText: "Selesai",
          statusColor: kSuccessColor,
        ),

        const SizedBox(height: 16),

        // CONTOH 2: Status Dibatalkan (Tombol Merah Full)
        _buildCompletedCardItem(
          statusText: "Dibatalkan",
          statusColor: kErrorColor,
        ),
      ],
    );
  }

  // Helper khusus untuk item completed agar tidak duplikasi kode
  Widget _buildCompletedCardItem({
    required String statusText,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildOrderHeader("Order #0001", "Michael"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white12),
          ),
          _buildOrderItemRow("1x Nasi Goreng", "Rp15.000"),
          const SizedBox(height: 8),
          _buildOrderItemRow("1x Es Teh", "Rp5.000"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white12),
          ),
          _buildOrderTotal("Rp20.000"),
          const SizedBox(height: 16),

          // Tombol Status Full Width
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {}, // Biasanya tombol histori tidak bisa diklik
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    statusColor, // Warna sesuai parameter (Merah/Hijau)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets Shared ---

  Widget _buildOrderHeader(String orderId, String customerName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              orderId,
              style: GoogleFonts.inter(color: kTextWhite, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              "April 20, 2025 | 10:00 AM",
              style: GoogleFonts.inter(color: kTextGrey, fontSize: 10),
            ),
          ],
        ),
        Row(
          children: [
            const CircleAvatar(backgroundColor: Colors.grey, radius: 16),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  customerName,
                  style: GoogleFonts.inter(
                    color: kTextWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Block A, Room 302",
                  style: GoogleFonts.inter(color: kTextGrey, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ],
    );
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

  Widget _buildOrderItemRow(String item, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(item, style: GoogleFonts.inter(color: kTextWhite, fontSize: 14)),
        Text(price, style: GoogleFonts.inter(color: kTextWhite, fontSize: 14)),
      ],
    );
  }

  // --- MENU ITEM CARD ---
  Widget _buildMenuItemCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Gambar Menu
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage("https://picsum.photos/id/40/200/200"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info Menu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nasi Goreng",
                  style: GoogleFonts.inter(
                    color: kTextWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Rice",
                  style: GoogleFonts.inter(color: kTextGrey, fontSize: 12),
                ),
                const SizedBox(height: 8),

                // Toggle Available
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 40,
                      child: Switch(
                        value: true,
                        activeColor: kPrimaryAccent,
                        onChanged: (val) {},
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Available",
                      style: GoogleFonts.inter(
                        color: kSuccessColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Harga & Edit Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Rp15000",
                style: GoogleFonts.inter(
                  color: kTextWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildIconAction(Icons.edit, Colors.grey),
                  const SizedBox(width: 8),
                  _buildIconAction(Icons.delete, Colors.grey),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconAction(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

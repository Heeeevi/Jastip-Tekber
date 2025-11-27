import 'package:flutter/material.dart';

// --- KONSTANTA WARNA ---
const Color kBackgroundColor = Color(0xFF19222C); // Latar belakang utama
const Color kHeaderDarkGradient = Color(
  0xFF111820,
); // Warna gelap di bawah header
const Color kAccentColor = Color(0xFF5B61E6); // Tombol plus / aksen
const Color kGreenColor = Color(0xFF4CAF50); // Tombol "Open Now"
const Color kCardColor = Color(0xFF232C38); // Latar kartu produk
const Color kTextColorPrimary = Colors.white;
const Color kTextColorSecondary = Colors.grey; // Warna teks sekunder

class SellerProfilePage extends StatelessWidget {
  const SellerProfilePage({super.key});

  // Data dummy untuk contoh tampilan
  final String sellerName = "Alan Walker";
  final String sellerImage = "https://i.pravatar.cc/300?img=12";
  final String headerBackgroundImage = "https://picsum.photos/id/292/800/600";
  final String productPlaceholder = "https://picsum.photos/id/40/400/400";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      // Menggunakan CustomScrollView untuk efek header yang dinamis
      body: CustomScrollView(
        slivers: [
          // --- BAGIAN 1: SLIVER APP BAR (Header Dinamis) ---
          _buildSliverAppBar(context),

          // --- BAGIAN 2: STATUS BAR (Delivery time & Open status) ---
          SliverToBoxAdapter(child: _buildStatusBar()),

          // --- BAGIAN 3: JUDUL SECTION ---
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                "Active Purchase Orders",
                style: TextStyle(
                  color: kTextColorPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // --- BAGIAN 4: GRID PRODUK ---
          _buildProductGrid(context),

          // Padding bawah agar tidak mentok
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  // ================= HELPER WIDGETS =================

  // 1. Membangun SliverAppBar (Header)
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: kBackgroundColor,
      expandedHeight: 280.0, // Tinggi header saat terbuka penuh
      pinned: true, // Toolbar tetap terlihat saat discroll ke atas
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextColorPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        sellerName,
        style: const TextStyle(
          color: kTextColorPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: kTextColorPrimary,
              size: 20,
            ),
            onPressed: () {},
          ),
        ),
      ],
      // Bagian fleksibel yang berisi gambar dan info seller
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Lapisan 1: Gambar Latar Belakang Header
            Image.network(headerBackgroundImage, fit: BoxFit.cover),
            // Lapisan 2: Gradien Gelap (agar teks terbaca)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    kHeaderDarkGradient.withOpacity(0.5),
                    kHeaderDarkGradient.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
            // Lapisan 3: Konten Info Seller di bagian bawah header
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  // Avatar Profile
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(sellerImage),
                    backgroundColor: kCardColor,
                  ),
                  const SizedBox(width: 16),
                  // Nama, Rating, Follow
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          sellerName,
                          style: const TextStyle(
                            color: kTextColorPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "4.8 (50 reviews)",
                              // FIXED: Menggunakan withOpacity alih-alih [300]
                              style: TextStyle(
                                color: kTextColorSecondary.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Tombol Follow Kecil
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: kCardColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: kTextColorSecondary.withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            "Follow",
                            style: TextStyle(
                              color: kTextColorPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tombol Chat
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.chat_bubble_outline, color: kTextColorPrimary),
                      SizedBox(height: 4),
                      Text(
                        "Chat",
                        style: TextStyle(
                          color: kTextColorPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Membangun Status Bar (Delivery time & Open Now)
  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: kHeaderDarkGradient,
      child: Row(
        children: [
          // FIXED: Menghapus [400]
          const Icon(Icons.access_time_filled, color: kTextColorSecondary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // FIXED: Menambahkan const untuk optimasi
              // FIXED: Menghapus [400]
              Text(
                "Delivery time",
                style: TextStyle(color: kTextColorSecondary, fontSize: 12),
              ),
              Text(
                "20-30min",
                style: TextStyle(
                  color: kTextColorPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Badge "Open Now"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: kGreenColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Open Now",
              style: TextStyle(
                color: kGreenColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Membangun Grid Produk
  Widget _buildProductGrid(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
        ),
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return _ProductCard(
            imageUrl: productPlaceholder,
            name: "Ramen",
            price: "Rp25.000",
          );
        }, childCount: 4),
      ),
    );
  }
}

// ================= WIDGET KARTU PRODUK TERPISAH =================
class _ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String price;

  const _ProductCard({
    required this.imageUrl,
    required this.name,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Gambar Produk
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          // Bagian Informasi Produk
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: kTextColorPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        color: kTextColorPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Tombol Plus (+)
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: kAccentColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

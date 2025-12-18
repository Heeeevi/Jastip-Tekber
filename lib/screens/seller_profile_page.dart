import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../cart_provider.dart'; // Pastikan path ini benar (sesuai posisi filemu)

// --- Theme constants ---
const Color kBackgroundColor = Color(0xFF19222C);
const Color kHeaderDarkGradient = Color(0xFF111820);
const Color kAccentColor = Color(0xFF5B61E6);
const Color kGreenColor = Color(0xFF4CAF50);
const Color kCardColor = Color(0xFF232C38);
const Color kTextColorPrimary = Colors.white;
const Color kTextColorSecondary = Colors.grey;

class SellerProfilePage extends StatefulWidget {
  const SellerProfilePage({super.key});

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  final _svc = SupabaseService();
  Map<String, dynamic>? _seller;
  String? _sellerId;
  List<Map<String, dynamic>> _products = [];
  bool _loadingProducts = true;
  String? _error;
  List<Map<String, dynamic>> _sellerActiveOrders = [];
  bool _loadingSellerOrders = true;

  // --- SOLUSI: Tambahkan variabel ini untuk mengunci loading data ---
  bool _isDataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // --- LOGIKA KUNCI: Cuma jalan kalau data belum pernah di-load ---
    if (!_isDataLoaded) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _seller = args?['seller'] as Map<String, dynamic>?;
      _sellerId =
          args?['seller_id']?.toString() ?? (_seller?['id']?.toString());

      if (_sellerId != null || _seller != null) {
        _loadData();
      } else {
        setState(() {
          _error = 'No seller ID provided';
        });
      }

      // Kunci supaya gak jalan lagi pas klik (+)
      _isDataLoaded = true;
    }
  }

  Future<void> _loadData() async {
    // Kita tidak perlu setState loading=true di sini karena sudah di-init true di atas
    // dan kita tidak mau spinner muncul lagi saat refresh kecil

    try {
      if (_seller == null && _sellerId != null) {
        _seller = await _svc.getSellerById(_sellerId!);
      }
      if (_sellerId == null && _seller != null) {
        _sellerId = _seller!['id']?.toString();
      }
      if (_sellerId != null) {
        // Gunakan Future.wait supaya request jalan barengan (lebih cepat)
        final results = await Future.wait([
          _svc.getProductsBySeller(_sellerId!),
          _svc.fetchActiveOrdersBySeller(_sellerId!),
        ]);

        if (mounted) {
          setState(() {
            _products = results[0] as List<Map<String, dynamic>>;
            _sellerActiveOrders = results[1] as List<Map<String, dynamic>>;
          });
        }
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
        });
    } finally {
      if (mounted)
        setState(() {
          _loadingProducts = false;
          _loadingSellerOrders = false;
        });
    }
  }

  Future<void> _checkout() async {
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (_sellerId == null || cart.items.isEmpty) return;
    try {
      String address = '';
      String timeWindow = '';

      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          // Kita pakai Theme gelap khusus untuk dialog ini
          return Theme(
            data: Theme.of(
              context,
            ).copyWith(dialogBackgroundColor: const Color(0xFF1C1F26)),
            child: AlertDialog(
              backgroundColor: const Color(
                0xFF1C1F26,
              ), // Background Dialog Gelap
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Delivery details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Input Address
                  TextField(
                    style: const TextStyle(
                      color: Colors.white,
                    ), // Warna teks yang kamu ketik
                    decoration: InputDecoration(
                      hintText:
                          'Delivery address', // Pakai hintText biar ga naik ke atas
                      hintStyle: const TextStyle(
                        color: Colors.white38,
                      ), // Warna teks placeholder abu-abu
                      filled: true,
                      fillColor: const Color(
                        0xFF2A2E35,
                      ), // Background kolom input agak terang dikit
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (v) => address = v.trim(),
                  ),
                  const SizedBox(height: 16), // Jarak antar input
                  // Input Time
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Delivery time (e.g. 6:00 - 7:00 PM)',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF2A2E35),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (v) => timeWindow = v.trim(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      );

      if (ok != true) return;

      final order = await _svc.createOrder(
        sellerId: _sellerId!,
        totalPrice: cart.totalAmount.toDouble(),
        deliveryAddress: address.isEmpty ? null : address,
        deliveryTime: timeWindow.isEmpty ? null : timeWindow,
      );

      for (final cartItem in cart.items.values) {
        await _svc.addOrderItem(
          orderId: order['id'] as int,
          productId: int.parse(cartItem.id),
          quantity: cartItem.quantity,
          price: cartItem.price.toDouble(),
        );
      }

      cart.clear();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order created!')));
        Navigator.pushReplacementNamed(context, '/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to checkout: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    final sellerName =
        _seller?['display_name']?.toString() ??
        (_seller?['name']?.toString() ?? 'Seller');
    final isOpen = (_seller?['is_online'] as bool?) ?? true;
    final rating = (_seller?['rating'] as num?)?.toDouble() ?? 0.0;

    if (_sellerId == null && _seller == null) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Seller Profile'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.store_outlined, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              const Text(
                'No seller provided',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/home'),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      // Checkout Bar Sticky di bawah
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : _buildStickyCartBar(cart),

      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, sellerName, rating),
          SliverToBoxAdapter(child: _buildStatusBar(isOpen)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: const Text(
                'Active Purchase Orders',
                style: TextStyle(
                  color: kTextColorPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildSellerActiveOrders()),
          _buildProductGrid(cart),

          // Jarak extra di bawah supaya tidak ketutup tombol checkout
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // --- WIDGET BARU: Floating Cart Bar (Gaya Pil Biru) ---
  Widget _buildStickyCartBar(CartProvider cart) {
    final total = cart.totalAmount;
    final itemsCount = cart.itemCount;

    // Ambil nama barang pertama & kedua untuk preview text (e.g. "Ramen reguler, ...")
    String itemsPreview = cart.items.values.map((e) => e.title).join(", ");
    if (itemsPreview.length > 30) {
      itemsPreview = "${itemsPreview.substring(0, 30)}...";
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        30,
      ), // Margin bawah agak naik
      color: Colors.transparent, // Transparan biar kelihatan floating
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Navigasi ke halaman Konfirmasi Pesanan
            Navigator.pushNamed(
              context,
              '/order-confirmation',
              arguments: {
                'seller': _seller,
              }, // Kirim data seller ke halaman konfirmasi
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: kAccentColor, // Warna Ungu/Biru
              borderRadius: BorderRadius.circular(30), // Membulat seperti pil
              boxShadow: [
                BoxShadow(
                  color: kAccentColor.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Bagian Kiri: Item Count & Preview Nama
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$itemsCount item',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      itemsPreview,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Bagian Kanan: Total Harga
                Text(
                  'Rp$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(CartProvider cart) {
    if (_loadingProducts) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_error != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Error: $_error'),
        ),
      );
    }
    if (_products.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No products available for this seller.'),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final p = _products[index];
          final name = p['name']?.toString() ?? 'Item';
          final price = (p['price'] as num?)?.toDouble() ?? 0.0;
          final pid = p['id'] as int;

          final qty = cart.getQuantity(pid.toString());
          return Container(
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. GAMBAR PRODUK ---
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      'https://picsum.photos/seed/$pid/400/400',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (ctx, err, stack) => Container(
                        color: Colors.grey,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),

                // --- 2. INFO PRODUK ---
                Padding(
                  padding: const EdgeInsets.all(
                    10.0,
                  ), // Padding sedikit dikecilkan biar muat
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Produk
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kTextColorPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // HARGA & TOMBOL (DIPISAH JADI COLUMN AGAR TIDAK OVERFLOW)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Harga di Atas
                          Text(
                            'Rp${price.toInt()}',
                            style: const TextStyle(
                              color: kAccentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Tombol di Bawah (Rata Kanan)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Penting: Biar Row tidak menuhin lebar
                              children: [
                                _QtyButton(
                                  icon: Icons.remove,
                                  onTap: qty > 0
                                      ? () => cart.removeSingleItem(
                                          pid.toString(),
                                        )
                                      : null,
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$qty',
                                    style: const TextStyle(
                                      color: kTextColorPrimary,
                                    ),
                                  ),
                                ),
                                _QtyButton(
                                  icon: Icons.add,
                                  onTap: () => cart.addItem(
                                    pid.toString(),
                                    price.toInt(),
                                    name,
                                  ),
                                ),
                              ],
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
        }, childCount: _products.length),
      ),
    );
  }

  Widget _buildSellerActiveOrders() {
    if (_loadingSellerOrders)
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    if (_sellerActiveOrders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1F26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'No orders here — want to order now?',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _sellerActiveOrders.map((o) {
          final items = List<Map<String, dynamic>>.from(o['order_items'] ?? []);
          final status = o['status']?.toString() ?? 'pending';
          final total = (o['total_price'] as num?)?.toDouble() ?? 0.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1F26),
              borderRadius: BorderRadius.circular(12),
            ),
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
                        color: kAccentColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Rp${total.toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final it in items)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(it['quantity'] as num?)?.toInt() ?? 1} x ${(it['product']?['name'] ?? 'Item').toString()}',
                      ),
                      Text(
                        'Rp${((it['price'] as num?)?.toDouble() ?? 0).toInt()}',
                      ),
                    ],
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/orders'),
                    child: const Text('View order'),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    String sellerName,
    double rating,
  ) {
    return SliverAppBar(
      backgroundColor: kBackgroundColor,
      expandedHeight: 260,
      pinned: true,
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
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://picsum.photos/id/292/800/600',
              fit: BoxFit.cover,
            ),
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
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage('assets/images/seller1.jpg'),
                    backgroundColor: kCardColor,
                  ),
                  const SizedBox(width: 16),
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
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${rating.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: kTextColorSecondary.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      try {
                        if (_sellerId == null) return;
                        final conv = await _svc.ensureConversationWithSeller(
                          _sellerId!,
                        );
                        if (!mounted) return;
                        Navigator.pushNamed(
                          context,
                          '/chat',
                          arguments: {
                            'conversation_id': conv['id'].toString(),
                            'seller_id': _sellerId,
                          },
                        );
                      } catch (e) {
                        if (mounted)
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: kTextColorPrimary,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Chat',
                          style: TextStyle(
                            color: kTextColorPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: kHeaderDarkGradient,
      child: Row(
        children: [
          const Icon(Icons.access_time_filled, color: kTextColorSecondary),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery time',
                style: TextStyle(color: kTextColorSecondary, fontSize: 12),
              ),
              Text(
                '20-30min',
                style: TextStyle(
                  color: kTextColorPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: kGreenColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isOpen ? 'Open Now' : 'Closed',
              style: const TextStyle(
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
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyButton({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        width: 28,
        decoration: BoxDecoration(
          color: kAccentColor.withOpacity(onTap == null ? 0.4 : 1.0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

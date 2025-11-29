import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

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

  // Per-seller cart: productId -> quantity
  final Map<int, int> _cart = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _seller = args?['seller'] as Map<String, dynamic>?;
    _sellerId = args?['seller_id']?.toString() ?? (_seller?['id']?.toString());
    
    // Debug: print what we received
    print('SellerProfilePage args: $args');
    print('SellerProfilePage _sellerId: $_sellerId');
    print('SellerProfilePage _seller: $_seller');
    
    if (_sellerId != null || _seller != null) {
      _loadData();
    } else {
      // No seller data provided - show error
      setState(() { _error = 'No seller ID provided'; });
    }
  }

  Future<void> _loadData() async {
    setState(() { _loadingProducts = true; _loadingSellerOrders = true; _error = null; });
    try {
      print('[SellerProfilePage] _loadData start - sellerId: $_sellerId, seller: $_seller');
      
      if (_seller == null && _sellerId != null) {
        print('[SellerProfilePage] Fetching seller by ID: $_sellerId');
        _seller = await _svc.getSellerById(_sellerId!);
        print('[SellerProfilePage] Seller fetched: $_seller');
      }
      if (_sellerId == null && _seller != null) {
        _sellerId = _seller!['id']?.toString();
        print('[SellerProfilePage] Extracted sellerId from seller: $_sellerId');
      }
      if (_sellerId != null) {
        print('[SellerProfilePage] Fetching products for seller: $_sellerId');
        _products = await _svc.getProductsBySeller(_sellerId!);
        print('[SellerProfilePage] Products fetched: ${_products.length} items');
        print('[SellerProfilePage] Products: $_products');
        
        print('[SellerProfilePage] Fetching seller active orders for: $_sellerId');
        _sellerActiveOrders = await _svc.fetchActiveOrdersBySeller(_sellerId!);
        print('[SellerProfilePage] Seller active orders: ${_sellerActiveOrders.length} orders');
      } else {
        print('[SellerProfilePage] ERROR: _sellerId is still null after processing!');
      }
    } catch (e) {
      print('[SellerProfilePage] ERROR loading data: $e');
      _error = e.toString();
    } finally {
      setState(() { _loadingProducts = false; _loadingSellerOrders = false; });
    }
  }

  void _addToCart(int productId) {
    setState(() { _cart[productId] = (_cart[productId] ?? 0) + 1; });
  }

  void _removeFromCart(int productId) {
    setState(() {
      final current = _cart[productId] ?? 0;
      if (current <= 1) {
        _cart.remove(productId);
      } else {
        _cart[productId] = current - 1;
      }
    });
  }

  double _cartTotal() {
    double total = 0;
    for (final entry in _cart.entries) {
      final product = _products.firstWhere(
        (p) => p['id'] == entry.key,
        orElse: () => {},
      );
      if (product.isNotEmpty) {
        final price = (product['price'] as num?)?.toDouble() ?? 0.0;
        total += price * entry.value;
      }
    }
    return total;
  }

  Future<void> _checkout() async {
    if (_sellerId == null || _cart.isEmpty) return;
    try {
      String address = '';
      String timeWindow = '';
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Delivery details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Delivery address', filled: true),
                  onChanged: (v) => address = v.trim(),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(labelText: 'Delivery time (e.g. 6:00 - 7:00 PM)', filled: true),
                  onChanged: (v) => timeWindow = v.trim(),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
            ],
          );
        },
      );
      if (ok != true) return;
      final order = await _svc.createOrder(
        sellerId: _sellerId!,
        totalPrice: _cartTotal(),
        deliveryAddress: address.isEmpty ? null : address,
        deliveryTime: timeWindow.isEmpty ? null : timeWindow,
      );
      for (final entry in _cart.entries) {
        final product = _products.firstWhere(
          (p) => p['id'] == entry.key,
          orElse: () => {},
        );
        if (product.isNotEmpty) {
          await _svc.addOrderItem(
            orderId: order['id'] as int,
            productId: product['id'] as int,
            quantity: entry.value,
            price: (product['price'] as num?)?.toDouble() ?? 0.0,
          );
        }
      }
      setState(() { _cart.clear(); });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created!')),
        );
        Navigator.pushReplacementNamed(context, '/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to checkout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
  final sellerName = _seller?['display_name']?.toString() ?? (_seller?['name']?.toString() ?? 'Seller');
  final isOpen = (_seller?['is_online'] as bool?) ?? true;
  final rating = (_seller?['rating'] as num?)?.toDouble() ?? 0.0;
    
    // Show error state if no seller ID provided at all
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
                style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please open a store from Home',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: kBackgroundColor,
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
          // NOTE: We can show an empty state here since this page focuses on the seller store
          SliverToBoxAdapter(child: _buildSellerActiveOrders()),
          _buildProductGrid(),
          SliverToBoxAdapter(child: _buildCartBar()),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildSellerActiveOrders() {
    if (_loadingSellerOrders) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_sellerActiveOrders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF1C1F26), borderRadius: BorderRadius.circular(12)),
          child: const Text('No orders here — want to order now?', style: TextStyle(color: Colors.white70)),
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
            decoration: BoxDecoration(color: const Color(0xFF1C1F26), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: kAccentColor, borderRadius: BorderRadius.circular(10)),
                  child: Text(status, style: const TextStyle(fontSize: 11, color: Colors.white)),
                ),
                const Spacer(),
                Text('Rp${total.toInt()}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
              for (final it in items)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${(it['quantity'] as num?)?.toInt() ?? 1} x ${(it['product']?['name'] ?? 'Item').toString()}'),
                    Text('Rp${((it['price'] as num?)?.toDouble() ?? 0).toInt()}'),
                  ],
                ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/orders');
                  },
                  child: const Text('View order'),
                ),
              )
            ]),
          );
        }).toList(),
      ),
    );
  }

  // Header app bar
  Widget _buildSliverAppBar(BuildContext context, String sellerName, double rating) {
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
        style: const TextStyle(color: kTextColorPrimary, fontWeight: FontWeight.w600),
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
            icon: const Icon(Icons.share_outlined, color: kTextColorPrimary, size: 20),
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network('https://picsum.photos/id/292/800/600', fit: BoxFit.cover),
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
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text('${rating.toStringAsFixed(1)}', style: TextStyle(color: kTextColorSecondary.withOpacity(0.7), fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      // Ensure a conversation exists and navigate to chat
                      try {
                        if (_sellerId == null) return;
                        final conv = await _svc.ensureConversationWithSeller(_sellerId!);
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
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                        }
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.chat_bubble_outline, color: kTextColorPrimary),
                        SizedBox(height: 4),
                        Text('Chat', style: TextStyle(color: kTextColorPrimary, fontSize: 12)),
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
              Text('Delivery time', style: TextStyle(color: kTextColorSecondary, fontSize: 12)),
              Text('20-30min', style: TextStyle(color: kTextColorPrimary, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: kGreenColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(isOpen ? 'Open Now' : 'Closed', style: const TextStyle(color: kGreenColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
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
          final qty = _cart[pid] ?? 0;
          return Container(
            decoration: BoxDecoration(color: kCardColor, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    'https://picsum.photos/seed/$pid/400/400',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: const TextStyle(color: kTextColorPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Rp${price.toInt()}', style: const TextStyle(color: kTextColorPrimary, fontWeight: FontWeight.w600)),
                    Row(children: [
                      _QtyButton(icon: Icons.remove, onTap: qty > 0 ? () => _removeFromCart(pid) : null),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                        child: Text('$qty', style: const TextStyle(color: kTextColorPrimary)),
                      ),
                      _QtyButton(icon: Icons.add, onTap: () => _addToCart(pid)),
                    ])
                  ])
                ]),
              )
            ]),
          );
        }, childCount: _products.length),
      ),
    );
  }

  Widget _buildCartBar() {
    if (_cart.isEmpty) return const SizedBox.shrink();
    final total = _cartTotal();
    final itemsCount = _cart.values.fold<int>(0, (p, e) => p + e);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1C1F26), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Expanded(child: Text('$itemsCount item(s) • Total Rp${total.toInt()}', style: const TextStyle(color: kTextColorPrimary, fontWeight: FontWeight.w600))),
        ElevatedButton(
          onPressed: _checkout,
          style: ElevatedButton.styleFrom(backgroundColor: kAccentColor, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
          child: const Text('Checkout'),
        ),
      ]),
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

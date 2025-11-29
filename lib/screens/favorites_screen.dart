import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/supabase_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int currentIndex = 2;
  final _svc = SupabaseService();
  List<Map<String, dynamic>> favorites = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _svc.fetchFavorites();
      setState(() { favorites = data; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  void _onBottomTap(int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/orders');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/chat');
        break;
    }
  }

  PreferredSizeWidget _topBar() => AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Favorites",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      );

  Future<void> _openProductPicker(String sellerId, String sellerName) async {
    List<Map<String, dynamic>> products = [];
    Map<int, int> qty = {}; // productId -> quantity
    num total = 0;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF14171D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctxLocal, setLocal) {
          Future<void> load() async {
            if (products.isNotEmpty) return;
            final data = await _svc.getProductsBySeller(sellerId);
            products = data;
            setLocal(() {});
          }
          load();

          void recalc() {
            total = 0;
            qty.forEach((pid, q) {
              final p = products.firstWhere((e) => e['id'] == pid);
              total += (p['price'] as num) * q;
            });
            setLocal(() {});
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Order from $sellerName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                if (products.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: products.length,
                      itemBuilder: (_, i) {
                        final p = products[i];
                        final pid = p['id'] as int;
                        final q = qty[pid] ?? 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1F26),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p['name']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('Rp ${(p['price'] as num).toInt()}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (q > 0) { qty[pid] = q - 1; recalc(); }
                                },
                                icon: const Icon(Icons.remove),
                              ),
                              Text('$q'),
                              IconButton(
                                onPressed: () { qty[pid] = q + 1; recalc(); },
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: qty.isEmpty
                        ? null
                        : () async {
                            try {
                              final order = await _svc.createOrder(
                                sellerId: sellerId,
                                totalPrice: total.toDouble(),
                                deliveryAddress: 'Kost',
                              );
                              final orderId = order['id'] as int;
                              for (final entry in qty.entries) {
                                final p = products.firstWhere((e) => e['id'] == entry.key);
                                await _svc.addOrderItem(
                                  orderId: orderId,
                                  productId: entry.key,
                                  quantity: entry.value,
                                  price: (p['price'] as num).toDouble(),
                                );
                              }
                              if (context.mounted) {
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed')));
                                Navigator.pushReplacementNamed(context, '/orders');
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                            }
                          },
                    child: Text('Checkout Rp ${total.toInt()}'),
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  Widget _favoriteCard(int index) {
    final row = favorites[index];
    final seller = row['sellers'] as Map<String, dynamic>?; // from fetchFavorites
    final sellerName = seller?['display_name']?.toString() ?? 'Seller';
    final isOnline = seller?['is_online'] as bool? ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Image and badges
          Stack(
            children: [
              Container(
                height: 150,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A2D35),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.storefront, size: 48, color: Colors.white54),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isOnline ? const Color(0xFF5F63D9) : Colors.grey,
            borderRadius: BorderRadius.circular(20)),
                  child: Text(isOnline ? 'Online' : 'Offline', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: const Color(0xFF5F63D9), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Closes in 45 min', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ],
          ),

          // Info row + order button + small edit icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(sellerName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.star, color: Colors.orange, size: 14),
                      const SizedBox(width: 6),
                      Text("4.8 • Indonesian", style: TextStyle(color: Colors.white.withOpacity(0.8))),
                    ]),
                    const SizedBox(height: 8),
                    Text('15 Orders', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  ]),
                ),

                // Quick add button (tap to add 1, long-press to open popup)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _openProductPicker(seller?['id']?.toString() ?? '', sellerName),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5F63D9),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Order'),
                    ),
                    const SizedBox(height: 6),
                    const Icon(Icons.edit, size: 18, color: Colors.white24),
                  ],
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
      backgroundColor: const Color(0xFF111418),
      appBar: _topBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: favorites.length,
                    itemBuilder: (_, i) => _favoriteCard(i),
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
}

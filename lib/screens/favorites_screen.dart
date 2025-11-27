import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int currentIndex = 2;

  final List<Map<String, dynamic>> favorites = [
    {
      "name": "Bakso Keputih",
      "rating": "4.8",
      "category": "Indonesian",
      "status": "Online",
      "orders": "15 Orders",
      "close": "Closes in 45 min",
      "price": 25000,
      "image": "assets/images/bakso.jpeg",
    },
    {
      "name": "Joder Steak",
      "rating": "4.4",
      "category": "Western",
      "status": "Offline",
      "orders": "8 Orders",
      "close": "Closed",
      "price": 34000,
      "image": "assets/images/bakso.jpeg",
    },
    {
      "name": "Mie Korea Hot",
      "rating": "4.9",
      "category": "Korean",
      "status": "Online",
      "orders": "22 Orders",
      "close": "Closes in 30 min",
      "price": 28000,
      "image": "assets/images/bakso.jpeg",
    },
  ];

  late List<bool> ordered;
  late List<int> qty;

  int totalPrice = 0;
  int keptItems = 0;

  @override
  void initState() {
    super.initState();
    ordered = List.generate(favorites.length, (_) => false);
    qty = List.generate(favorites.length, (_) => 0);
    _recalcTotals();
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
        // no chat route yet
        break;
    }
  }

  // ALWAYS recalc totals from qty to avoid incremental mismatch bugs
  void _recalcTotals() {
    int t = 0;
    int k = 0;
    for (int i = 0; i < favorites.length; i++) {
      t += (qty[i] * (favorites[i]['price'] as int));
      if (qty[i] > 0) k++;
      ordered[i] = qty[i] > 0;
    }
    setState(() {
      totalPrice = t;
      keptItems = k;
    });
  }

  // quick add: user taps Order button -> add 1 directly (keeps)
  void _quickAdd(int index) {
    qty[index] += 1;
    _recalcTotals();
  }

  // adjust qty by delta (positive or negative)
  void _changeQty(int index, int delta) {
    qty[index] = (qty[index] + delta).clamp(0, 999);
    _recalcTotals();
  }

  // remove entire item from cart
  void _removeItem(int index) {
    qty[index] = 0;
    _recalcTotals();
  }

  // Popup to set quantity / update / remove single item
  void _showItemPopup(int index) {
    final item = favorites[index];
    int localQty = qty[index];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF14171D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctxLocal, setLocal) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item['name'],
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (localQty > 0) setLocal(() => localQty--);
                      },
                      icon: const Icon(Icons.remove, color: Colors.white),
                    ),
                    Container(
                      width: 60,
                      alignment: Alignment.center,
                      child: Text(localQty.toString(),
                          style:
                              const TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                    IconButton(
                      onPressed: () => setLocal(() => localQty++),
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // compute diff and apply
                          final diff = localQty - qty[index];
                          if (diff > 0) {
                            _changeQty(index, diff);
                          } else if (diff < 0) {
                            _changeQty(index, diff); // delta negative OK
                          }
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5F63D9),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          qty[index] == 0 ? 'Add to Order' : 'Update Order',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (qty[index] > 0)
                      IconButton(
                        onPressed: () {
                          _removeItem(index);
                          Navigator.of(ctx).pop();
                        },
                        icon: const Icon(Icons.delete_forever,
                            color: Colors.redAccent),
                      )
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        });
      },
    );
  }

  // Cart popup (draggable, shows items, supports delete & qty +/-)
  void _showCartPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF14171D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return StatefulBuilder(builder: (contextLocal, setLocal) {
              // build list of indices currently in cart
              final cartIndexes = <int>[];
              for (int i = 0; i < favorites.length; i++) {
                if (qty[i] > 0) cartIndexes.add(i);
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text("Your Cart",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: cartIndexes.isEmpty
                          ? const Center(
                              child: Text("No items in cart",
                                  style: TextStyle(color: Colors.white70)))
                          : ListView.builder(
                              controller: controller,
                              itemCount: cartIndexes.length,
                              itemBuilder: (_, idx) {
                                final i = cartIndexes[idx];
                                final it = favorites[i];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1C1F26),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          it['image'],
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(width:56, height:56, color: Colors.grey),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(it['name'],
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                            const SizedBox(height: 6),
                                            Text("Rp ${it['price']}",
                                                style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      // qty controls
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove, color: Colors.white),
                                            onPressed: () {
                                              if (qty[i] > 0) {
                                                _changeQty(i, -1);
                                                setLocal(() {});
                                              }
                                            },
                                          ),
                                          Text('${qty[i]}',
                                              style: const TextStyle(color: Colors.white)),
                                          IconButton(
                                            icon: const Icon(Icons.add, color: Colors.white),
                                            onPressed: () {
                                              _changeQty(i, 1);
                                              setLocal(() {});
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                                            onPressed: () {
                                              _removeItem(i);
                                              setLocal(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${keptItems} item(s)",
                            style: const TextStyle(color: Colors.white70)),
                        Text("Rp $totalPrice",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: cartIndexes.isEmpty
                            ? null
                            : () {
                                Navigator.of(context).pop();
                                // mock place order
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Order placed (mock)')),
                                );
                                // reset
                                setState(() {
                                  for (int j = 0; j < qty.length; j++) {
                                    qty[j] = 0;
                                    ordered[j] = false;
                                  }
                                  _recalcTotals();
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5F63D9),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Checkout Rp $totalPrice',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        );
      },
    );
  }

  PreferredSizeWidget _topBar() => AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Favorites",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      );

  Widget _favoriteCard(int index) {
    final item = favorites[index];
    final isOrdered = ordered[index];

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
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Image.asset(
                  item["image"],
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height:150, color: Colors.grey),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: item['status'] == 'Online' ? const Color(0xFF5F63D9) : Colors.grey,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(item['status'], style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: const Color(0xFF5F63D9), borderRadius: BorderRadius.circular(20)),
                  child: Text(item['close'], style: const TextStyle(color: Colors.white, fontSize: 12)),
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
                    Text(item['name'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.star, color: Colors.orange, size: 14),
                      const SizedBox(width: 6),
                      Text("${item['rating']} • ${item['category']}", style: TextStyle(color: Colors.white.withOpacity(0.8))),
                    ]),
                    const SizedBox(height: 8),
                    Text(item['orders'], style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  ]),
                ),

                // Quick add button (tap to add 1, long-press to open popup)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _quickAdd(index),
                      onLongPress: () => _showItemPopup(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOrdered ? const Color(0xFF5F63D9) : Colors.white,
                        foregroundColor: isOrdered ? Colors.white : Colors.black,
                        minimumSize: const Size(80, 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(isOrdered ? 'Kept' : 'Order'),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _showItemPopup(index),
                      child: const Icon(Icons.edit, size: 18, color: Colors.white70),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111418),
      appBar: _topBar(),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: favorites.length,
        itemBuilder: (_, i) => _favoriteCard(i),
      ),
      bottomSheet: keptItems > 0
          ? GestureDetector(
              onTap: _showCartPopup,
              child: Container(
                width: double.infinity,
                color: const Color(0xFF5F63D9),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                child: Text(
                  "$keptItems item(s) • Rp $totalPrice — View Order",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
            )
          : null,
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

import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order; // original map from list
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _svc = SupabaseService();
  bool _loadingItems = true;
  List<Map<String, dynamic>> _items = [];
  String? _error;
  bool _sending = false;
  final _msgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() { _loadingItems = true; _error = null; });
    try {
      final id = widget.order['id'] as int;
      final data = await _svc.fetchOrderItems(id);
      setState(() { _items = data; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loadingItems = false; });
    }
  }

  Future<void> _sendMessage() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() { _sending = true; });
    try {
      final sellerId = widget.order['seller_id']?.toString();
      if (sellerId == null) throw Exception('Seller unknown');
      final conv = await _svc.ensureConversationWithSeller(sellerId);
      await _svc.sendMessage(
        recipientId: sellerId,
        content: _msgCtrl.text.trim(),
        conversationId: conv['id'].toString(),
        orderId: widget.order['id'] as int,
      );
      _msgCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      setState(() { _sending = false; });
    }
  }

  PreferredSizeWidget _topBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.chevron_left),
      ),
      centerTitle: true,
      title: const Text('Order Status'),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.notifications_none),
        )
      ],
    );
  }

  Widget _profileCard() {
    final seller = widget.order['sellers'] as Map<String,dynamic>?;
    final sellerName = seller?['display_name']?.toString() ?? 'Seller';
    final status = widget.order['status']?.toString() ?? 'pending';
    final address = widget.order['delivery_address']?.toString();
    final timeWindow = widget.order['delivery_time']?.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const CircleAvatar(radius: 42, backgroundImage: AssetImage('assets/images/seller1.jpg')),
          const SizedBox(height: 12),
          Text(sellerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  try {
                    final sellerId = widget.order['seller_id']?.toString();
                    if (sellerId == null) return;
                    final conv = await _svc.ensureConversationWithSeller(sellerId);
                    if (!mounted) return;
                    Navigator.pushNamed(context, '/chat-conversation', arguments: {
                      'conversation_id': conv['id'].toString(),
                      'seller_id': sellerId,
                      'order_id': widget.order['id'] as int,
                    });
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                    }
                  }
                },
                child: Column(
                  children: const [
                    Icon(Icons.chat_bubble_outline),
                    SizedBox(height: 6),
                    Text('Chat', style: TextStyle(fontSize: 12))
                  ],
                ),
              ),
              const SizedBox(width: 36),
              Column(
                children: const [
                  Icon(Icons.receipt_long_outlined),
                  SizedBox(height: 6),
                  Text('Order Details', style: TextStyle(fontSize: 12))
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF5F63D9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 18),
          if (address != null || timeWindow != null)
            Column(
              children: [
                if (timeWindow != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.access_time, size: 16),
                      SizedBox(width: 6),
                      // Text below filled with value after Row
                    ],
                  ),
                if (timeWindow != null)
                  Text(timeWindow, style: const TextStyle(fontSize: 12)),
                if (address != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.place, size: 16),
                      SizedBox(width: 6),
                    ],
                  ),
                  Text(address, style: const TextStyle(fontSize: 12)),
                ]
              ],
            ),
          const SizedBox(height: 8),
          _timeline(),
          const SizedBox(height: 10),
          _messageComposer(),
        ],
      ),
    );
  }

  Widget _timeline() {
    // Two items as in the mock
    final items = [
      {
        'time': '07.30 - Order placed',
        'desc': 'Pesanamu sudah diterima sistem',
      },
      {
        'time': '07.30 - Heading to restoran',
        'desc': 'Alan walker menuju restoran',
      },
    ];

    return Column(
      children: [
        for (int i = 0; i < items.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // timeline bar
              SizedBox(
                width: 30,
                child: Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                    if (i != items.length - 1)
                      Container(width: 2, height: 44, color: Colors.white24),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3F4856),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(items[i]['time']!, style: const TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(height: 6),
                      Text(items[i]['desc']!, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _itemsList() {
    if (_loadingItems) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Text('Error: $_error');
    if (_items.isEmpty) return const Text('No items');
    return Column(
      children: _items.map((it){
        final product = it['product'] as Map<String,dynamic>?;
        final name = product?['name']?.toString() ?? 'Item';
        final qty = it['quantity'] ?? 1;
        final price = (it['price'] as num?)?.toDouble() ?? 0;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('$qty x $name'),
          trailing: Text('Rp${price.toInt()}'),
        );
      }).toList(),
    );
  }

  double _computedTotal() {
    double sum = 0;
    for (final it in _items) {
      final p = (it['price'] as num?)?.toDouble() ?? 0;
      final q = (it['quantity'] as num?)?.toInt() ?? 1;
      sum += p * q;
    }
    return sum;
  }

  Widget _messageComposer() {
    final status = widget.order['status']?.toString() ?? 'pending';
    final canCancel = status == 'pending' || status == 'confirmed';
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(children:[
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              decoration: const InputDecoration(
                hintText: 'Ketik pesan ke seller...',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width:8),
          ElevatedButton(
            onPressed: _sending? null : _sendMessage,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5F63D9)),
            child: _sending? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)) : const Icon(Icons.send),
          ),
        ]),
        if (canCancel) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cancel Order?'),
                    content: const Text('Are you sure you want to cancel this order?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    await _svc.updateOrderStatus(orderId: widget.order['id'] as int, status: 'cancelled');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order cancelled')));
                      Navigator.pop(context); // Kembali ke Orders screen
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to cancel: $e')));
                    }
                  }
                }
              },
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text('Cancel Order', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _topBar(context),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileCard(),
              const SizedBox(height:24),
              const Text('Items', style: TextStyle(fontSize:16,fontWeight: FontWeight.w600)),
              const SizedBox(height:8),
              _itemsList(),
              const SizedBox(height:12),
              if(!_loadingItems && _error==null) Text('Total: Rp${_computedTotal().toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height:40),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderDetailScreen({super.key, required this.order});

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(radius: 42, backgroundImage: AssetImage(order['avatar'] as String)),
          const SizedBox(height: 12),
          Text('Jastip ${order['name']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: const [
                  Icon(Icons.chat_bubble_outline),
                  SizedBox(height: 6),
                  Text('Chat', style: TextStyle(fontSize: 12))
                ],
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
            child: const Text('Estimasi: 30 menit', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 18),
          _timeline(),
          const SizedBox(height: 10),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _topBar(context),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _profileCard(),
            ],
          ),
        ),
      ),
    );
  }
}

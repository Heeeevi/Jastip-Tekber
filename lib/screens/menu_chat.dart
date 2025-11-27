import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORTS HALAMAN LAIN ---
import 'home_screen.dart';       // Untuk balik ke Home
import 'orders_screen.dart';     // Untuk ke Orders
import 'favorites_screen.dart';  // Untuk ke Favorites
import 'chat.dart'; // Pastikan file ini ada (code yang sebelumnya saya kasih)

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Set default index ke 3 (Chat Tab)
  int currentIndex = 3;

  // Data dummy chat list
  final chatList = [
    {
      'name': 'Alan Walker',
      'message': 'Udah sampai mana Broo...',
      'time': '10.00',
      'avatarColor': Colors.pinkAccent,
      'unread': 0,
      'isSent': true,
    },
    {
      'name': 'Alex',
      'message': 'Udah saya taruh depan pintu',
      'time': '10.00',
      'avatarColor': Colors.grey,
      'unread': 1,
      'isSent': false,
    },
  ];

  // --- LOGIKA BOTTOM NAVIGATION BAR ---
  BottomNavigationBar _bottomNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        switch (i) {
          case 0:
            // Pindah ke HOME
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const HomeScreen(),
                transitionDuration: Duration.zero,
              ),
            );
            break;
          case 1:
            // Pindah ke ORDERS
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const OrdersScreen(),
                transitionDuration: Duration.zero,
              ),
            );
            break;
          case 2:
            // Pindah ke FAVORITES
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const FavoritesScreen(),
                transitionDuration: Duration.zero,
              ),
            );
            break;
          case 3:
            // Sudah di Chat, tidak perlu aksi apa-apa
            break;
        }
        setState(() => currentIndex = i);
      },
      backgroundColor: const Color(0xFF14171D),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF5F63D9),
      unselectedItemColor: Colors.white60,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorites'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
      ],
    );
  }

  // --- WIDGET ITEM CHAT (BISA DIKLIK) ---
  Widget _buildChatItem(BuildContext context, Map<String, dynamic> chat) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke DetailChatScreen saat item diklik
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailChatScreen(
              userName: chat['name'], // Mengirim nama ke halaman detail
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1F26),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: chat['avatarColor'],
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 16),
            
            // Nama dan Pesan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (chat['isSent'] == true)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(Icons.done_all, size: 16, color: Colors.grey),
                        ),
                      Expanded(
                        child: Text(
                          chat['message'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Waktu dan Badge Unread
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat['time'],
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                if ((chat['unread'] as int) > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      chat['unread'].toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14171D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14171D),
        elevation: 0,
        // Tombol Back di AppBar yang mengarah ke Home (Manual Sync)
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF1C1F26),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white70),
          ),
          onPressed: () {
             Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const HomeScreen(),
                transitionDuration: Duration.zero,
              ),
            );
          },
        ),
        title: Text('JasTip', style: GoogleFonts.inter(color: Colors.white, fontSize: 18)),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1C1F26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_none, size: 20, color: Colors.white),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Text('2', style: TextStyle(fontSize: 10, color: Colors.white)),
                ),
              )
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: chatList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final chat = chatList[index];
          // Panggil fungsi widget item dan berikan context
          return _buildChatItem(context, chat);
        },
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }
}
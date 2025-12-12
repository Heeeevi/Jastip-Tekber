import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_2/services/supabase_service.dart';

// --- IMPORTS HALAMAN LAIN ---
// Hapus import langsung ke screen lain untuk menghindari circular imports
// Navigasi gunakan named routes agar lebih aman
// chat.dart (mock) no longer used; real screen uses /chat-conversation

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Set default index ke 3 (Chat Tab)
  int currentIndex = 3;
  final _svc = SupabaseService();
  List<Map<String, dynamic>> _conversations = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _svc.fetchConversations();
      setState(() {
        _conversations = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // --- LOGIKA BOTTOM NAVIGATION BAR ---
  BottomNavigationBar _bottomNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        switch (i) {
          case 0:
            // Pindah ke HOME
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            // Pindah ke ORDERS
            Navigator.pushReplacementNamed(context, '/orders');
            break;
          case 2:
            // Pindah ke FAVORITES
            Navigator.pushReplacementNamed(context, '/favorites');
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
    final p1 = chat['participant_1'] as Map<String, dynamic>?;
    final p2 = chat['participant_2'] as Map<String, dynamic>?;
    final currentUserId = _svc.getCurrentUser()?.id;
    final other = (chat['participant_1_id'] == currentUserId) ? p2 : p1;
    final otherId = (chat['participant_1_id'] == currentUserId) 
        ? chat['participant_2_id']?.toString() 
        : chat['participant_1_id']?.toString();
    final otherName = other != null ? (other['full_name'] as String? ?? 'User') : 'User';
    final lastMessage = chat['last_message']?.toString() ?? '';
    final time = (chat['last_message_at']?.toString() ?? '').split('T').first;
    return GestureDetector(
      onTap: () {
        // Buka percakapan nyata dengan conversation_id DAN recipient_id
        Navigator.pushNamed(
          context,
          '/chat-conversation',
          arguments: {
            'conversation_id': chat['id'].toString(),
            'recipient_id': otherId, // FIXED: Pass the other participant ID
          },
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
              backgroundColor: Colors.blueGrey,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 16),
            
            // Nama dan Pesan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
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
                  time,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
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
             Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        title: Text('JasTip', style: GoogleFonts.inter(color: Colors.white, fontSize: 18)),
        centerTitle: true,
        actions: [
          // --- BAGIAN INI DIPERBARUI (MERAH-MERAH DIHAPUS) ---
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
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _conversations.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final chat = _conversations[index];
                      return _buildChatItem(context, chat);
                    },
                  ),
                ),
      bottomNavigationBar: _bottomNav(),
    );
  }
}
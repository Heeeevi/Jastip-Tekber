import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailChatScreen extends StatefulWidget {
  final String userName;

  const DetailChatScreen({super.key, required this.userName});

  @override
  State<DetailChatScreen> createState() => _DetailChatScreenState();
}

class _DetailChatScreenState extends State<DetailChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [
    {
      'message': 'Siap dikirim',
      'isMe': false,
      'time': '09.41',
    },
    {
      'message': 'Udah sampai mana broo...',
      'isMe': true,
      'time': '09.42',
    },
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        'message': _controller.text,
        'isMe': true,
        'time': 'Now',
      });
    });

    String lastMsg = _controller.text; 
    _controller.clear();
    _scrollToBottom();

    // Simulasi balasan otomatis
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          messages.add({
            'message': 'Oke siap, $lastMsg ditunggu ya!',
            'isMe': false,
            'time': 'Now',
          });
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14171D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14171D),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF1C1F26),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white70),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.userName,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // LIST CHAT
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['isMe'] as bool;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3E3E3),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg['message'],
                          style: const TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                        if (isMe)
                           const Padding(
                             padding: EdgeInsets.only(top: 4),
                             child: Icon(Icons.done_all, size: 14, color: Colors.grey),
                           ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // INPUT FIELD AREA (REVISI: Tombol Send Muncul Lagi)
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF14171D),
            child: Row(
              children: [
                // Kolom Ketik (Kapsul Abu-abu)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3E3E3), // Warna abu-abu terang
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file, color: Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: 'Type something',
                              hintStyle: TextStyle(color: Colors.black45),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Tombol Kirim (Lingkaran Ungu)
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF5F63D9), // Warna Ungu
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
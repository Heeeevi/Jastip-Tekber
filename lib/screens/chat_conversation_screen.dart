import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({super.key});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final _svc = SupabaseService();
  final _msgCtrl = TextEditingController();
  int? _conversationId;
  String? _sellerId;
  int? _orderId;
  List<Map<String, dynamic>> _messages = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _conversationId = int.tryParse(args?['conversation_id']?.toString() ?? '');
    _sellerId = args?['seller_id']?.toString();
    _orderId = args?['order_id'] as int?;
    _load();
  }

  Future<void> _load() async {
    if (_conversationId == null) return;
    final data = await _svc.fetchMessages(_conversationId!);
    if (mounted) setState(() => _messages = data);
    // Optionally, listen to realtime
    _svc.messagesStream(_conversationId!).listen((data) {
      if (mounted) setState(() => _messages = data);
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    // If conversation id unknown but we have seller id, ensure conversation first
    String? convId = _conversationId?.toString();
    if (convId == null || convId.isEmpty) {
      if (_sellerId == null) return;
      final conv = await _svc.ensureConversationWithSeller(_sellerId!);
      convId = conv['id'].toString();
      setState(() { _conversationId = int.tryParse(convId!); });
    }
    await _svc.sendMessage(
      recipientId: _sellerId ?? '',
      content: text,
      conversationId: convId,
      orderId: _orderId,
    );
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conversation')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final me = m['sender_id'] == _svc.getCurrentUser()?.id;
                return Align(
                  alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: me ? const Color(0xFF5F63D9) : const Color(0xFF1C1F26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (m['order_id'] != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text('Order #${m['order_id']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ),
                        Text(m['content']?.toString() ?? '', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        filled: true,
                      ),
                    ),
                  ),
                ),
                IconButton(onPressed: _send, icon: const Icon(Icons.send)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

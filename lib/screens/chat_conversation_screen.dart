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
  String? _recipientId; // Can be seller_id or any participant
  int? _orderId;
  List<Map<String, dynamic>> _messages = [];
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _conversationId = int.tryParse(args?['conversation_id']?.toString() ?? '');
    // Support both 'seller_id' and 'recipient_id' for flexibility
    _recipientId = args?['seller_id']?.toString() ?? args?['recipient_id']?.toString();
    _orderId = int.tryParse(args?['order_id']?.toString() ?? '');
    
    print('[ChatConversation] Args: $args');
    print('[ChatConversation] ConversationId: $_conversationId, RecipientId: $_recipientId');
    
    _load();
  }

  Future<void> _load() async {
    if (_conversationId == null) {
      print('[ChatConversation] No conversation_id, cannot load messages');
      return;
    }
    final data = await _svc.fetchMessages(_conversationId!);
    if (mounted) setState(() => _messages = data);
    
    // If we don't have recipient_id yet, try to get it from conversation
    if (_recipientId == null && _messages.isNotEmpty) {
      final currentUserId = _svc.getCurrentUser()?.id;
      // Find the other person from messages
      for (final m in _messages) {
        if (m['sender_id'] != currentUserId) {
          _recipientId = m['sender_id']?.toString();
          print('[ChatConversation] Found recipient from messages: $_recipientId');
          break;
        }
        if (m['recipient_id'] != currentUserId) {
          _recipientId = m['recipient_id']?.toString();
          print('[ChatConversation] Found recipient from messages: $_recipientId');
          break;
        }
      }
    }
    
    // Listen to realtime updates
    _svc.messagesStream(_conversationId!).listen((data) {
      if (mounted) setState(() => _messages = data);
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) {
      print('[ChatConversation] Empty message, not sending');
      return;
    }
    
    if (_recipientId == null || _recipientId!.isEmpty) {
      print('[ChatConversation] ERROR: No recipient_id, cannot send message');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot send message: recipient unknown')),
      );
      return;
    }
    
    setState(() => _loading = true);
    
    try {
      // If conversation id unknown, ensure conversation first
      String? convId = _conversationId?.toString();
      if (convId == null || convId.isEmpty) {
        print('[ChatConversation] Creating new conversation with: $_recipientId');
        final conv = await _svc.ensureConversationWithSeller(_recipientId!);
        convId = conv['id'].toString();
        setState(() { _conversationId = int.tryParse(convId!); });
      }
      
      print('[ChatConversation] Sending message to $_recipientId in conversation $convId');
      
      await _svc.sendMessage(
        recipientId: _recipientId!,
        content: text,
        conversationId: convId,
        orderId: _orderId,
      );
      
      _msgCtrl.clear();
      print('[ChatConversation] Message sent successfully');
      
      // Reload messages
      await _load();
    } catch (e) {
      print('[ChatConversation] ERROR sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                      style: const TextStyle(color: Colors.black), // Text color black
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: TextStyle(color: Colors.black54),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onSubmitted: (_) => _send(), // Allow send on Enter key
                    ),
                  ),
                ),
                _loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(onPressed: _send, icon: const Icon(Icons.send)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

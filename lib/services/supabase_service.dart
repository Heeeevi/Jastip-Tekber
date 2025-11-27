import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // ==================== AUTH ====================
  
  /// Sign up new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  /// Sign in user
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out user
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Get current user
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return supabase.auth.currentUser != null;
  }

  // ==================== USERS ====================
  
  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final data = await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return data;
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? block,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (block != null) updates['block'] = block;

    await supabase.from('users').update(updates).eq('id', userId);
  }

  // ==================== SELLERS ====================
  
  /// Fetch all sellers (untuk Popular Sellers)
  Future<List<Map<String, dynamic>>> fetchSellers({
    int limit = 10,
    bool? isOnline,
  }) async {
    var query = supabase
        .from('sellers')
        .select('''
          *,
          profiles!inner(full_name, avatar_url, dom_block)
        ''');

    if (isOnline != null) {
      query = query.eq('is_online', isOnline);
    }

    final data = await query.order('total_orders', ascending: false).limit(limit);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Get seller by ID
  Future<Map<String, dynamic>?> getSellerById(String sellerId) async {
    final data = await supabase
        .from('sellers')
        .select()
        .eq('id', sellerId)
        .maybeSingle();
    return data;
  }

  /// Create seller profile
  Future<Map<String, dynamic>> createSellerProfile({
    required String userId,
    required String displayName,
    required String block,
    String? description,
    String? deliveryTime,
  }) async {
    final data = await supabase.from('sellers').insert({
      'id': userId, // sellers.id references profiles.id
      'display_name': displayName,
      'block': block,
      'description': description,
      'delivery_time': deliveryTime,
      'is_online': true,
      'rating': 0.0,
      'total_orders': 0,
    }).select().single();

    return data;
  }

  /// Update seller profile
  Future<void> updateSellerProfile({
    required String sellerId,
    String? displayName,
    String? block,
    String? description,
    String? deliveryTime,
    bool? isOnline,
  }) async {
    final updates = <String, dynamic>{};

    if (displayName != null) updates['display_name'] = displayName;
    if (block != null) updates['block'] = block;
    if (description != null) updates['description'] = description;
    if (deliveryTime != null) updates['delivery_time'] = deliveryTime;
    if (isOnline != null) updates['is_online'] = isOnline;

    await supabase.from('sellers').update(updates).eq('id', sellerId);
  }

  /// Stream sellers untuk real-time updates
  Stream<List<Map<String, dynamic>>> sellersStream() {
    return supabase
        .from('sellers')
        .stream(primaryKey: ['id'])
        .order('total_orders', ascending: false);
  }

  // ==================== ORDERS ====================
  
  /// Fetch active orders (untuk Active Purchase Orders)
  Future<List<Map<String, dynamic>>> fetchActiveOrders() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await supabase
        .from('orders')
        .select('''
          *,
          sellers(display_name, rating, block),
          profiles!orders_seller_id_fkey(avatar_url)
        ''')
        .eq('buyer_id', userId)
        .inFilter('status', ['pending', 'confirmed', 'preparing', 'ready'])
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Count active orders untuk badge
  Future<int> countActiveOrders() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final data = await supabase
        .from('orders')
        .select()
        .eq('buyer_id', userId)
        .inFilter('status', ['pending', 'confirmed', 'preparing', 'ready']);

    return data.length;
  }

  /// Create new order
  Future<Map<String, dynamic>> createOrder({
    required String sellerId,
    required double totalPrice,
    double? deliveryFee,
    String? deliveryAddress,
    String? notes,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final data = await supabase.from('orders').insert({
      'buyer_id': userId,
      'seller_id': sellerId,
      'total_price': totalPrice,
      'delivery_fee': deliveryFee ?? 0,
      'status': 'pending',
      'delivery_address': deliveryAddress,
      'notes': notes,
    }).select().single();

    return data;
  }

  // ==================== FAVORITES ====================
  
  /// Check if seller is favorited
  Future<bool> isFavorited(String sellerId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final data = await supabase
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('seller_id', sellerId)
        .maybeSingle();

    return data != null;
  }

  /// Toggle favorite
  Future<void> toggleFavorite(String sellerId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final isFav = await isFavorited(sellerId);

    if (isFav) {
      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('seller_id', sellerId);
    } else {
      await supabase.from('favorites').insert({
        'user_id': userId,
        'seller_id': sellerId,
      });
    }
  }

  /// Fetch favorite sellers
  Future<List<Map<String, dynamic>>> fetchFavorites() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await supabase
        .from('favorites')
        .select('*, sellers(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  // ==================== NOTIFICATIONS ====================
  
  /// Fetch unread notifications
  Future<List<Map<String, dynamic>>> fetchUnreadNotifications() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .eq('is_read', false)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Count unread notifications untuk badge
  Future<int> countUnreadNotifications() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final data = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .eq('is_read', false);

    return data.length;
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await supabase.from('notifications').update({
      'is_read': true,
    }).eq('id', notificationId);
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from('notifications').update({
      'is_read': true,
    }).eq('user_id', userId).eq('is_read', false);
  }

  // ==================== PRODUCTS ====================
  
  /// Get products by seller
  Future<List<Map<String, dynamic>>> getProductsBySeller(String sellerId) async {
    final data = await supabase
        .from('products')
        .select()
        .eq('seller_id', sellerId)
        .eq('is_available', true)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Create product
  Future<Map<String, dynamic>> createProduct({
    required String sellerId,
    required String name,
    required double price,
    String? description,
    String? category,
    String? imageUrl,
    String? keywords,
  }) async {
    final data = await supabase.from('products').insert({
      'seller_id': sellerId,
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'image_url': imageUrl,
      'keywords': keywords,
      'is_available': true,
      'status': 'active',
    }).select().single();

    return data;
  }

  /// Update product
  Future<void> updateProduct({
    required int productId,
    String? name,
    double? price,
    String? description,
    String? category,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    final updates = <String, dynamic>{};

    if (name != null) updates['name'] = name;
    if (price != null) updates['price'] = price;
    if (description != null) updates['description'] = description;
    if (category != null) updates['category'] = category;
    if (imageUrl != null) updates['image_url'] = imageUrl;
    if (isAvailable != null) updates['is_available'] = isAvailable;

    await supabase.from('products').update(updates).eq('id', productId);
  }

  /// Delete product
  Future<void> deleteProduct(int productId) async {
    await supabase.from('products').delete().eq('id', productId);
  }

  // ==================== CHAT / MESSAGES ====================
  
  /// Send a message
  Future<Map<String, dynamic>> sendMessage({
    required String recipientId,
    required String content,
    String? conversationId,
    String? messageType,
    int? orderId,
    String? imageUrl,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    // If no conversation ID provided, find or create conversation
    String finalConversationId = conversationId ?? '';
    if (finalConversationId.isEmpty) {
      final existingConv = await _findConversation(userId, recipientId);
      if (existingConv != null) {
        finalConversationId = existingConv['id'].toString();
      } else {
        final newConv = await _createConversation(userId, recipientId);
        finalConversationId = newConv['id'].toString();
      }
    }

    final data = await supabase.from('messages').insert({
      'sender_id': userId,
      'recipient_id': recipientId,
      'content': content,
      'conversation_id': int.parse(finalConversationId),
      'message_type': messageType ?? 'text',
      'order_id': orderId,
      'image_url': imageUrl,
      'is_read': false,
    }).select().single();

    // Update conversation last_message
    await supabase.from('conversations').update({
      'last_message': content,
      'last_message_at': DateTime.now().toIso8601String(),
    }).eq('id', int.parse(finalConversationId));

    return data;
  }

  /// Find existing conversation between two users
  Future<Map<String, dynamic>?> _findConversation(String userId1, String userId2) async {
    final data = await supabase
        .from('conversations')
        .select()
        .or('and(participant_1_id.eq.$userId1,participant_2_id.eq.$userId2),and(participant_1_id.eq.$userId2,participant_2_id.eq.$userId1)')
        .maybeSingle();
    return data;
  }

  /// Create new conversation
  Future<Map<String, dynamic>> _createConversation(String userId1, String userId2) async {
    final data = await supabase.from('conversations').insert({
      'participant_1_id': userId1,
      'participant_2_id': userId2,
    }).select().single();
    return data;
  }

  /// Fetch messages for a conversation
  Future<List<Map<String, dynamic>>> fetchMessages(int conversationId) async {
    final data = await supabase
        .from('messages')
        .select('''
          *,
          sender:profiles!messages_sender_id_fkey(full_name, avatar_url),
          recipient:profiles!messages_recipient_id_fkey(full_name, avatar_url)
        ''')
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Fetch user conversations
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await supabase
        .from('conversations')
        .select('''
          *,
          participant_1:profiles!conversations_participant_1_id_fkey(full_name, avatar_url),
          participant_2:profiles!conversations_participant_2_id_fkey(full_name, avatar_url)
        ''')
        .or('participant_1_id.eq.$userId,participant_2_id.eq.$userId')
        .order('last_message_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Stream messages for real-time chat
  Stream<List<Map<String, dynamic>>> messagesStream(int conversationId) {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(int conversationId, String userId) async {
    await supabase
        .from('messages')
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .eq('recipient_id', userId)
        .eq('is_read', false);
  }

  /// Set typing indicator
  Future<void> setTypingIndicator({
    required int conversationId,
    required bool isTyping,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    if (isTyping) {
      await supabase.from('typing_indicators').upsert({
        'conversation_id': conversationId,
        'user_id': userId,
        'is_typing': true,
      });
    } else {
      await supabase
          .from('typing_indicators')
          .delete()
          .eq('conversation_id', conversationId)
          .eq('user_id', userId);
    }
  }

  /// Stream typing indicators
  Stream<List<Map<String, dynamic>>> typingIndicatorsStream(int conversationId) {
    return supabase
        .from('typing_indicators')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId);
  }
}

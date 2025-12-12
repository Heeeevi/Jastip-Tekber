import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // ==================== AUTH ====================

  /// Sign up new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? domBlock,
    String? roomNumber,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
        'dom_block': domBlock,
        'room_number': roomNumber,
      },
    );

    // Profile akan otomatis dibuat oleh trigger handle_new_user di Supabase
    // Tidak perlu manual insert karena sudah ada trigger

    return response;
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
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return data;
  }

  /// Update user profile (Buyer)
  /// Updated to match ProfilePage inputs
  Future<void> updateUserProfile({
    required String userId,
    String? displayName, // Dari form dikirim sebagai displayName
    String? bio,
    String? phone,
    String? block, // Dari form dikirim sebagai block
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    // MAPPING KE KOLOM DATABASE:
    if (displayName != null)
      updates['full_name'] = displayName; // Masuk ke full_name
    if (phone != null) updates['phone'] = phone;
    if (bio != null) updates['bio'] = bio;
    if (block != null) updates['dom_block'] = block; // Masuk ke dom_block

    await supabase.from('profiles').update(updates).eq('id', userId);
  }

  // ==================== SELLERS ====================

  /// Fetch all sellers (untuk Popular Sellers)
  Future<List<Map<String, dynamic>>> fetchSellers({
    int limit = 10,
    bool? isOnline,
  }) async {
    var query = supabase.from('sellers').select('''
          *,
          profiles!inner(full_name, avatar_url, dom_block)
        ''');

    if (isOnline != null) {
      query = query.eq('is_online', isOnline);
    }

    final data = await query
        .order('total_orders', ascending: false)
        .limit(limit);
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
    double? deliveryFee,
    double? rating,
  }) async {
    final data = await supabase
        .from('sellers')
        .insert({
          'id': userId, // sellers.id references profiles.id
          'display_name': displayName,
          'block': block,
          'description': description,
          'delivery_time': deliveryTime,
          'is_online': true,
          'delivery_fee': deliveryFee ?? 0.0,
          'rating': rating ?? 0.0,
          'total_orders': 0,
        })
        .select()
        .single();

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
    double? deliveryFee,
    double? rating,
  }) async {
    final updates = <String, dynamic>{};

    if (displayName != null) updates['display_name'] = displayName;
    if (block != null) updates['block'] = block;
    if (description != null) updates['description'] = description;
    if (deliveryTime != null) updates['delivery_time'] = deliveryTime;
    if (isOnline != null) updates['is_online'] = isOnline;
    if (deliveryFee != null) updates['delivery_fee'] = deliveryFee;
    if (rating != null) updates['rating'] = rating;

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
          sellers(display_name, rating, block)
        ''')
        .eq('buyer_id', userId)
        .inFilter('status', ['pending', 'confirmed', 'preparing', 'ready'])
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Fetch orders for the current seller filtered by statuses
  Future<List<Map<String, dynamic>>> fetchSellerOrders({
    List<String>? statuses,
  }) async {
    final sellerId = supabase.auth.currentUser?.id;
    if (sellerId == null) return [];
    var builder = supabase
        .from('orders')
        .select('''
        *,
        buyer:profiles!orders_buyer_id_fkey(full_name, dom_block, room_number)
      ''')
        .eq('seller_id', sellerId);
    if (statuses != null && statuses.isNotEmpty) {
      builder = builder.inFilter('status', statuses);
    }
    final data = await builder.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Fetch items for an order (join products)
  Future<List<Map<String, dynamic>>> fetchOrderItems(int orderId) async {
    final data = await supabase
        .from('order_items')
        .select('''
          *,
          product:products(id,name,price,category,image_url)
        ''')
        .eq('order_id', orderId)
        .order('id');
    return List<Map<String, dynamic>>.from(data);
  }

  /// Ensure conversation exists between current user and seller (returns conversation map)
  Future<Map<String, dynamic>> ensureConversationWithSeller(
    String sellerId,
  ) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in');
    // Find existing
    final existing = await supabase
        .from('conversations')
        .select()
        .or(
          'and(participant_1_id.eq.$userId,participant_2_id.eq.$sellerId),and(participant_1_id.eq.$sellerId,participant_2_id.eq.$userId)',
        )
        .maybeSingle();
    if (existing != null) return existing;
    // Create new
    final created = await supabase
        .from('conversations')
        .insert({'participant_1_id': userId, 'participant_2_id': sellerId})
        .select()
        .single();
    return created;
  }

  /// Update order status (seller side)
  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    await supabase.from('orders').update({'status': status}).eq('id', orderId);
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
    String? deliveryAddress,
    String? deliveryTime,
    String? notes,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    Map<String, dynamic> payload = {
      'buyer_id': userId,
      'seller_id': sellerId,
      'total_price': totalPrice,
      'status': 'pending',
      'notes': notes,
    };
    if (deliveryAddress != null) payload['delivery_address'] = deliveryAddress;
    if (deliveryTime != null) payload['delivery_time'] = deliveryTime;

    dynamic data;
    try {
      data = await supabase.from('orders').insert(payload).select().single();
    } catch (e) {
      // Fallback: if server schema doesn't have delivery_time/address yet, retry without them
      final msg = e.toString();
      final maybeSchemaCache =
          msg.contains("Could not find the 'delivery_time' column") ||
          msg.contains('schema cache');
      if (maybeSchemaCache) {
        payload.remove('delivery_time');
        payload.remove('delivery_address');
        data = await supabase.from('orders').insert(payload).select().single();
      } else {
        rethrow;
      }
    }

    return data;
  }

  /// Fetch current user's active orders filtered by a seller
  Future<List<Map<String, dynamic>>> fetchActiveOrdersBySeller(
    String sellerId,
  ) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];
    final data = await supabase
        .from('orders')
        .select('''
          *,
          sellers(display_name, rating, block),
          order_items(*, product:products(id,name,price))
        ''')
        .eq('buyer_id', userId)
        .eq('seller_id', sellerId)
        .inFilter('status', ['pending', 'confirmed', 'preparing', 'ready'])
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Add an item to an order
  Future<Map<String, dynamic>> addOrderItem({
    required int orderId,
    required int productId,
    required int quantity,
    required double price,
  }) async {
    final item = await supabase
        .from('order_items')
        .insert({
          'order_id': orderId,
          'product_id': productId,
          'quantity': quantity,
          'price': price,
        })
        .select()
        .single();
    return item;
  }

  /// Re-order from a previous order: duplicates items under a new order
  Future<Map<String, dynamic>> reorder({
    required int previousOrderId,
    required String sellerId,
    String? deliveryAddress,
    String? deliveryTime,
    String? notes,
  }) async {
    // Fetch previous items
    final prevItems = await supabase
        .from('order_items')
        .select('product_id, quantity, price')
        .eq('order_id', previousOrderId);

    if (prevItems.isEmpty) {
      throw Exception('No items to reorder');
    }

    // Compute total price
    double total = 0;
    for (final it in prevItems) {
      total += (it['price'] as num).toDouble() * (it['quantity'] as int);
    }

    // Create the new order
    final newOrder = await createOrder(
      sellerId: sellerId,
      totalPrice: total,
      deliveryAddress: deliveryAddress,
      deliveryTime: deliveryTime,
      notes: notes,
    );

    // Add items to the new order
    for (final it in prevItems) {
      await addOrderItem(
        orderId: newOrder['id'] as int,
        productId: it['product_id'] as int,
        quantity: it['quantity'] as int,
        price: (it['price'] as num).toDouble(),
      );
    }

    return newOrder;
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
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  // ==================== PRODUCTS ====================

  /// Get products by seller
  Future<List<Map<String, dynamic>>> getProductsBySeller(
    String sellerId,
  ) async {
    final data = await supabase
        .from('products')
        .select()
        .eq('seller_id', sellerId)
        .eq('is_available', true)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Get products by category (global view for buyers) with seller embed
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String category, {
    int limit = 20,
  }) async {
    final data = await supabase
        .from('products')
        .select('''
          *,
          sellers(display_name, block)
        ''')
        .eq('category', category)
        .eq('is_available', true)
        .order('created_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Get ALL products from all sellers (for buyer home dashboard)
  Future<List<Map<String, dynamic>>> getAllProducts({int limit = 50}) async {
    final data = await supabase
        .from('products')
        .select('''
          *,
          sellers(display_name, block, rating)
        ''')
        .eq('is_available', true)
        .order('created_at', ascending: false)
        .limit(limit);
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
    final data = await supabase
        .from('products')
        .insert({
          'seller_id': sellerId,
          'name': name,
          'price': price,
          'description': description,
          'category': category,
          'image_url': imageUrl,
          'keywords': keywords,
          'is_available': true,
          'status': 'active',
        })
        .select()
        .single();

    return data;
  }

  // ==================== SELLER HELPERS ====================

  /// Get current user's seller profile (if exists)
  Future<Map<String, dynamic>?> getCurrentSellerProfile() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return null;
    final data = await supabase
        .from('sellers')
        .select()
        .eq('id', uid)
        .maybeSingle();
    return data;
  }

  /// Ensure current user has a seller profile, create if missing
  Future<Map<String, dynamic>> ensureSellerProfile({
    required String displayName,
    String? block,
    String? description,
    String? deliveryTime,
  }) async {
    await _ensureProfileExists();
    final existing = await getCurrentSellerProfile();
    if (existing != null) return existing;
    return await createSellerProfile(
      userId: supabase.auth.currentUser!.id,
      displayName: displayName,
      block: block ?? 'A',
      description: description,
      deliveryTime: deliveryTime,
    );
  }

  /// Ensure profile row exists (fallback if trigger failed or legacy user)
  Future<void> _ensureProfileExists() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await supabase.rpc('ensure_profile');
    } catch (_) {
      // ignore if function not deployed yet
    }
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

    final data = await supabase
        .from('messages')
        .insert({
          'sender_id': userId,
          'recipient_id': recipientId,
          'content': content,
          'conversation_id': int.parse(finalConversationId),
          'message_type': messageType ?? 'text',
          'order_id': orderId,
          'image_url': imageUrl,
          'is_read': false,
        })
        .select()
        .single();

    // Update conversation last_message
    await supabase
        .from('conversations')
        .update({
          'last_message': content,
          'last_message_at': DateTime.now().toIso8601String(),
        })
        .eq('id', int.parse(finalConversationId));

    return data;
  }

  /// Find existing conversation between two users
  Future<Map<String, dynamic>?> _findConversation(
    String userId1,
    String userId2,
  ) async {
    final data = await supabase
        .from('conversations')
        .select()
        .or(
          'and(participant_1_id.eq.$userId1,participant_2_id.eq.$userId2),and(participant_1_id.eq.$userId2,participant_2_id.eq.$userId1)',
        )
        .maybeSingle();
    return data;
  }

  /// Create new conversation
  Future<Map<String, dynamic>> _createConversation(
    String userId1,
    String userId2,
  ) async {
    final data = await supabase
        .from('conversations')
        .insert({'participant_1_id': userId1, 'participant_2_id': userId2})
        .select()
        .single();
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
  Stream<List<Map<String, dynamic>>> typingIndicatorsStream(
    int conversationId,
  ) {
    return supabase
        .from('typing_indicators')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId);
  }

  /// Cari produk berdasarkan keyword (mencari di kolom 'keywords' ATAU 'category')
  Future<List<Map<String, dynamic>>> getProductsByKeyword(String tag) async {
    try {
      final response = await supabase
          .from('products')
          .select('''
            *,
            sellers:seller_id(display_name, rating, block)
          ''') // join seller untuk info toko
          .or(
            'keywords.ilike.%$tag%, category.ilike.%$tag%',
          ) // Cek keyword ATAU category
          .eq('is_available', true)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching products by keyword: $e');
      return [];
    }
  }
}

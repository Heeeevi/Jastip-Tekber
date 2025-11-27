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
    String? category,
    bool? isOpen,
  }) async {
    var query = supabase
        .from('sellers')
        .select();

    if (category != null) {
      query = query.eq('category', category);
    }

    if (isOpen != null) {
      query = query.eq('is_open', isOpen);
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
    required String sellerName,
    required String block,
    String? description,
    String? category,
    String? avatarUrl,
  }) async {
    final data = await supabase.from('sellers').insert({
      'user_id': userId,
      'seller_name': sellerName,
      'block': block,
      'description': description,
      'category': category,
      'avatar_url': avatarUrl,
      'is_open': true,
      'rating': 0.0,
      'total_orders': 0,
    }).select().single();

    return data;
  }

  /// Update seller profile
  Future<void> updateSellerProfile({
    required String sellerId,
    String? sellerName,
    String? block,
    String? description,
    bool? isOpen,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (sellerName != null) updates['seller_name'] = sellerName;
    if (block != null) updates['block'] = block;
    if (description != null) updates['description'] = description;
    if (isOpen != null) updates['is_open'] = isOpen;

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
          sellers(seller_name, avatar_url, rating, block)
        ''')
        .eq('buyer_id', userId)
        .inFilter('status', ['pending', 'confirmed', 'ready'])
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
        .inFilter('status', ['pending', 'confirmed', 'ready']);

    return data.length;
  }

  /// Create new order
  Future<Map<String, dynamic>> createOrder({
    required String sellerId,
    required double totalPrice,
    String? deliveryTime,
    String? notes,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final data = await supabase.from('orders').insert({
      'buyer_id': userId,
      'seller_id': sellerId,
      'total_price': totalPrice,
      'status': 'pending',
      'delivery_time': deliveryTime,
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
}

# Supabase Implementation Guide - JasTip Flutter App

## ✅ Status Implementasi

### Completed:
1. **Database Setup** ✅
   - All tables created (profiles, sellers, products, orders, etc.)
   - Row Level Security (RLS) enabled
   - Triggers configured (auto-create profiles, update timestamps)
   - Indexes added for performance

2. **Supabase Service Layer** ✅
   - File: `lib/services/supabase_service.dart`
   - Authentication methods (signUp, signIn, signOut)
   - CRUD operations for sellers, products, orders
   - Favorites management
   - Notifications handling
   - Complete chat system (messages, conversations, typing indicators)
   - Real-time streams for orders and messages

3. **Authentication Integration** ✅
   - **Login Screen** (`lib/screens/login_screen.dart`)
     - Form validation added
     - Connected to Supabase auth
     - Loading states and error handling
     
   - **Sign Up Screen** (`lib/screens/sign_up_screen.dart`)
     - Form validation added
     - Connected to Supabase auth
     - Automatic profile creation on sign up
     - Loading states and error handling

### Next Steps to Complete Integration:

#### 1. Update Home Screen to Fetch Real Sellers
Currently, home_screen.dart uses mock data. To connect to Supabase:

```dart
// Add at top of home_screen.dart
import '../services/supabase_service.dart';

// In _HomeScreenState class
final _supabaseService = SupabaseService();
List<Map<String, dynamic>> sellers = [];
bool _isLoadingSellers = true;

@override
void initState() {
  super.initState();
  _loadSellers();
}

Future<void> _loadSellers() async {
  try {
    final data = await _supabaseService.fetchSellers(limit: 10);
    setState(() {
      sellers = data;
      _isLoadingSellers = false;
    });
  } catch (e) {
    setState(() => _isLoadingSellers = false);
    // Handle error
  }
}
```

Then update the seller card to use the real data structure:
- `seller['display_name']` instead of `seller['name']`
- `seller['is_online']` instead of `seller['open']`
- Access avatar from `seller['profiles']['avatar_url']`

#### 2. Integrate Orders Screen
File: `lib/screens/orders_screen.dart`

```dart
// Fetch active orders
final orders = await SupabaseService().fetchActiveOrders();

// Count badge
final count = await SupabaseService().countActiveOrders();
```

#### 3. Integrate Favorites Screen
File: `lib/screens/favorites_screen.dart`

```dart
// Fetch favorites
final favorites = await SupabaseService().fetchFavorites();

// Toggle favorite
await SupabaseService().toggleFavorite(sellerId);

// Check if favorited
final isFav = await SupabaseService().isFavorited(sellerId);
```

#### 4. Create Products Management (for Sellers)
```dart
// In seller dashboard, add products
await SupabaseService().createProduct(
  sellerId: currentUserId,
  name: 'Product Name',
  price: 15000,
  description: 'Product description',
  category: 'Food',
);

// Get seller's products
final products = await SupabaseService().getProductsBySeller(sellerId);
```

#### 5. Implement Chat System
```dart
// Send message
await SupabaseService().sendMessage(
  recipientId: sellerId,
  content: 'Hello!',
);

// Fetch conversations
final conversations = await SupabaseService().fetchConversations();

// Stream messages (real-time)
SupabaseService().messagesStream(conversationId).listen((messages) {
  // Update UI with new messages
});

// Set typing indicator
await SupabaseService().setTypingIndicator(
  conversationId: conversationId,
  isTyping: true,
);
```

## Database Structure Reference

### Tables:
1. **profiles** - User profiles (auto-created on sign up)
   - id (uuid, references auth.users)
   - full_name, role, dom_block, room_number
   - phone, bio, avatar_url

2. **sellers** - Seller-specific data
   - id (uuid, references profiles.id)
   - display_name, description, block, delivery_time
   - is_online, rating, total_orders

3. **products** - Seller products
   - id (bigint), seller_id
   - name, price, description, category
   - image_url, keywords, is_available, status

4. **orders** - Purchase orders
   - id (bigint), buyer_id, seller_id
   - total_price, delivery_fee, status
   - delivery_address, notes

5. **order_items** - Order line items
   - id (bigint), order_id, product_id
   - quantity, unit_price

6. **messages** - Chat messages
   - id (bigint), sender_id, recipient_id
   - content, conversation_id, message_type
   - is_read, order_id, image_url

7. **conversations** - Chat conversations
   - id (bigint), participant_1_id, participant_2_id
   - last_message, last_message_at

8. **favorites** - User favorite sellers
   - id (bigint), user_id, seller_id

9. **notifications** - User notifications
   - id (bigint), user_id, title, message
   - type, is_read

10. **typing_indicators** - Real-time typing status
    - id (bigint), conversation_id, user_id, is_typing

## Authentication Flow

### Sign Up:
1. User fills form with email, name, password
2. `SupabaseService().signUp()` creates auth user
3. Database trigger automatically creates profile record
4. User is signed in and redirected to home

### Sign In:
1. User enters email and password
2. `SupabaseService().signIn()` authenticates
3. Session is maintained by Supabase
4. User redirected to home screen

### Current User:
```dart
// Get current user
final user = SupabaseService().currentUser;
final userId = user?.id;

// Check if signed in
final isSignedIn = SupabaseService().isUserSignedIn;
```

## Important Notes:

1. **RLS Policies**: All tables have Row Level Security enabled
   - Users can only access their own data
   - Sellers can manage their products/orders
   - Messages require participants to be sender or recipient

2. **Real-time Features**: Use streams for live updates
   - `sellersStream()` for seller updates
   - `messagesStream()` for chat
   - `typingIndicatorsStream()` for typing status

3. **Error Handling**: Always wrap Supabase calls in try-catch
   ```dart
   try {
     await SupabaseService().someMethod();
   } catch (e) {
     // Show error to user
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Error: ${e.toString()}')),
     );
   }
   ```

4. **Loading States**: Show loading indicators while fetching data
   ```dart
   bool _isLoading = true;
   
   // In build:
   _isLoading 
     ? CircularProgressIndicator()
     : YourContent()
   ```

## Testing Authentication

### Test Sign Up:
1. Run the app
2. Go to Sign Up screen
3. Enter:
   - Email: test@example.com
   - Full Name: Test User
   - Password: test123
4. Click Sign Up
5. Check Supabase dashboard → Authentication → Users
6. Check Supabase dashboard → Table Editor → profiles

### Test Login:
1. Use the credentials from sign up
2. Go to Login screen
3. Enter email and password
4. Click Sign In
5. Should navigate to home screen

## Supabase Dashboard Access

- **URL**: https://lhnjwhnvawqzmoqwcadx.supabase.co
- **Location**: Authentication → Users (to see registered users)
- **Location**: Table Editor (to view/edit data)
- **Location**: SQL Editor (to run queries)

## Next Development Priorities:

1. **High Priority**:
   - Connect home screen to fetch real sellers ⚠️
   - Test sign up and sign in flows
   - Add profile image upload functionality

2. **Medium Priority**:
   - Implement orders screen with real data
   - Add favorites functionality
   - Create product management for sellers

3. **Low Priority**:
   - Implement chat system
   - Add notifications
   - Add real-time features (online status, typing indicators)

## Useful Commands:

```bash
# Check Supabase connection
# Add this temporarily in main.dart after Supabase.initialize():
final response = await supabase.from('profiles').select().limit(1);
print('Supabase connected: $response');

# Clear local storage (if needed)
# flutter clean
# flutter pub get
```

---

**Last Updated**: Current session
**Status**: Authentication complete, ready for UI integration

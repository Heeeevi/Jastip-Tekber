# 🐛 Debug Guide - Seller Profile "No seller provided" Issue

## Problem
Ketika klik seller card dari Home, muncul error "No seller provided" di Seller Profile page.

## Root Cause Analysis

### Possible Causes:
1. **Seller ID is NULL** - Data dari database tidak return `id` field
2. **Navigation arguments not passed** - Route arguments hilang during navigation
3. **Data type mismatch** - UUID from Supabase vs String in Dart

## Debug Steps

### Step 1: Check Console Logs
After clicking a seller card, check browser console (F12) for:
```
[HomeScreen] Seller card tapped: SotiStore
[HomeScreen] Seller ID: xxx-xxx-xxx-xxx
[HomeScreen] Seller data: {id: xxx, display_name: SotiStore, ...}
```

### Step 2: Verify Database
Run this query in Supabase SQL Editor:
```sql
SELECT 
  id,
  display_name,
  block,
  is_online,
  rating
FROM public.sellers
ORDER BY display_name;
```

Expected output:
```
id                                   | display_name       | block | is_online | rating
-------------------------------------|--------------------| ------|-----------|-------
xxx-xxx-xxx-xxx                     | Bakso Keputih      | B     | true      | 4.80
xxx-xxx-xxx-xxx                     | Dessert Paradise   | D     | true      | 4.90
```

### Step 3: Check Seller Profile Page Logs
After navigation, check for:
```
SellerProfilePage args: {seller: {...}, seller_id: xxx}
SellerProfilePage _sellerId: xxx
[SellerProfilePage] Fetching products for seller: xxx
[SellerProfilePage] Products fetched: 2 items
```

## Quick Fixes

### Fix 1: Force Seller ID from Arguments
If `seller_id` is null but `seller` object exists:

Edit `lib/screens/seller_profile_page.dart` line 35-40:
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  _seller = args?['seller'] as Map<String, dynamic>?;
  
  // Try multiple ways to get seller_id
  _sellerId = args?['seller_id']?.toString() 
           ?? _seller?['id']?.toString() 
           ?? (_seller?['sellers']?['id']?.toString()); // nested case
  
  print('DEBUG - args: $args');
  print('DEBUG - _sellerId: $_sellerId');
  print('DEBUG - _seller: $_seller');
  
  if (_sellerId != null || _seller != null) {
    _loadData();
  } else {
    setState(() { _error = 'No seller ID provided'; });
  }
}
```

### Fix 2: Reload Products Even If Seller Data Incomplete
Edit `lib/screens/seller_profile_page.dart` `_loadData()`:
```dart
Future<void> _loadData() async {
  setState(() { _loadingProducts = true; _error = null; });
  try {
    // If we have seller_id, always try to load products
    if (_sellerId != null) {
      _products = await _svc.getProductsBySeller(_sellerId!);
      
      // Load seller data if missing
      if (_seller == null) {
        _seller = await _svc.getSellerById(_sellerId!);
      }
    } else if (_seller != null) {
      // Extract seller_id from seller object
      _sellerId = _seller!['id']?.toString();
      if (_sellerId != null) {
        _products = await _svc.getProductsBySeller(_sellerId!);
      }
    }
  } catch (e) {
    print('ERROR: $e');
    _error = e.toString();
  } finally {
    setState(() { _loadingProducts = false; });
  }
}
```

### Fix 3: Add Fallback Empty State
If products is empty but no error:
```dart
if (_products.isEmpty && _error == null) {
  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'No products yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'This seller hasn\'t added any products',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    ),
  );
}
```

## Testing Checklist

- [ ] Console shows seller ID when clicking card
- [ ] Console shows "Fetching products for seller: xxx"
- [ ] Console shows "Products fetched: N items"
- [ ] Seller profile page shows seller name in AppBar
- [ ] Products appear in grid
- [ ] Can add products to cart
- [ ] Can checkout

## If Still Not Working

Share these debug outputs:
1. Console logs dari browser (F12 → Console)
2. Screenshot Supabase Table Editor → sellers table
3. Screenshot Supabase Table Editor → products table

---

**Created: 2025-11-29**

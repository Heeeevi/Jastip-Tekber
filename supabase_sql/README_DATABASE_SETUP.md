# 🗄️ Database Setup Guide - JasTip

Panduan lengkap untuk setup database Supabase untuk aplikasi JasTip.

---

## 📋 Prerequisites

1. **Akun Supabase**: https://supabase.com
2. **Project Supabase** sudah dibuat
3. **API Keys** sudah dicopy ke `lib/main.dart`:
   - `url`: Project URL (e.g., `https://xxx.supabase.co`)
   - `anonKey`: Anon/Public Key

---

## 🚀 Setup Steps

### **Option A: Fresh Database (Recommended for New Projects)**

Jika project baru atau ingin reset database dari awal:

#### Step 1: Wipe Database (Optional)
```sql
-- Run di Supabase SQL Editor
-- File: supabase_sql/WIPE_OUT.sql
-- ⚠️ WARNING: Ini akan menghapus semua data!
```

Copy-paste isi `WIPE_OUT.sql` ke SQL Editor dan Run.

#### Step 2: Create Schema
```sql
-- Run di Supabase SQL Editor
-- File: supabase_sql/SCHEMA_V1.sql
```

Copy-paste isi `SCHEMA_V1.sql` ke SQL Editor dan Run.

Schema ini akan membuat:
- ✅ `profiles` table
- ✅ `sellers` table (dengan `delivery_fee`, `rating`)
- ✅ `products` table
- ✅ `orders` table (dengan `delivery_fee`, `delivery_address`, `delivery_time`)
- ✅ `order_items` table
- ✅ `conversations` table
- ✅ `messages` table
- ✅ `favorites` table
- ✅ `notifications` table
- ✅ `typing_indicators` table
- ✅ Triggers (handle_new_user, set_updated_at)
- ✅ RLS Policies

#### Step 3: Create Test Users
Di Supabase Dashboard → Authentication → Users → Add User (Manual):

Create 4 test users:
1. **buyer@example.com** / password123
2. **seller@example.com** / password123
3. **seller3@example.com** / password123
4. **seller4@example.com** / password123

#### Step 4: Seed Data
```sql
-- Run di Supabase SQL Editor
-- File: supabase_sql/SEED_DATA.sql
```

Copy-paste isi `SEED_DATA.sql` ke SQL Editor dan Run.

Seed data akan create:
- ✅ 4 Sellers dengan store names
- ✅ 10+ Products (Bakso, Nasi Goreng, Desserts, Drinks)
- ✅ Sample Orders dengan items
- ✅ Conversations & Messages
- ✅ Favorites & Notifications

---

### **Option B: Existing Database (Add Missing Columns)**

Jika sudah punya database dan hanya perlu update schema:

#### Run Migration Script
```sql
-- Run di Supabase SQL Editor
-- File: supabase_sql/MIGRATION_ADD_DELIVERY_COLUMNS.sql
```

Migration ini akan:
- ✅ Add `delivery_fee` & `rating` to `sellers` table
- ✅ Add `delivery_fee`, `delivery_time`, `delivery_address` to `orders` table
- ✅ Refresh PostgREST schema cache
- ✅ Verify new columns exist

**⚠️ IMPORTANT**: Setelah run migration, tunggu ~10 detik agar PostgREST cache refresh!

---

## 🔍 Verification Queries

Jalankan query ini untuk memastikan setup berhasil:

### Check Tables Exist
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN (
    'profiles', 'sellers', 'products', 'orders', 
    'order_items', 'conversations', 'messages'
  )
ORDER BY table_name;
```

### Check Sellers with Products
```sql
SELECT 
  s.display_name, 
  s.block, 
  s.rating,
  s.delivery_fee,
  s.is_online,
  COUNT(p.id) as product_count
FROM public.sellers s
LEFT JOIN public.products p ON s.id = p.seller_id
GROUP BY s.id, s.display_name, s.block, s.rating, s.delivery_fee, s.is_online
ORDER BY s.display_name;
```

Expected output:
```
display_name          | block | rating | delivery_fee | is_online | product_count
Bakso Keputih        | B     | 4.80   | 0.00         | true      | 2
Dessert Paradise     | D     | 4.90   | 0.00         | true      | 3
Nasi Goreng Pak Joko | C     | 4.50   | 0.00         | true      | 3
```

### Check All Products
```sql
SELECT 
  p.name, 
  p.price, 
  p.category, 
  s.display_name as seller,
  p.is_available
FROM public.products p
JOIN public.sellers s ON p.seller_id = s.id
ORDER BY s.display_name, p.name;
```

### Check Sample Order
```sql
SELECT 
  o.id,
  o.status,
  o.delivery_address,
  o.delivery_time,
  buyer.full_name as buyer_name,
  seller.display_name as seller_name,
  COUNT(oi.id) as item_count,
  o.total_price
FROM public.orders o
JOIN public.profiles buyer ON o.buyer_id = buyer.id
JOIN public.sellers seller ON o.seller_id = seller.id
LEFT JOIN public.order_items oi ON o.id = oi.order_id
GROUP BY o.id, buyer.full_name, seller.display_name
ORDER BY o.created_at DESC
LIMIT 5;
```

---

## 🛠️ Troubleshooting

### Issue 1: "Column does not exist" Error
**Problem**: PostgREST schema cache belum refresh setelah ALTER TABLE.

**Solution**:
```sql
NOTIFY pgrst, 'reload schema';
```
Atau restart Supabase project (Dashboard → Settings → General → Pause → Resume)

---

### Issue 2: Users Not Found in Seed Data
**Problem**: Test users belum dibuat di Supabase Auth.

**Solution**: Create users manually via Supabase Dashboard → Authentication → Users.

---

### Issue 3: RLS Policy Blocking Queries
**Problem**: Row Level Security (RLS) policies blocking data access.

**Solution**: Pastikan user sudah login via app. RLS policies bergantung pada `auth.uid()`.

Test RLS dengan query ini (setelah login):
```sql
SELECT auth.uid(); -- Should return your user ID
SELECT * FROM public.profiles WHERE id = auth.uid();
```

---

## 📁 SQL Files Summary

| File | Purpose | When to Use |
|------|---------|-------------|
| `WIPE_OUT.sql` | Reset database (delete all data & tables) | Fresh start / debugging |
| `SCHEMA_V1.sql` | Create complete schema from scratch | New project / after wipe |
| `MIGRATION_ADD_DELIVERY_COLUMNS.sql` | Add missing columns to existing DB | Update existing project |
| `SEED_DATA.sql` | Insert test data (users, products, orders) | After schema creation |

---

## ✅ Final Checklist

- [ ] Supabase project created
- [ ] API keys copied to `lib/main.dart`
- [ ] Schema applied (`SCHEMA_V1.sql` OR `MIGRATION_ADD_DELIVERY_COLUMNS.sql`)
- [ ] Test users created (buyer@example.com, seller@example.com, etc.)
- [ ] Seed data inserted (`SEED_DATA.sql`)
- [ ] Verification queries return expected data
- [ ] PostgREST schema cache refreshed
- [ ] Flutter app can login and fetch data

---

## 🔗 Useful Supabase Links

- **SQL Editor**: Dashboard → SQL Editor
- **Table Editor**: Dashboard → Table Editor
- **Authentication**: Dashboard → Authentication → Users
- **API Docs**: Dashboard → Settings → API
- **Logs**: Dashboard → Logs

---

**Happy coding! 🚀**

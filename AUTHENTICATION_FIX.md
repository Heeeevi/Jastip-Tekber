# 🔐 Authentication Fix & Database Revision

## Masalah yang Diperbaiki

### ❌ Masalah Sebelumnya:
1. **Sign Up** hanya mengirim `full_name` ke database
2. **Profiles table** tidak menyimpan `email` pengguna
3. Service mencoba insert ke table `users` yang tidak ada
4. Trigger tidak menyimpan email dari auth.users

### ✅ Solusi Sekarang:
1. **Profiles table** sekarang punya kolom `email` (UNIQUE)
2. **Trigger `handle_new_user()`** otomatis menyimpan:
   - id (dari auth.users)
   - full_name
   - **email** (dari auth.users)
   - phone (opsional)
   - dom_block (opsional)
   - room_number (opsional)
3. **SupabaseService.signUp()** diperbaiki untuk kirim metadata lengkap
4. **Sign Up Screen** menggunakan `emailCtrl` bukan `emailPhoneCtrl`

---

## 📋 Langkah-Langkah Setup Ulang Database

### 1. Buka Supabase Dashboard
URL: https://lhnjwhnvawqzmoqwcadx.supabase.co

### 2. Pergi ke SQL Editor
Dashboard > SQL Editor > New Query

### 3. Copy & Paste SQL dari File
Buka file: **`SUPABASE_SETUP_REVISED.sql`**

### 4. Jalankan SQL Script
- Klik **Run** untuk execute
- Tunggu sampai selesai (biasanya 5-10 detik)

### 5. Verifikasi Setup
Cek di **Table Editor** bahwa semua table sudah ada:
- ✅ profiles (dengan kolom `email` yang baru)
- ✅ sellers
- ✅ products
- ✅ orders
- ✅ order_items
- ✅ messages
- ✅ conversations
- ✅ favorites
- ✅ notifications
- ✅ typing_indicators

---

## 🔄 Perubahan pada Profiles Table

### Struktur Baru:
```sql
CREATE TABLE public.profiles (
  id uuid PRIMARY KEY,              -- From auth.users
  full_name text NOT NULL,          -- User's full name
  email text NOT NULL UNIQUE,       -- ⭐ BARU: Email dari auth.users
  phone text,                       -- Optional phone number
  role text DEFAULT 'buyer',        -- 'buyer' or 'seller'
  dom_block text,                   -- Dormitory block
  room_number text,                 -- Room number
  bio text,                         -- User bio
  avatar_url text,                  -- Profile picture URL
  created_at timestamptz,           -- Created timestamp
  updated_at timestamptz            -- Updated timestamp
);
```

### Kolom yang Ditambahkan:
- **`email`** - Menyimpan email user dari auth.users
- **UNIQUE constraint** pada email untuk mencegah duplikat

---

## 🔧 Perubahan pada Trigger

### Trigger Function Baru:
```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email, phone, dom_block, room_number)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', ''),
    new.email,  -- ⭐ BARU: Ambil email dari auth.users
    COALESCE(new.raw_user_meta_data->>'phone', NULL),
    COALESCE(new.raw_user_meta_data->>'dom_block', NULL),
    COALESCE(new.raw_user_meta_data->>'room_number', NULL)
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Yang Berubah:
- ✅ Sekarang menyimpan `new.email` ke profiles.email
- ✅ Mengambil data tambahan dari `raw_user_meta_data`
- ✅ Menggunakan COALESCE untuk handle null values

---

## 💻 Perubahan pada Flutter Code

### 1. SupabaseService (`lib/services/supabase_service.dart`)

#### Sebelum:
```dart
Future<AuthResponse> signUp({
  required String email,
  required String password,
  String? fullName,
}) async {
  final response = await supabase.auth.signUp(
    email: email,
    password: password,
    data: {'full_name': fullName},
  );
  
  // ❌ Mencoba insert ke 'users' table yang tidak ada
  await supabase.from('users').insert({...});
  
  return response;
}
```

#### Sesudah:
```dart
Future<AuthResponse> signUp({
  required String email,
  required String password,
  required String fullName,  // ⭐ BARU: Required, bukan optional
  String? phone,             // ⭐ BARU: Optional fields
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
  
  // ✅ Profile otomatis dibuat oleh trigger
  // Tidak perlu manual insert
  
  return response;
}
```

### 2. Sign Up Screen (`lib/screens/sign_up_screen.dart`)

#### Perubahan Controller:
```dart
// Sebelum:
final TextEditingController emailPhoneCtrl = ...

// Sesudah:
final TextEditingController emailCtrl = ...  // ⭐ Nama lebih jelas
```

#### Perubahan Validasi:
```dart
// Sebelum:
if (emailPhoneCtrl.text.isEmpty) { ... }

// Sesudah:
final email = emailCtrl.text.trim();
if (email.isEmpty || !email.contains('@')) {
  _showSnackBar('Please enter a valid email address', Colors.red);
  return;
}
```

#### Perubahan Label:
```dart
// Sebelum:
label: 'Email or Mobile Phone',

// Sesudah:
label: 'Email',  // ⭐ Lebih jelas dan sesuai requirement
```

---

## 🧪 Testing Sign Up & Sign In

### Test Sign Up:

1. **Buka aplikasi** dan pergi ke Sign Up screen

2. **Isi form**:
   - Email: `test@example.com`
   - Full Name: `Test User`
   - Password: `password123` (min 6 karakter)

3. **Klik Sign Up**

4. **Expected Result**:
   - Loading indicator muncul
   - Sukses message: "Account created successfully!"
   - Navigate ke Login screen

5. **Verifikasi di Supabase Dashboard**:
   - Pergi ke: **Authentication > Users**
   - Harusnya ada user baru dengan email `test@example.com`
   
   - Pergi ke: **Table Editor > profiles**
   - Harusnya ada row baru dengan:
     - id: (UUID dari auth.users)
     - full_name: `Test User`
     - email: `test@example.com` ⭐
     - role: `buyer`
     - created_at & updated_at: timestamp

### Test Sign In:

1. **Pergi ke Login screen**

2. **Isi form**:
   - Email: `test@example.com`
   - Password: `password123`

3. **Klik Sign In**

4. **Expected Result**:
   - Loading indicator muncul
   - Navigate ke Home screen
   - User sudah authenticated

5. **Verifikasi Session**:
   - Session tersimpan di browser
   - Refresh page → User masih login
   - Bisa akses protected features

---

## 📊 Database Relationship Overview

```
auth.users (Supabase Auth)
    ↓ (trigger: handle_new_user)
profiles (User Data) ← email disimpan di sini juga
    ↓
    ├─→ sellers (Seller-specific data)
    │       ↓
    │       ├─→ products
    │       └─→ orders (as seller)
    │
    ├─→ orders (as buyer)
    │       └─→ order_items
    │
    ├─→ messages (as sender/recipient)
    │       └─→ conversations
    │
    ├─→ favorites
    └─→ notifications
```

---

## 🔐 Security (RLS Policies)

### Profiles Table:
- ✅ **SELECT**: Everyone can read (public profiles)
- ✅ **UPDATE**: Only own profile

### Email Privacy:
- Email tersimpan di profiles table
- RLS policy memastikan user hanya bisa edit profile sendiri
- Email bisa diakses untuk keperluan:
  - Display user info
  - Send notifications
  - Password reset

---

## 🚨 Troubleshooting

### Issue: Sign up berhasil tapi profile tidak dibuat

**Solution**:
1. Cek trigger sudah dibuat:
   ```sql
   SELECT * FROM information_schema.triggers 
   WHERE trigger_name = 'on_auth_user_created';
   ```

2. Test trigger manual:
   ```sql
   -- Test insert ke auth.users
   -- Harusnya otomatis create profile
   ```

3. Cek function exists:
   ```sql
   SELECT * FROM pg_proc 
   WHERE proname = 'handle_new_user';
   ```

### Issue: Email tidak muncul di profiles table

**Solution**:
1. **Drop & recreate trigger**:
   ```sql
   DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
   DROP FUNCTION IF EXISTS handle_new_user();
   ```
   
2. **Run SUPABASE_SETUP_REVISED.sql** lagi

3. **Test dengan user baru**

### Issue: Duplicate key error pada email

**Solution**:
- Email sudah ada di database
- Gunakan email berbeda untuk sign up
- Atau delete user lama:
  ```sql
  DELETE FROM auth.users WHERE email = 'test@example.com';
  -- Profile akan otomatis terhapus (CASCADE)
  ```

---

## 📝 Summary

### ✅ Yang Sudah Diperbaiki:
1. **Database Schema**: Profiles table punya kolom `email`
2. **Trigger**: Auto-create profile dengan email dari auth.users
3. **SupabaseService**: Method signUp() kirim metadata lengkap
4. **Sign Up Screen**: Validasi email yang proper
5. **SQL Script**: File `SUPABASE_SETUP_REVISED.sql` sudah fix

### 🎯 Next Steps:
1. **Run SQL script** di Supabase Dashboard
2. **Test sign up** dengan email baru
3. **Verifikasi** profile dibuat dengan email
4. **Test sign in** dengan credentials yang sama
5. **Continue development** dengan confidence! 🚀

---

**File Changes**:
- ✅ `lib/services/supabase_service.dart` - Updated signUp method
- ✅ `lib/screens/sign_up_screen.dart` - Fixed controller & validation
- ✅ `SUPABASE_SETUP_REVISED.sql` - Complete new schema with fixes

**Last Updated**: Current session
**Status**: Ready to test! 🎉

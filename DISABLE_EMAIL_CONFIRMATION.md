# Disable Email Confirmation - Supabase Setup

## Masalah:
Setelah register, user tidak bisa langsung login dan muncul error "Please confirm your email first"

## Solusi:

### Step 1: Buka Supabase Dashboard
1. Go to: https://lhnjwhnvawqzmoqwcadx.supabase.co
2. Login dengan akun Supabase Anda

### Step 2: Disable Email Confirmation
1. Pergi ke: **Authentication** (sidebar kiri)
2. Klik tab **"Providers"**
3. Cari section **"Email"**
4. Klik **"Edit"** atau settings icon
5. **MATIKAN** toggle untuk:
   - ❌ **"Confirm email"** atau **"Enable email confirmations"**
6. Klik **"Save"**

### Step 3: Verifikasi Setting
Pastikan setting seperti ini:
```
Email Provider:
  ✅ Enabled: ON
  ❌ Confirm email: OFF  ← PENTING!
  ✅ Secure email change: ON (optional)
```

### Step 4: Test Sign Up & Sign In
1. Register user baru di app
2. Langsung coba Sign In tanpa confirm email
3. Harusnya bisa login langsung! ✅

---

## Alternative: Jika Masih Ada Masalah

### Manually Confirm Existing Users:

1. Pergi ke: **Authentication > Users**
2. Cari user yang belum confirmed (ada icon warning)
3. Klik user tersebut
4. Klik **"Confirm email"** button
5. User sekarang bisa login

### Atau Via SQL:

```sql
-- Confirm all existing users
UPDATE auth.users 
SET email_confirmed_at = now() 
WHERE email_confirmed_at IS NULL;
```

---

## Untuk Production (Nanti):

Jika nanti mau production, bisa enable email confirmation lagi dan setup:
1. Email templates
2. SMTP settings
3. Redirect URLs

Tapi untuk development/testing, lebih baik disable dulu! 🚀

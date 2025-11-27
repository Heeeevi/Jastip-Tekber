# Supabase Database Setup untuk JasTip

## Langkah-langkah Setup Database

### 1. Buka Supabase Dashboard
- Go to: https://app.supabase.com
- Select project: `lhnjwhnvawqzmoqwcadx`

### 2. Buat Tabel `users`
Jalankan SQL query berikut di SQL Editor:

```sql
-- Buat tabel users (jika belum ada)
CREATE TABLE IF NOT EXISTS users (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email varchar(255) NOT NULL UNIQUE,
    full_name varchar(255),
    phone varchar(20),
    avatar_url text,
    block varchar(10),
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

-- Enable RLS (Row Level Security)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Users dapat membaca profil mereka sendiri
CREATE POLICY "Users can read own profile" ON users
    FOR SELECT USING (auth.uid() = id);

-- Policy: Users dapat update profil mereka sendiri
CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

-- Policy: Users baru dapat insert profil mereka
CREATE POLICY "Users can insert own profile" ON users
    FOR INSERT WITH CHECK (auth.uid() = id);
```

### 3. Setup Auth Configuration
Di Supabase Dashboard:
1. Go to **Authentication** → **Providers**
2. Make sure **Email** is enabled
3. Go to **Email Templates** dan konfigurasi sesuai kebutuhan

### 4. Verifikasi Setup
Setelah menjalankan SQL:
1. Go ke **Table Editor**
2. Verify bahwa tabel `users` sudah muncul
3. Coba signup dari aplikasi dan check apakah data masuk ke tabel

## Troubleshooting

### Jika signup masih gagal:
1. Check **Logs** di Supabase Dashboard
2. Pastikan RLS policy sudah benar
3. Verify bahwa anonKey di `main.dart` sudah correct

### Jika data tidak masuk ke database:
1. Check console app untuk error message
2. Pastikan internet connection stabil
3. Verify bahwa user berhasil create di auth (cek di **Authentication** → **Users**)

# JASTIP

## Deskripsi Proyek

JasTip adalah aplikasi mobile berbasis **Flutter** yang dikembangkan untuk memfasilitasi layanan jasa titip (jastip) bagi mahasiswa penghuni Asrama ITS. Aplikasi ini menggantikan proses pemesanan manual melalui grup WhatsApp menjadi sistem digital yang lebih **terstruktur, efisien, dan transparan**.

Melalui aplikasi ini, buyer dapat mencari PO aktif, melakukan pemesanan, serta memantau status pesanan secara real-time. Di sisi lain, jastiper (seller) dapat mengelola PO, menu, dan pesanan secara sistematis tanpa pencatatan manual.

---

## Fitur Aplikasi

### Fitur untuk Buyer

* Melihat daftar jastip (PO) yang sedang aktif
* Mencari jastip berdasarkan menu, seller, atau kata kunci
* Melakukan pemesanan secara terstruktur (pilih menu, catatan, checkout)
* Melihat status pesanan secara real-time
* Membatalkan pesanan selama masih menunggu persetujuan seller
* Chat langsung dengan jastiper

### Fitur untuk Jastiper (Seller)

* Mengaktifkan dan menonaktifkan PO (Online / Offline)
* Melihat dan mengelola pesanan yang masuk
* Mengubah status pesanan (New, Preparing, Completed)
* Menambah dan mengelola menu jastip
* Membatalkan pesanan dengan alasan

### Fitur Umum

* Registrasi akun (Sign Up)
* Login pengguna (Sign In)
* Perpindahan role antara Buyer dan Jastiper
* Sistem chat real-time

---

## Cara Instalasi

Pastikan perangkat sudah memenuhi prasyarat berikut:

* Flutter SDK
* Android Studio / Emulator atau perangkat Android
* Git

Langkah instalasi:

```bash
git clone <repository-url>
cd jastip-asrama-its
flutter pub get
```

---

## Cara Menjalankan Aplikasi

Jalankan aplikasi menggunakan perintah berikut:

```bash
flutter run
```

Pastikan emulator atau perangkat Android sudah terhubung sebelum menjalankan perintah di atas.


## Struktur Folder

Struktur folder utama pada project Flutter ini adalah sebagai berikut (difokuskan pada folder yang paling sering dikembangkan):

```
lib/
│
├── main.dart                  # Entry point aplikasi
├── cart_provider.dart         # State management keranjang
│
├── screens/                   # Seluruh UI / halaman aplikasi
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── sign_up_screen.dart
│   ├── profile_page.dart
│   ├── seller_dashboard_screen.dart
│   ├── seller_profile_page.dart
│   ├── add_item_screen.dart
│   ├── all_sellers_screen.dart
│   ├── search_screen.dart
│   ├── favorites_screen.dart
│   ├── orders_screen.dart
│   ├── order_detail_screen.dart
│   ├── order_status_screen.dart
│   ├── order_confirmation_screen.dart
│   ├── chat.dart
│   ├── chat_conversation_screen.dart
│   └── menu_chat.dart
│
├── services/                  # Integrasi backend (Supabase)
│   └── supabase_service.dart
```

Folder penting lainnya:

```
assets/                        # Asset statis (gambar, ikon)
│   └── images/
│
android/                       # Konfigurasi Android
ios/                           # Konfigurasi iOS
web/                           # Konfigurasi Web
windows/, macos/, linux/       # Konfigurasi desktop

supabase_sql/                  # Script SQL & migrasi database
build/                         # Output hasil build (auto-generated)
```

> Catatan: Fokus utama pengembangan aplikasi berada pada folder `lib/screens` dan `lib/services`, karena seluruh logika tampilan dan integrasi backend didefinisikan di dalam folder tersebut.

---

README ini disediakan untuk membantu proses instalasi, menjalankan aplikasi, serta memahami struktur project JasTip Asrama ITS.

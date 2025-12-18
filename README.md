# JASTIP

> **Aplikasi Jasa Titip Mahasiswa Asrama ITS**

---

## Deskripsi Proyek

**JasTip** adalah aplikasi mobile berbasis **Flutter** yang dikembangkan untuk memfasilitasi layanan jasa titip (jastip) **bagi mahasiswa penghuni Asrama ITS**. Aplikasi ini dirancang sebagai solusi digital atas proses pemesanan konvensional yang sebelumnya dilakukan melalui grup WhatsApp, yang cenderung tidak terstruktur dan rawan miskomunikasi.

Melalui JasTip, proses pemesanan menjadi lebih **terorganisir, efisien, dan transparan**. Buyer dapat dengan mudah menemukan PO (Pre-Order) yang aktif, melakukan pemesanan, serta memantau status pesanan secara *real-time*. Sementara itu, jastiper (seller) dapat mengelola PO, menu, dan pesanan secara sistematis tanpa perlu pencatatan manual.

---

## Fitur Aplikasi

### Fitur untuk Buyer

* Melihat daftar jastip (PO) yang sedang aktif
* Mencari jastip berdasarkan menu, seller, atau kata kunci
* Melakukan pemesanan secara terstruktur (pilih menu, catatan, checkout)
* Melihat status pesanan secara *real-time*
* Membatalkan pesanan selama masih menunggu persetujuan seller
* Chat langsung dengan jastiper

### Fitur untuk Jastiper (Seller)

* Mengaktifkan dan menonaktifkan PO (*Online / Offline*)
* Melihat dan mengelola pesanan yang masuk
* Mengubah status pesanan (*New, Preparing, Completed*)
* Menambah dan mengelola menu jastip
* Membatalkan pesanan dengan alasan

### Fitur Umum

* Registrasi akun (*Sign Up*)
* Login pengguna (*Sign In*)
* Perpindahan role antara Buyer dan Jastiper
* Sistem chat *real-time*

---

## Tech Stack

Aplikasi **JasTip** dikembangkan menggunakan teknologi berikut:

### Frontend

* **Flutter** : Framework utama untuk membangun aplikasi mobile lintas platform (Android).
* **Dart** : Bahasa pemrograman yang digunakan dalam pengembangan aplikasi Flutter.

### Backend (Backend-as-a-Service)

* **Supabase** : Digunakan sebagai backend utama yang menyediakan:

  * Authentication (Sign Up, Sign In)
  * Database **PostgreSQL** untuk penyimpanan data pengguna, menu, pesanan, dan chat
  * Realtime Database untuk pembaruan status pesanan dan fitur chat
  * Storage untuk penyimpanan gambar (menu, avatar pengguna)

### Tools Pendukung

* **Git & GitHub** : Version control dan kolaborasi pengembangan
* **Android Studio** : Emulator dan debugging aplikasi

---

## Cara Instalasi

Pastikan perangkat telah memenuhi prasyarat berikut:

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

Jalankan aplikasi dengan perintah berikut:

```bash
flutter run
```

> Pastikan emulator atau perangkat Android sudah terhubung sebelum menjalankan perintah di atas.

---

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

### Folder Penting Lainnya

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

> **Catatan:** Fokus utama pengembangan aplikasi berada pada folder `lib/screens` dan `lib/services`, karena seluruh logika tampilan dan integrasi backend didefinisikan di dalam folder tersebut.

---

README ini disediakan untuk membantu proses instalasi, menjalankan aplikasi, serta memahami struktur project **JasTip**.

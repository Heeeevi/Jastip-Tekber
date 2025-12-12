import 'package:flutter/material.dart';

// Model sederhana untuk item keranjang
class CartItem {
  final String id;
  final String title;
  final int price;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    this.quantity = 0,
  });
}

class CartProvider with ChangeNotifier {
  // Map untuk menyimpan item: Key-nya adalah ID barang
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  // Hitung total harga semua barang
  int get totalAmount {
    var total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // Hitung total jumlah barang (untuk badge notifikasi misal)
  int get itemCount {
    return _items.length;
  }

  // Fungsi untuk menambah barang (+)
  void addItem(String productId, int price, String title) {
    if (_items.containsKey(productId)) {
      // Jika barang sudah ada, tambah jumlahnya
      _items.update(
        productId,
        (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          price: existing.price,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      // Jika barang belum ada, buat baru
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners(); // Kabari semua halaman kalau data berubah
  }

  // Fungsi untuk mengurangi barang (-)
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      // Kurangi 1
      _items.update(
        productId,
        (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          price: existing.price,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      // Kalau sisa 1 dikurang, hapus dari keranjang
      _items.remove(productId);
    }
    notifyListeners();
  }

  // Ambil jumlah qty per item spesifik (untuk ditampilkan di tengah tombol - 0 +)
  int getQuantity(String id) {
    return _items.containsKey(id) ? _items[id]!.quantity : 0;
  }
  
  // Bersihkan keranjang (misal setelah checkout)
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
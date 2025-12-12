import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cart_provider.dart';
import '../services/supabase_service.dart';

// --- Theme Colors (Sesuai Referensi Gambar) ---
const Color kBackgroundColor = Color(0xFF19222C); // Background layar gelap
const Color kPrimaryPurple = Color(0xFF5F63D9);   // Warna Ungu Utama (Card & Button)
const Color kGreenColor = Color(0xFF6FCF97);      // Warna Hijau (Tombol Ganti/Tambah)
const Color kTextColorPrimary = Colors.white;

class OrderConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> seller;
  
  const OrderConfirmationScreen({super.key, required this.seller});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  final _svc = SupabaseService();
  final TextEditingController _addressController = TextEditingController();
  
  final int _deliveryFee = 9000;
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _processOrder() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final address = _addressController.text.trim();

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon isi alamat pengantaran')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final subtotal = cart.totalAmount;
      final grandTotal = subtotal + _deliveryFee;
      final sellerId = widget.seller['id'].toString();

      // 1. Buat Order
      final order = await _svc.createOrder(
        sellerId: sellerId,
        totalPrice: grandTotal.toDouble(),
        deliveryAddress: address,
        deliveryTime: "ASAP",
      );

      // 2. Masukkan Item
      for (final cartItem in cart.items.values) {
        await _svc.addOrderItem(
          orderId: order['id'] as int,
          productId: int.parse(cartItem.id),
          quantity: cartItem.quantity,
          price: cartItem.price.toDouble(),
        );
      }

      cart.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dibuat!')));
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false); 
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final subtotal = cart.totalAmount;
    final grandTotal = subtotal + _deliveryFee;
    
    // Ambil info seller untuk header
    final sellerName = widget.seller['display_name'] ?? widget.seller['name'] ?? 'Seller';

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(sellerName, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  // --- 1. KOTAK ALAMAT (UNGU) ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kPrimaryPurple, // Background Ungu
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Alamat Pengantaran', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _addressController,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), // Teks Putih Tebal
                                cursorColor: Colors.white,
                                maxLines: 2,
                                minLines: 1,
                                decoration: const InputDecoration(
                                  hintText: 'Masukkan alamat lengkap...',
                                  hintStyle: TextStyle(color: Colors.white54), // Hint abu muda
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  filled: false, 
                                  fillColor: Colors.transparent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Tombol Ganti Alamat (Hijau)
                            SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Fitur ganti alamat (bisa dikembangkan nanti)
                                  _addressController.clear(); 
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kGreenColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Ganti alamat', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // --- 2. KOTAK DAFTAR ITEM (UNGU) ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kPrimaryPurple, // Background Ungu
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ...cart.items.values.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      // Text('Level 3\nEkstra kuah', style: TextStyle(color: Colors.white70, fontSize: 12)), // Contoh deskripsi
                                      const SizedBox(height: 4),
                                      Text('Rp${item.price}', style: const TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    _RoundQtyBtn(icon: Icons.remove, onTap: () => cart.removeSingleItem(item.id)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text('${item.quantity}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                    ),
                                    _RoundQtyBtn(icon: Icons.add, onTap: () => cart.addItem(item.id, item.price, item.title)),
                                  ],
                                )
                              ],
                            ),
                          );
                        }).toList(),
                        
                        const Divider(color: Colors.white24),
                        // Bagian Tambahan (Opsional sesuai gambar)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Ada tambahan?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context), // Balik ke menu
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kGreenColor.withOpacity(0.2),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Tambah', style: TextStyle(fontSize: 12, color: kGreenColor, fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- 3. KOTAK TOTAL (UNGU) ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kPrimaryPurple, // Background Ungu
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _rowPrice('Harga', 'Rp$subtotal'),
                        const SizedBox(height: 8),
                        _rowPrice('Biaya pengantaran', 'Rp$_deliveryFee'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(color: Colors.white24),
                        ),
                        _rowPrice('Total', 'Rp$grandTotal', isTotal: true),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // --- 4. TOMBOL PESAN (STICKY DI BAWAH) ---
          Container(
            padding: const EdgeInsets.all(20),
            color: kBackgroundColor, // Warna dasar biar nyatu sama background
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryPurple, // Tombol Ungu
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), // Membulat penuh
                  elevation: 5,
                  shadowColor: kPrimaryPurple.withOpacity(0.5),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Pesan sekarang', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _rowPrice(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: Colors.white, fontSize: isTotal ? 18 : 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// Widget Tombol + / - yang bulat hijau
class _RoundQtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundQtyBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: kGreenColor, // Warna Hijau
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
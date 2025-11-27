import 'package:flutter/material.dart';

class OrderStatusScreen extends StatelessWidget {
  final String courierName = "Jastip Alan Walker";
  final String orderPlaced = "07.30 - Order placed";
  final String headingToRestaurant = "07.30 - Heading to restoran";

  const OrderStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order Status",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Courier name
            Text(
              courierName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            // Timeline status
            _buildStatusText(orderPlaced),
            const SizedBox(height: 4),
            _buildStatusText(headingToRestaurant),

            const SizedBox(height: 20),

            // System status + courier status box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Pesananmu sudah diterima sistem",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Alan walker menuju restoran",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ETA box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Estimasi: 30 menit",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 40),

            // Buttons Chat & Order Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.chat_bubble_outline, "Chat"),
                _buildActionButton(Icons.receipt_long, "Order Details"),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.home, size: 28),
            Icon(Icons.receipt, size: 28),
            Icon(Icons.favorite, size: 28),
            Icon(Icons.chat, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

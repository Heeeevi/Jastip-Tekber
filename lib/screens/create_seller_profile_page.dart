import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

// --- KONSTANTA WARNA ---
const Color kBackgroundColor = Color(0xFF19222C);
const Color kCardColor = Color(0xFF232C38);
const Color kAccentColor = Color(0xFF5B61E6);
const Color kTextColorPrimary = Colors.white;
const Color kTextColorSecondary = Colors.grey;

class CreateSellerProfilePage extends StatefulWidget {
  // Parameter untuk menentukan apakah user adalah seller atau buyer
  final bool isSeller;

  const CreateSellerProfilePage({super.key, this.isSeller = false});

  @override
  State<CreateSellerProfilePage> createState() =>
      _CreateSellerProfilePageState();
}

class _CreateSellerProfilePageState extends State<CreateSellerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseService _supabaseService = SupabaseService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _deliveryTimeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _deliveryFeeController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _deliveryTimeController.dispose();
    _phoneController.dispose();
    _blockController.dispose();
    _deliveryFeeController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isSeller) {
      _prefillSeller();
    }
  }

  Future<void> _prefillSeller() async {
    try {
      final seller = await _supabaseService.getCurrentSellerProfile();
      if (seller != null) {
        _nameController.text = seller['display_name']?.toString() ?? '';
        _bioController.text = seller['description']?.toString() ?? '';
        _deliveryTimeController.text = seller['delivery_time']?.toString() ?? '';
        _blockController.text = seller['block']?.toString() ?? '';
        _deliveryFeeController.text = (seller['delivery_fee']?.toString() ?? '0');
        _ratingController.text = (seller['rating']?.toString() ?? '0');
        if (mounted) setState(() {});
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: Text(
          widget.isSeller ? 'Edit Seller Profile' : 'Edit Profile',
          style: const TextStyle(color: kTextColorPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextColorPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // --- BAGIAN 1: PICKER FOTO PROFIL ---
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kCardColor,
                          border: Border.all(color: kAccentColor, width: 2),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://i.pravatar.cc/300?img=12',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kAccentColor,
                            border: Border.all(
                              color: kBackgroundColor,
                              width: 3,
                            ),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Fitur pilih gambar belum diimplementasikan",
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // --- BAGIAN 2: FORM INPUT FIELDS ---
                _buildSectionLabel("Public Information"),
                const SizedBox(height: 15),

                _buildDarkTextField(
                  controller: _nameController,
                  label: 'Display Name',
                  hint: 'e.g., Alan Walker',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your display name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildDarkTextField(
                  controller: _bioController,
                  label: 'Bio / Description',
                  hint: widget.isSeller
                      ? 'What kind of jastip do you offer?'
                      : 'Tell us about yourself',
                  icon: Icons.info_outline,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                _buildDarkTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: 'e.g., 081234567890',
                  icon: Icons.phone_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildDarkTextField(
                  controller: _blockController,
                  label: 'Block / Dorm',
                  hint: 'e.g., Block A',
                  icon: Icons.home_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your block/dorm';
                    }
                    return null;
                  },
                ),

                // Tampilkan field delivery time hanya untuk seller
                if (widget.isSeller) ...[
                  const SizedBox(height: 20),
                  _buildDarkTextField(
                    controller: _deliveryTimeController,
                    label: 'Typical Delivery Time',
                    hint: 'e.g., 20-30min',
                    icon: Icons.timer_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter delivery estimate';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildDarkTextField(
                    controller: _deliveryFeeController,
                    label: 'Delivery Fee (Rp)',
                    hint: 'e.g., 5000',
                    icon: Icons.delivery_dining,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter fee';
                      final v = double.tryParse(value.replaceAll(',', '.'));
                      if (v == null) return 'Invalid number';
                      if (v < 0) return 'Must be >= 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildDarkTextField(
                    controller: _ratingController,
                    label: 'Rating (0-5)',
                    hint: 'e.g., 4.8',
                    icon: Icons.star_rate,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter rating';
                      final v = double.tryParse(value.replaceAll(',', '.'));
                      if (v == null) return 'Invalid number';
                      if (v < 0 || v > 5) return '0 - 5 only';
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 50),

                // --- BAGIAN 3: TOMBOL SUBMIT ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: kAccentColor.withOpacity(0.4),
                    ),
                    onPressed: _submitProfile,
                    child: Text(
                      widget.isSeller ? 'Save Seller Profile' : 'Save Profile',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- BAGIAN 4: TOMBOL LOGOUT ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: _handleLogout,
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitProfile() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final phone = _phoneController.text;
      final block = _blockController.text;

      String message;
      if (widget.isSeller) {
        final deliveryTime = _deliveryTimeController.text;
        final deliveryFee = double.tryParse(_deliveryFeeController.text.replaceAll(',', '.')) ?? 0.0;
        final rating = double.tryParse(_ratingController.text.replaceAll(',', '.')) ?? 0.0;
        // Save to Supabase
        final uid = _supabaseService.getCurrentUser()?.id;
        if (uid != null) {
          _supabaseService.updateSellerProfile(
            sellerId: uid,
            displayName: name,
            block: block,
            description: _bioController.text,
            deliveryTime: deliveryTime,
            deliveryFee: deliveryFee,
            rating: rating,
            isOnline: true,
          );
        }
        message = 'Seller profile saved!';
      } else {
        message = 'Profile saved! Name: $name, Phone: $phone, Block: $block';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );

      // Kembali ke halaman sebelumnya setelah 1 detik
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    }
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabaseService.signOut();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to login after logout
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: kTextColorPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDarkTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: kTextColorPrimary),
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: kTextColorSecondary),
        hintText: hint,
        hintStyle: TextStyle(color: kTextColorSecondary.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: kAccentColor),
        filled: true,
        fillColor: kCardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: kAccentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }
}

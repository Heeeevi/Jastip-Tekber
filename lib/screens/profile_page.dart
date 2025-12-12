import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

// --- KONSTANTA WARNA ---
const Color kBackgroundColor = Color(0xFF19222C);
const Color kCardColor = Color(0xFF232C38);
const Color kAccentColor = Color(0xFF5B61E6);
const Color kTextColorPrimary = Colors.white;
const Color kTextColorSecondary = Colors.grey;

class ProfilePage extends StatefulWidget {
  // Parameter untuk menentukan apakah user adalah seller atau buyer
  final bool isSeller;

  const ProfilePage({super.key, this.isSeller = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseService _supabaseService = SupabaseService();

  // Controller
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _deliveryTimeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _deliveryFeeController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  bool _isLoading = false; // Untuk indikator loading saat save
  bool _isInit = true; // Untuk load data sekali saja

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _loadProfileData();
      _isInit = false;
    }
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      if (widget.isSeller) {
        // --- LOAD DATA SELLER ---
        final seller = await _supabaseService.getCurrentSellerProfile();
        if (seller != null) {
          _nameController.text = seller['display_name']?.toString() ?? '';
          _bioController.text = seller['description']?.toString() ?? '';
          _deliveryTimeController.text =
              seller['delivery_time']?.toString() ?? '';
          _blockController.text = seller['block']?.toString() ?? '';
          _deliveryFeeController.text =
              (seller['delivery_fee']?.toString() ?? '0');
          _ratingController.text = (seller['rating']?.toString() ?? '0');
          // Note: Phone biasanya ada di table 'profiles' user, bukan 'sellers'
          // Tapi kita biarkan kosong dulu atau ambil dari user profile kalau ada methodnya.
        }
      } else {
        // --- LOAD DATA BUYER (USER BIASA) ---
        // Asumsi: Kamu punya table 'profiles' atau metadata user
        final user = _supabaseService.getCurrentUser();
        if (user != null) {
          final profile = await _supabaseService.getUserProfile(user.id);

          if (profile != null) {
            // MAPPING DATA SESUAI TABEL PROFILES KAMU:

            // 1. full_name
            _nameController.text = profile['full_name']?.toString() ?? '';

            // 2. bio
            _bioController.text = profile['bio']?.toString() ?? '';

            // 3. phone
            _phoneController.text = profile['phone']?.toString() ?? '';

            // 4. dom_block
            _blockController.text = profile['dom_block']?.toString() ?? '';
          }
        }
      }
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAccentColor))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // --- BAGIAN 1: FOTO PROFIL (DUMMY) ---
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: kCardColor,
                                border: Border.all(
                                  color: kAccentColor,
                                  width: 2,
                                ),
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
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // --- BAGIAN 2: FORM INPUT ---
                      _buildSectionLabel("Public Information"),
                      const SizedBox(height: 15),

                      _buildDarkTextField(
                        controller: _nameController,
                        label: 'Display Name',
                        hint: 'e.g., Alan Walker',
                        icon: Icons.person_outline,
                        validator: (val) =>
                            (val == null || val.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      _buildDarkTextField(
                        controller: _bioController,
                        label: 'Bio / Description',
                        hint: 'Tell us about yourself',
                        icon: Icons.info_outline,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),

                      _buildDarkTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: 'e.g., 081234567890',
                        icon: Icons.phone_outlined,
                        validator: (val) =>
                            (val == null || val.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      _buildDarkTextField(
                        controller: _blockController,
                        label: 'Block / Dorm',
                        hint: 'e.g., Block A',
                        icon: Icons.home_outlined,
                        validator: (val) =>
                            (val == null || val.isEmpty) ? 'Required' : null,
                      ),

                      // FIELD KHUSUS SELLER
                      if (widget.isSeller) ...[
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 20),
                        _buildSectionLabel("Store Settings"),
                        const SizedBox(height: 15),

                        _buildDarkTextField(
                          controller: _deliveryTimeController,
                          label: 'Typical Delivery Time',
                          hint: 'e.g., 20-30min',
                          icon: Icons.timer_outlined,
                          validator: (val) =>
                              (val == null || val.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 20),

                        _buildDarkTextField(
                          controller: _deliveryFeeController,
                          label: 'Delivery Fee (Rp)',
                          hint: 'e.g., 5000',
                          icon: Icons.delivery_dining,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Required';
                            if (double.tryParse(val) == null)
                              return 'Invalid number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildDarkTextField(
                          controller: _ratingController,
                          label: 'Rating (0-5)',
                          hint: 'e.g., 4.8',
                          icon: Icons.star_rate,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Required';
                            final n = double.tryParse(val);
                            if (n == null || n < 0 || n > 5)
                              return '0 - 5 only';
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 50),

                      // --- BAGIAN 3: TOMBOL SAVE ---
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
                          ),
                          onPressed: _isLoading ? null : _submitProfile,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Save Profile',
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
                            side: const BorderSide(
                              color: Colors.redAccent,
                              width: 2,
                            ),
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

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final uid = _supabaseService.getCurrentUser()?.id;
      if (uid == null) throw "User not logged in";

      final name = _nameController.text.trim();
      final bio = _bioController.text.trim();
      final phone = _phoneController.text.trim();
      final block = _blockController.text.trim();

      if (widget.isSeller) {
        // --- LOGIC SELLER ---
        final deliveryTime = _deliveryTimeController.text.trim();
        final deliveryFee = double.tryParse(_deliveryFeeController.text) ?? 0.0;
        final rating = double.tryParse(_ratingController.text) ?? 0.0;

        await _supabaseService.updateSellerProfile(
          sellerId: uid,
          displayName: name,
          block: block,
          description: bio,
          deliveryTime: deliveryTime,
          deliveryFee: deliveryFee,
          rating: rating,
          isOnline: true,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Seller profile saved!'),
              backgroundColor: Colors.green,
            ),
          );
          // Kalau Seller, arahkan ke Dashboard
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/seller-dashboard',
            (route) => false,
          );
        }
      } else {
        // --- LOGIC BUYER ---
        await _supabaseService.updateUserProfile(
          userId: uid,
          displayName: name,
          bio: bio,
          phone: phone,
          block: block,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _supabaseService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: kTextColorPrimary),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode
          .onUserInteraction, // Validasi real-time biar merahnya ilang
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kTextColorSecondary),
        hintText: hint,
        hintStyle: TextStyle(color: kTextColorSecondary.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: kAccentColor),
        filled: true,
        fillColor: kCardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
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

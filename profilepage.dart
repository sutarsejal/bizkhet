import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'my_orders_page.dart';
import 'settings_page.dart';
import 'sell_crop_form_page.dart';
import 'market_place_page.dart';
import 'book_tractor_page.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? profile;
  bool isLoading = true;
  bool isEditing = false;
  bool isSaving = false;

  // Stats
  int _ordersCount = 0;
  int _listingsCount = 0;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController locationController;
  late TextEditingController bioController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    locationController = TextEditingController();
    bioController = TextEditingController();
    fetchProfile();
    _fetchStats();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    locationController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> _fetchStats() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Fetch orders count
      final orders = await supabase
          .from('orders')
          .select('id')
          .eq('user_id', user.id);
      // Fetch listings count
      final listings = await supabase
          .from('items')
          .select('id');

      if (mounted) {
        setState(() {
          _ordersCount = (orders as List).length;
          _listingsCount = (listings as List).length;
        });
      }
    } catch (e) {
      debugPrint('Stats error: $e');
    }
  }

  Future<void> fetchProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          profile = data;
          isLoading = false;
          nameController.text =
              data?['full_name'] ?? data?['username'] ?? '';
          phoneController.text = data?['phone'] ?? '';
          locationController.text = data?['location'] ?? '';
          bioController.text = data?['bio'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showSnack('Error: $e', isError: true);
      }
    }
  }

  Future<void> saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      _showSnack('Name cannot be empty', isError: true);
      return;
    }
    setState(() => isSaving = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': nameController.text.trim(),
        'username': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'location': locationController.text.trim(),
        'bio': bioController.text.trim(),
        'email': user.email,
      });

      await fetchProfile();
      if (mounted) {
        setState(() => isEditing = false);
        _showSnack('Profile updated! ✅');
      }
    } catch (e) {
      _showSnack('Update failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _cancelEdit() {
    setState(() {
      isEditing = false;
      nameController.text =
          profile?['full_name'] ?? profile?['username'] ?? '';
      phoneController.text = profile?['phone'] ?? '';
      locationController.text = profile?['location'] ?? '';
      bioController.text = profile?['bio'] ?? '';
    });
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? Colors.red : const Color(0xFF1B8F5A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.trim()[0].toUpperCase();
  }

  String _formatDate(dynamic createdAt) {
    if (createdAt == null) return 'N/A';
    final dt = DateTime.tryParse(createdAt.toString());
    if (dt == null) return 'N/A';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  // ── NAVIGATE based on activity item ─────────────────────────
  void _onActivityTap(String label) {
    switch (label) {
      case 'My Orders':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MyOrdersPage()));
        break;
      case 'My Listings':
        Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => const MarketPlacePage()));
        break;
      case 'Sell Crop':
        Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => SellCropFormPage(cropName: '')));
        break;
      case 'Book Tractor':
        Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => const BookTractorPage()));
        break;
      case 'Settings':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SettingsPage()));
        break;
      case 'Help & Support':
        _showSupportSheet();
        break;
      case 'Wishlist':
      case 'Transaction History':
        _showComingSoon(label);
        break;
      default:
        _showComingSoon(label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    if (!isLoading && user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F4F0),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F5C35),
          foregroundColor: Colors.white,
          title: const Text('My Profile',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B8F5A)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_off_rounded,
                      size: 60, color: Color(0xFF1B8F5A)),
                ),
                const SizedBox(height: 24),
                const Text('Not Logged In',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Please login to view your profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black45, fontSize: 14)),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginPage())),
                    icon: const Icon(Icons.login_rounded,
                        color: Colors.white, size: 18),
                    label: const Text('Go to Login',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B8F5A),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF1B8F5A)))
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(user),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      _buildStatsRow(),
                      const SizedBox(height: 14),
                      _buildPersonalInfoCard(user),
                      const SizedBox(height: 14),
                      _buildAccountCard(user),
                      const SizedBox(height: 14),
                      _buildActivityCard(),
                      const SizedBox(height: 14),
                      _buildLogoutButton(),
                      const SizedBox(height: 60),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  // ── SLIVER APP BAR ───────────────────────────────────────────
  Widget _buildSliverAppBar(user) {
    final name =
        profile?['full_name'] ?? profile?['username'] ?? 'Farmer';
    final role = profile?['role'] ?? 'user';

    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: const Color(0xFF0A3D22),
      foregroundColor: Colors.white,
      actions: [
        if (isEditing) ...[
          GestureDetector(
            onTap: _cancelEdit,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Cancel',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ),
          GestureDetector(
            onTap: saveProfile,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('Save',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ]),
            ),
          ),
        ] else ...[
          GestureDetector(
            onTap: () => setState(() => isEditing = true),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_rounded,
                        color: Colors.white, size: 15),
                    SizedBox(width: 5),
                    Text('Edit',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ]),
            ),
          ),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A3D22),
                Color(0xFF0F5C35),
                Color(0xFF1B8F5A)
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Stack(children: [
                  Container(
                    width: 86, height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                          color: Colors.white, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(name),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2, right: 2,
                    child: Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(user?.email ?? '',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role == 'farmer' ? '🌾 Farmer' : '🛒 Buyer',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        title: const Text('My Profile',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        titlePadding:
            const EdgeInsets.only(left: 20, bottom: 16),
        collapseMode: CollapseMode.pin,
      ),
    );
  }

  // ── STATS ROW ────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(children: [
        // ✅ Real orders count
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => const MyOrdersPage())),
          child: _statItem('$_ordersCount', 'Orders',
              Icons.shopping_bag_rounded,
              const Color(0xFF1B8F5A)),
        ),
        _vDiv(),
        // ✅ Real listings count
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => const MarketPlacePage())),
          child: _statItem('$_listingsCount', 'Listings',
              Icons.store_rounded, const Color(0xFF2980B9)),
        ),
        _vDiv(),
        _statItem('5.0', 'Rating', Icons.star_rounded,
            const Color(0xFFE67E22)),
      ]),
    );
  }

  Widget _statItem(
          String val, String label, IconData icon, Color color) =>
      Expanded(
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 5),
          Text(val,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Colors.black38)),
        ]),
      );

  Widget _vDiv() =>
      Container(width: 1, height: 40, color: Colors.black12);

  // ── PERSONAL INFO CARD ───────────────────────────────────────
  Widget _buildPersonalInfoCard(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B8F5A)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_rounded,
                color: Color(0xFF1B8F5A), size: 18),
          ),
          const SizedBox(width: 10),
          const Text('Personal Information',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (isEditing)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Editing',
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
        ]),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),

        _buildEditableField(
          label: 'Full Name',
          value: profile?['full_name'] ??
              profile?['username'] ?? 'Not set',
          icon: Icons.badge_rounded,
          controller: nameController,
        ),
        const SizedBox(height: 16),

        _buildLockedField(
          label: 'Email Address',
          value: user?.email ?? 'Not set',
          icon: Icons.email_rounded,
        ),
        const SizedBox(height: 16),

        _buildEditableField(
          label: 'Phone Number',
          value: profile?['phone'] ?? 'Not set',
          icon: Icons.phone_rounded,
          controller: phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        _buildEditableField(
          label: 'Location / Village',
          value: profile?['location'] ?? 'Not set',
          icon: Icons.location_on_rounded,
          controller: locationController,
        ),
        const SizedBox(height: 16),

        _buildEditableField(
          label: 'About Me',
          value: profile?['bio'] ?? 'Not set',
          icon: Icons.info_rounded,
          controller: bioController,
          maxLines: isEditing ? 3 : 2,
        ),
      ]),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Text(label,
          style: const TextStyle(
              fontSize: 11,
              color: Colors.black38,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5)),
      const SizedBox(height: 6),
      isEditing
          ? TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: const TextStyle(
                  fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                prefixIcon: Icon(icon,
                    color: const Color(0xFF1B8F5A), size: 18),
                filled: true,
                fillColor: const Color(0xFFF8FAF7),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: const Color(0xFF1B8F5A)
                            .withValues(alpha: 0.3))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: const Color(0xFF1B8F5A)
                            .withValues(alpha: 0.3))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF1B8F5A), width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Icon(icon,
                    color: const Color(0xFF1B8F5A), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value.isEmpty ? 'Not set' : value,
                    style: TextStyle(
                        fontSize: 14,
                        color: value.isEmpty ||
                                value == 'Not set'
                            ? Colors.black26
                            : Colors.black87),
                  ),
                ),
              ]),
            ),
    ]);
  }

  Widget _buildLockedField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Text(label,
          style: const TextStyle(
              fontSize: 11,
              color: Colors.black38,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Row(children: [
          Icon(icon, color: Colors.black26, size: 18),
          const SizedBox(width: 10),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black45))),
          const Icon(Icons.lock_rounded,
              size: 14, color: Colors.black26),
        ]),
      ),
    ]);
  }

  // ── ACCOUNT CARD ─────────────────────────────────────────────
  Widget _buildAccountCard(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2980B9)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.security_rounded,
                color: Color(0xFF2980B9), size: 18),
          ),
          const SizedBox(width: 10),
          const Text('Account Details',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        _accountRow(Icons.calendar_today_rounded, 'Joined On',
            _formatDate(profile?['created_at']),
            const Color(0xFF1B8F5A)),
        const SizedBox(height: 14),
        _accountRow(Icons.badge_rounded, 'Account Type',
            profile?['role'] == 'farmer'
                ? '🌾 Farmer'
                : '🛒 Buyer',
            const Color(0xFF2980B9)),
        const SizedBox(height: 14),
        _accountRow(Icons.verified_rounded, 'Email Status',
            '✅ Verified', const Color(0xFF27AE60)),
        const SizedBox(height: 14),
        _accountRow(Icons.person_rounded, 'Username',
            profile?['username'] ?? 'Not set',
            const Color(0xFF8E44AD)),
      ]),
    );
  }

  Widget _accountRow(
      IconData icon, String label, String value, Color color) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Colors.black38)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ]),
      ),
    ]);
  }

  // ── ACTIVITY CARD ─────────────────────────────────────────────
  Widget _buildActivityCard() {
    final items = [
      {
        'icon': Icons.shopping_bag_rounded,
        'color': 0xFF1B8F5A,
        'label': 'My Orders',
        'subtitle': 'View purchase history',
        'badge': _ordersCount > 0 ? '$_ordersCount' : null,
        'active': true,
      },
      {
        'icon': Icons.store_rounded,
        'color': 0xFF2980B9,
        'label': 'My Listings',
        'subtitle': 'Browse marketplace',
        'badge': null,
        'active': true,
      },
      {
        'icon': Icons.spa_rounded,
        'color': 0xFF27AE60,
        'label': 'Sell Crop',
        'subtitle': 'Post your crops for sale',
        'badge': null,
        'active': true,
      },
      {
        'icon': Icons.agriculture_rounded,
        'color': 0xFF2980B9,
        'label': 'Book Tractor',
        'subtitle': 'Rent agricultural equipment',
        'badge': null,
        'active': true,
      },
      {
        'icon': Icons.favorite_rounded,
        'color': 0xFFE74C3C,
        'label': 'Wishlist',
        'subtitle': 'Your saved items',
        'badge': null,
        'active': false,
      },
      {
        'icon': Icons.history_rounded,
        'color': 0xFFE67E22,
        'label': 'Transaction History',
        'subtitle': 'All your transactions',
        'badge': null,
        'active': false,
      },
      {
        'icon': Icons.help_outline_rounded,
        'color': 0xFF8E44AD,
        'label': 'Help & Support',
        'subtitle': 'Get assistance',
        'badge': null,
        'active': true,
      },
      {
        'icon': Icons.settings_rounded,
        'color': 0xFF7F8C8D,
        'label': 'Settings',
        'subtitle': 'App preferences',
        'badge': null,
        'active': true,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8E44AD)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.grid_view_rounded,
                  color: Color(0xFF8E44AD), size: 18),
            ),
            const SizedBox(width: 10),
            const Text('My Activity',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ]),
        ),
        const Divider(height: 1),
        ...items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final color = Color(item['color'] as int);
          final isActive = item['active'] as bool;
          final badge = item['badge'] as String?;

          return Column(children: [
            InkWell(
              onTap: () =>
                  _onActivityTap(item['label'] as String),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Icon(item['icon'] as IconData,
                        color: color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                      Text(item['label'] as String,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isActive
                                  ? Colors.black87
                                  : Colors.black45)),
                      Text(item['subtitle'] as String,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black38)),
                    ]),
                  ),

                  // Badge for orders count
                  if (badge != null)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(badge,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.bold)),
                    ),

                  // Coming soon badge
                  if (!isActive)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange
                            .withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: const Text('Soon',
                          style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.bold)),
                    ),

                  Icon(Icons.chevron_right_rounded,
                      color: isActive
                          ? Colors.black38
                          : Colors.black12,
                      size: 20),
                ]),
              ),
            ),
            if (i < items.length - 1)
              const Divider(
                  height: 1, indent: 16, endIndent: 16),
          ]);
        }),
      ]),
    );
  }

  // ── SUPPORT SHEET ─────────────────────────────────────────────
  void _showSupportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8E44AD)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.headset_mic_rounded,
                color: Color(0xFF8E44AD), size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Help & Support',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          _supportRow(Icons.email_rounded, 'Email',
              'support@bizkhet.com',
              const Color(0xFF1B8F5A)),
          const SizedBox(height: 10),
          _supportRow(Icons.phone_rounded, 'Phone',
              '+91 1800-270-0224',
              const Color(0xFF2980B9)),
          const SizedBox(height: 10),
          _supportRow(Icons.access_time_rounded, 'Hours',
              'Mon-Sat, 9 AM - 6 PM',
              const Color(0xFFE67E22)),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8E44AD),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Close',
                  style: TextStyle(
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _supportRow(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: color.withValues(alpha: 0.15)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Colors.black38)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ]),
      ]),
    );
  }

  // ── COMING SOON ──────────────────────────────────────────────
  void _showComingSoon(String label) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B8F5A)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.hourglass_empty_rounded,
                color: Color(0xFF1B8F5A), size: 36),
          ),
          const SizedBox(height: 16),
          Text(label,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'This feature is coming soon!\nStay tuned for updates.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black45, fontSize: 14)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B8F5A),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('OK',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  // ── LOGOUT ───────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _confirmLogout,
        icon: const Icon(Icons.logout_rounded,
            color: Colors.white, size: 18),
        label: const Text('Logout',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }

  void _confirmLogout() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.logout_rounded,
                color: Colors.red, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Logout?',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black45)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Cancel',
                    style: TextStyle(
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await supabase.auth.signOut();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Logout',
                    style: TextStyle(
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

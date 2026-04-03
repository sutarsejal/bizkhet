import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final supabase = Supabase.instance.client;

  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _priceAlerts = true;
  bool _orderUpdates = true;
  bool _darkMode = false;
  bool _locationEnabled = true;
  bool _biometricEnabled = false;

  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'हिंदी', 'मराठी'];

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSection(
                    title: 'Account',
                    icon: Icons.person_rounded,
                    color: const Color(0xFF1B8F5A),
                    children: [
                      _buildInfoTile(
                        icon: Icons.email_rounded,
                        label: 'Email',
                        value: user?.email ?? 'Not logged in',
                        color: const Color(0xFF1B8F5A),
                      ),
                      _buildDivider(),
                      _buildActionTile(
                        icon: Icons.lock_rounded,
                        label: 'Change Password',
                        color: const Color(0xFF1B8F5A),
                        onTap: () => _showChangePasswordSheet(),
                      ),
                      _buildDivider(),
                      _buildActionTile(
                        icon: Icons.delete_forever_rounded,
                        label: 'Delete Account',
                        color: Colors.red,
                        onTap: () => _showDeleteAccountDialog(),
                        isDestructive: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _buildSection(
                    title: 'Notifications',
                    icon: Icons.notifications_rounded,
                    color: const Color(0xFF2980B9),
                    children: [
                      _buildToggleTile(
                        icon: Icons.notifications_active_rounded,
                        label: 'Push Notifications',
                        subtitle: 'Enable all notifications',
                        value: _notificationsEnabled,
                        color: const Color(0xFF2980B9),
                        onChanged: (val) =>
                            setState(() => _notificationsEnabled = val),
                      ),
                      _buildDivider(),
                      _buildToggleTile(
                        icon: Icons.email_rounded,
                        label: 'Email Notifications',
                        subtitle: 'Get updates on email',
                        value: _emailNotifications,
                        color: const Color(0xFF2980B9),
                        onChanged: (val) =>
                            setState(() => _emailNotifications = val),
                      ),
                      _buildDivider(),
                      _buildToggleTile(
                        icon: Icons.sms_rounded,
                        label: 'SMS Notifications',
                        subtitle: 'Get updates on phone',
                        value: _smsNotifications,
                        color: const Color(0xFF2980B9),
                        onChanged: (val) =>
                            setState(() => _smsNotifications = val),
                      ),
                      _buildDivider(),
                      _buildToggleTile(
                        icon: Icons.trending_up_rounded,
                        label: 'Price Alerts',
                        subtitle: 'Notify when crop prices change',
                        value: _priceAlerts,
                        color: const Color(0xFF2980B9),
                        onChanged: (val) =>
                            setState(() => _priceAlerts = val),
                      ),
                      _buildDivider(),
                      _buildToggleTile(
                        icon: Icons.shopping_bag_rounded,
                        label: 'Order Updates',
                        subtitle: 'Notify on order status change',
                        value: _orderUpdates,
                        color: const Color(0xFF2980B9),
                        onChanged: (val) =>
                            setState(() => _orderUpdates = val),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _buildSection(
                    title: 'Appearance',
                    icon: Icons.palette_rounded,
                    color: const Color(0xFF8E44AD),
                    children: [
                      _buildToggleTile(
                        icon: Icons.dark_mode_rounded,
                        label: 'Dark Mode',
                        subtitle: 'Switch to dark theme',
                        value: _darkMode,
                        color: const Color(0xFF8E44AD),
                        onChanged: (val) {
                          setState(() => _darkMode = val);
                          _showSnack('Dark mode coming soon!');
                        },
                      ),
                      _buildDivider(),
                      _buildLanguageTile(),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _buildSection(
                    title: 'Privacy & Security',
                    icon: Icons.security_rounded,
                    color: const Color(0xFFE67E22),
                    children: [
                      _buildToggleTile(
                        icon: Icons.location_on_rounded,
                        label: 'Location Access',
                        subtitle: 'For weather & nearby services',
                        value: _locationEnabled,
                        color: const Color(0xFFE67E22),
                        onChanged: (val) =>
                            setState(() => _locationEnabled = val),
                      ),
                      _buildDivider(),
                      _buildToggleTile(
                        icon: Icons.fingerprint_rounded,
                        label: 'Biometric Login',
                        subtitle: 'Use fingerprint to login',
                        value: _biometricEnabled,
                        color: const Color(0xFFE67E22),
                        onChanged: (val) {
                          setState(() => _biometricEnabled = val);
                          _showSnack('Biometric coming soon!');
                        },
                      ),
                      _buildDivider(),
                      _buildActionTile(
                        icon: Icons.privacy_tip_rounded,
                        label: 'Privacy Policy',
                        color: const Color(0xFFE67E22),
                        onTap: () => _showPolicySheet(
                          title: 'Privacy Policy',
                          content: _privacyPolicyText,
                        ),
                      ),
                      _buildDivider(),
                      _buildActionTile(
                        icon: Icons.description_rounded,
                        label: 'Terms & Conditions',
                        color: const Color(0xFFE67E22),
                        onTap: () => _showPolicySheet(
                          title: 'Terms & Conditions',
                          content: _termsText,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _buildSection(
                    title: 'Help & Support',
                    icon: Icons.help_rounded,
                    color: const Color(0xFF27AE60),
                    children: [
                      _buildActionTile(
                        icon: Icons.headset_mic_rounded,
                        label: 'Contact Support',
                        subtitle: 'We\'re here to help',
                        color: const Color(0xFF27AE60),
                        onTap: () => _showContactSheet(),
                      ),
                      _buildDivider(),
                      _buildActionTile(
                        icon: Icons.quiz_rounded,
                        label: 'FAQ',
                        subtitle: 'Frequently asked questions',
                        color: const Color(0xFF27AE60),
                        onTap: () => _showFaqSheet(),
                      ),
                      _buildDivider(),
                      _buildActionTile(
                        icon: Icons.star_rounded,
                        label: 'Rate BizKhet',
                        subtitle: 'Share your experience',
                        color: const Color(0xFF27AE60),
                        onTap: () =>
                            _showSnack('Redirecting to Play Store...'),
                      ),
                      _buildDivider(),
                      _buildActionTile(
                        icon: Icons.share_rounded,
                        label: 'Share App',
                        subtitle: 'Invite your farmer friends',
                        color: const Color(0xFF27AE60),
                        onTap: () => _showSnack('Sharing BizKhet...'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _buildSection(
                    title: 'App Info',
                    icon: Icons.info_rounded,
                    color: const Color(0xFF7F8C8D),
                    children: [
                      _buildInfoTile(
                        icon: Icons.apps_rounded,
                        label: 'App Version',
                        value: '1.0.0',
                        color: const Color(0xFF7F8C8D),
                      ),
                      _buildDivider(),
                      _buildInfoTile(
                        icon: Icons.build_rounded,
                        label: 'Build Number',
                        value: '100',
                        color: const Color(0xFF7F8C8D),
                      ),
                      _buildDivider(),
                      _buildActionTile(
                        icon: Icons.system_update_rounded,
                        label: 'Check for Updates',
                        color: const Color(0xFF7F8C8D),
                        onTap: () =>
                            _showSnack('App is up to date! ✅'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _buildLogoutButton(),

                  const SizedBox(height: 12),

                  const Text(
                    'BizKhet — Farming Is The Business 🌾',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black38, fontSize: 12),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── APP BAR ── ✅ Fixed — no double title ────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: const Color(0xFF0A3D22),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        // ✅ NO title parameter — sirf background hai
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A3D22),
                Color(0xFF0F5C35),
                Color(0xFF1B8F5A),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('BizKhet',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              letterSpacing: 1.5)),
                      SizedBox(height: 4),
                      Text('Settings',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              height: 1.1)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.settings_rounded,
                        color: Colors.white, size: 26),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── SECTION BUILDER ──────────────────────────────────────────
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ]),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  // ── TILES ────────────────────────────────────────────────────
  Widget _buildToggleTile({
    required IconData icon,
    required String label,
    String? subtitle,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
              if (subtitle != null)
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black38)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: color,
          activeTrackColor: color.withValues(alpha: 0.3),
        ),
      ]),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    String? subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? Colors.red
                            : Colors.black87)),
                if (subtitle != null)
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black38)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: Colors.black26, size: 20),
        ]),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ),
        Text(value,
            style: const TextStyle(
                fontSize: 13, color: Colors.black45)),
      ]),
    );
  }

  Widget _buildLanguageTile() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8E44AD).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.language_rounded,
              color: Color(0xFF8E44AD), size: 18),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Language',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
              Text('Select preferred language',
                  style: TextStyle(
                      fontSize: 11, color: Colors.black38)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                const Color(0xFF8E44AD).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLanguage,
              isDense: true,
              icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF8E44AD),
                  size: 18),
              style: const TextStyle(
                  color: Color(0xFF8E44AD),
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedLanguage = val);
                  _showSnack('Language changed to $val');
                }
              },
              items: _languages
                  .map((l) => DropdownMenuItem(
                      value: l, child: Text(l)))
                  .toList(),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildDivider() =>
      const Divider(height: 1, indent: 16, endIndent: 16);

  // ── LOGOUT BUTTON ────────────────────────────────────────────
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

  // ── CHANGE PASSWORD ──────────────────────────────────────────
  void _showChangePasswordSheet() {
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    bool isLoading = false;
    bool obscure1 = true;
    bool obscure2 = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Change Password',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black
                              .withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 18, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _passField(
                  controller: newPassController,
                  label: 'New Password',
                  obscure: obscure1,
                  onToggle: () =>
                      setModalState(() => obscure1 = !obscure1),
                ),
                const SizedBox(height: 14),
                _passField(
                  controller: confirmPassController,
                  label: 'Confirm Password',
                  obscure: obscure2,
                  onToggle: () =>
                      setModalState(() => obscure2 = !obscure2),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (newPassController.text !=
                                confirmPassController.text) {
                              _showSnack(
                                  'Passwords do not match!',
                                  isError: true);
                              return;
                            }
                            if (newPassController.text.length < 
                                6) {
                              _showSnack(
                                  'Min 6 characters required',
                                  isError: true);
                              return;
                            }
                            setModalState(
                                () => isLoading = true);
                            try {
                              await supabase.auth.updateUser(
                                UserAttributes(
                                    password: newPassController
                                        .text),
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                                _showSnack(
                                    'Password updated! ✅');
                              }
                            } catch (e) {
                              _showSnack('Error: $e',
                                  isError: true);
                            } finally {
                              setModalState(
                                  () => isLoading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF1B8F5A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2))
                        : const Text('Update Password',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _passField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_rounded,
            color: Color(0xFF1B8F5A), size: 18),
        suffixIcon: IconButton(
          icon: Icon(
              obscure
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: Colors.black38,
              size: 18),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAF7),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
      ),
    );
  }

  // ── DELETE ACCOUNT ───────────────────────────────────────────
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.warning_rounded, color: Colors.red, size: 24),
          SizedBox(width: 8),
          Text('Delete Account',
              style: TextStyle(fontSize: 18)),
        ]),
        content: const Text(
            'Are you sure? This action cannot be undone. All your data will be permanently deleted.',
            style: TextStyle(color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack('Contact support to delete account',
                  isError: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── LOGOUT CONFIRM ───────────────────────────────────────────
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
                    style:
                        TextStyle(fontWeight: FontWeight.bold)),
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
                    style:
                        TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  // ── CONTACT SHEET ─────────────────────────────────────────────
  void _showContactSheet() {
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
              color: const Color(0xFF27AE60)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.headset_mic_rounded,
                color: Color(0xFF27AE60), size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Contact Support',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _contactRow(Icons.email_rounded, 'Email',
              'support@bizkhet.com', const Color(0xFF27AE60)),
          const SizedBox(height: 10),
          _contactRow(Icons.phone_rounded, 'Phone',
              '+91 1800-270-0224', const Color(0xFF27AE60)),
          const SizedBox(height: 10),
          _contactRow(Icons.access_time_rounded, 'Hours',
              'Mon-Sat, 9 AM - 6 PM', const Color(0xFF27AE60)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Close',
                  style:
                      TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _contactRow(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
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

  // ── FAQ SHEET ─────────────────────────────────────────────────
  void _showFaqSheet() {
    final faqs = [
      {
        'q': 'How do I sell my crops on BizKhet?',
        'a':
            'Go to Market → Click "Sell Produce" button → Fill in crop details, price and location → Submit listing.'
      },
      {
        'q': 'How do I book a tractor?',
        'a':
            'Go to Home → Quick Actions → Book Tractor → Select tractor → Choose date & hours → Confirm booking.'
      },
      {
        'q': 'How do I track my order?',
        'a':
            'Go to Home → Menu → My Orders → Click on any order to see real-time status and timeline.'
      },
      {
        'q': 'Is my payment information safe?',
        'a':
            'Yes, BizKhet uses industry-standard encryption. We never store card details on our servers.'
      },
      {
        'q': 'How do I cancel an order?',
        'a':
            'Go to My Orders → Click on pending order → Tap "Cancel Order" button. Only pending orders can be cancelled.'
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text('FAQ',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black
                            .withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 18, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.all(16),
                itemCount: faqs.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: 10),
                itemBuilder: (_, i) => _faqCard(faqs[i]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _faqCard(Map<String, String> faq) {
    return ExpansionTile(
      tilePadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding:
          const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)),
      collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)),
      backgroundColor:
          const Color(0xFF1B8F5A).withValues(alpha: 0.05),
      collapsedBackgroundColor: const Color(0xFFF8FAF7),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color:
              const Color(0xFF1B8F5A).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.quiz_rounded,
            color: Color(0xFF1B8F5A), size: 16),
      ),
      title: Text(faq['q']!,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87)),
      children: [
        Text(faq['a']!,
            style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.5)),
      ],
    );
  }

  // ── POLICY SHEET ─────────────────────────────────────────────
  void _showPolicySheet(
      {required String title, required String content}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black
                            .withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 18, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                child: Text(content,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.8)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── SNACKBAR ─────────────────────────────────────────────────
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

  // ── POLICY TEXTS ─────────────────────────────────────────────
  final String _privacyPolicyText = '''
BizKhet Privacy Policy
Last updated: March 2026

1. Information We Collect
We collect information you provide directly to us, such as when you create an account, make a purchase, or contact us for support.

- Personal Information: Name, email address, phone number, location
- Usage Data: How you interact with our app
- Device Information: Device type, OS version, unique device identifiers

2. How We Use Your Information
- To provide and improve our services
- To process transactions
- To send notifications about orders and price alerts
- To personalize your experience

3. Data Security
We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

4. Data Sharing
We do not sell your personal information. We may share data with:
- Service providers who assist in our operations
- Law enforcement when required by law

5. Your Rights
You have the right to:
- Access your personal data
- Correct inaccurate data
- Request deletion of your data
- Opt-out of marketing communications

6. Contact Us
For privacy-related questions: privacy@bizkhet.com
''';

  final String _termsText = '''
BizKhet Terms & Conditions
Last updated: March 2026

1. Acceptance of Terms
By using BizKhet, you agree to these Terms & Conditions.

2. Use of Service
- You must be 18 years or older to use this service
- You are responsible for maintaining account security
- You must not use the service for illegal activities

3. Marketplace Rules
- Sellers must provide accurate product information
- Prices must be in Indian Rupees (₹)
- BizKhet takes no responsibility for disputes between buyers and sellers

4. Payments
- All payments are processed securely
- Refunds are subject to our refund policy
- BizKhet charges a 2% platform fee on transactions

5. Prohibited Activities
- Posting false or misleading information
- Harassment of other users
- Attempting to hack or disrupt the service

6. Limitation of Liability
BizKhet is not liable for:
- Losses due to third-party actions
- Service interruptions beyond our control
- Accuracy of market prices shown

7. Governing Law
These terms are governed by Indian law. Disputes will be resolved in courts of Maharashtra.

8. Contact
For terms-related questions: legal@bizkhet.com
''';
}

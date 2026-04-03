import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late TabController _tabController;

  int _totalUsers = 0;
  int _totalOrders = 0;
  int _totalItems = 0;
  int _totalTractors = 0;
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchStats() async {
    try {
      final users = await supabase.from('profiles').select('id');
      final orders = await supabase.from('orders').select('id');
      final items = await supabase.from('items').select('id');
      final tractors = await supabase.from('tractors').select('id');
      if (mounted) {
        setState(() {
          _totalUsers = (users as List).length;
          _totalOrders = (orders as List).length;
          _totalItems = (items as List).length;
          _totalTractors = (tractors as List).length;
          _statsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : const Color(0xFF1B8F5A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(child: _buildTabBar()),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _UsersTab(supabase: supabase, onSnack: _showSnack),
            _OrdersTab(supabase: supabase, onSnack: _showSnack),
            _ItemsTab(supabase: supabase, onSnack: _showSnack, onRefresh: _fetchStats),
            _TractorsTab(supabase: supabase, onSnack: _showSnack, onRefresh: _fetchStats),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: const Color(0xFF0A3D22),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A3D22), Color(0xFF0F5C35), Color(0xFF1B8F5A)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('BizKhet',
                          style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1.5)),
                      SizedBox(height: 4),
                      Text('Admin Panel',
                          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 26),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: _statsLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B8F5A)))
          : Row(children: [
              _statCard('$_totalUsers', 'Users', Icons.people_rounded, const Color(0xFF1B8F5A)),
              const SizedBox(width: 10),
              _statCard('$_totalOrders', 'Orders', Icons.shopping_bag_rounded, const Color(0xFF2980B9)),
              const SizedBox(width: 10),
              _statCard('$_totalItems', 'Items', Icons.store_rounded, const Color(0xFFE67E22)),
              const SizedBox(width: 10),
              _statCard('$_totalTractors', 'Tractors', Icons.agriculture_rounded, const Color(0xFF8E44AD)),
            ]),
    );
  }

  Widget _statCard(String val, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.black45)),
        ]),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF1B8F5A),
        unselectedLabelColor: Colors.black38,
        indicatorColor: const Color(0xFF1B8F5A),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        tabs: const [
          Tab(icon: Icon(Icons.people_rounded, size: 18), text: 'Users'),
          Tab(icon: Icon(Icons.shopping_bag_rounded, size: 18), text: 'Orders'),
          Tab(icon: Icon(Icons.store_rounded, size: 18), text: 'Items'),
          Tab(icon: Icon(Icons.agriculture_rounded, size: 18), text: 'Tractors'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TAB 1 — USERS
// ══════════════════════════════════════════════════════════════
class _UsersTab extends StatefulWidget {
  final SupabaseClient supabase;
  final Function(String, {bool isError}) onSnack;
  const _UsersTab({required this.supabase, required this.onSnack});

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final data = await widget.supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(data);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      widget.onSnack('Error loading users: $e', isError: true);
    }
  }

  String _formatDate(dynamic d) {
    if (d == null) return 'N/A';
    final dt = DateTime.tryParse(d.toString());
    if (dt == null) return 'N/A';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1B8F5A)));
    }
    if (_users.isEmpty) {
      return const Center(child: Text('No users found', style: TextStyle(color: Colors.black45)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (_, i) {
        final u = _users[i];
        final name = u['full_name'] ?? u['username'] ?? 'Unknown';
        final role = u['role'] ?? 'user';
        final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
        final roleColor = role == 'admin'
            ? Colors.red
            : role == 'farmer'
                ? const Color(0xFF1B8F5A)
                : const Color(0xFF2980B9);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Center(
                child: Text(initial, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: roleColor)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(u['email'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.black45)),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(role.toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: roleColor)),
                  ),
                  const SizedBox(width: 8),
                  Text('Joined: ${_formatDate(u['created_at'])}',
                      style: const TextStyle(fontSize: 10, color: Colors.black38)),
                ]),
              ]),
            ),
            if (u['location'] != null && u['location'].toString().isNotEmpty)
              Column(children: [
                const Icon(Icons.location_on_rounded, size: 14, color: Colors.black38),
                Text(
                  u['location'].toString().length > 10
                      ? '${u['location'].toString().substring(0, 10)}...'
                      : u['location'].toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.black38),
                ),
              ]),
          ]),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TAB 2 — ORDERS
// ══════════════════════════════════════════════════════════════
class _OrdersTab extends StatefulWidget {
  final SupabaseClient supabase;
  final Function(String, {bool isError}) onSnack;
  const _OrdersTab({required this.supabase, required this.onSnack});

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  String _filter = 'All';
  final filters = ['All', 'pending', 'confirmed', 'delivered', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final data = await widget.supabase
          .from('orders')
          .select()
          .order('order_date', ascending: false);
      if (mounted) {
        setState(() {
          _orders = List<Map<String, dynamic>>.from(data);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      widget.onSnack('Error loading orders: $e', isError: true);
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      await widget.supabase.from('orders').update({'status': status}).eq('id', id);
      final idx = _orders.indexWhere((o) => o['id'] == id);
      if (idx != -1 && mounted) {
        setState(() => _orders[idx] = {..._orders[idx], 'status': status});
      }
      widget.onSnack('✅ Order updated to $status');
    } catch (e) {
      widget.onSnack('Error: $e', isError: true);
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'delivered': return const Color(0xFF1B8F5A);
      case 'confirmed': return const Color(0xFF2980B9);
      case 'pending':   return const Color(0xFFE67E22);
      case 'processing':return const Color(0xFF8E44AD);
      case 'cancelled': return Colors.red;
      default:          return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1B8F5A)));
    }

    final orders = _filter == 'All'
        ? _orders
        : _orders.where((o) => o['status'] == _filter).toList();

    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((f) {
              final selected = _filter == f;
              final color = f == 'All' ? const Color(0xFF1B8F5A) : _statusColor(f);
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? color : color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    f == 'All' ? 'All' : f.toUpperCase(),
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold,
                        color: selected ? Colors.white : color),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      Expanded(
        child: orders.isEmpty
            ? const Center(child: Text('No orders found', style: TextStyle(color: Colors.black45)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (_, i) {
                  final o = orders[i];
                  final status = o['status'] ?? 'pending';
                  final color = _statusColor(status);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(children: [
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(children: [
                          Row(children: [
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(o['item_name'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('Qty: ${o['quantity']} • ₹${o['total_price']}',
                                    style: const TextStyle(color: Colors.black45, fontSize: 12)),
                              ]),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(status.toUpperCase(),
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                            ),
                          ]),
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(children: [
                              const Text('Change to: ', style: TextStyle(fontSize: 11, color: Colors.black38)),
                              ...['confirmed', 'processing', 'delivered', 'cancelled'].map((s) {
                                if (s == status) return const SizedBox();
                                final sc = _statusColor(s);
                                return GestureDetector(
                                  onTap: () => _updateStatus(o['id'], s),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: sc.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: sc.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(s, style: TextStyle(fontSize: 10, color: sc, fontWeight: FontWeight.bold)),
                                  ),
                                );
                              }),
                            ]),
                          ),
                        ]),
                      ),
                    ]),
                  );
                },
              ),
      ),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════
// TAB 3 — ITEMS
// ══════════════════════════════════════════════════════════════
class _ItemsTab extends StatefulWidget {
  final SupabaseClient supabase;
  final Function(String, {bool isError}) onSnack;
  final VoidCallback onRefresh;
  const _ItemsTab({required this.supabase, required this.onSnack, required this.onRefresh});

  @override
  State<_ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<_ItemsTab> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final data = await widget.supabase
          .from('items')
          .select()
          .order('id', ascending: false);
      if (mounted) {
        setState(() {
          _items = List<Map<String, dynamic>>.from(data);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      widget.onSnack('Error loading items: $e', isError: true);
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      await widget.supabase.from('items').delete().eq('id', id);
      if (mounted) {
        setState(() => _items.removeWhere((item) => item['id'] == id));
      }
      widget.onRefresh();
      widget.onSnack('✅ Item deleted successfully');
    } catch (e) {
      widget.onSnack('Error: $e', isError: true);
    }
  }

  void _showAddItemDialog() {
    final nameC = TextEditingController();
    final priceC = TextEditingController();
    final locationC = TextEditingController();
    String category = 'Grains';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.add_circle_rounded, color: Color(0xFF1B8F5A), size: 22),
            SizedBox(width: 8),
            Text('Add New Item', style: TextStyle(fontSize: 16)),
          ]),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _dialogField(nameC, 'Item Name', Icons.grass_rounded),
              const SizedBox(height: 10),
              _dialogField(priceC, 'Price (e.g. ₹2000/Quintal)', Icons.currency_rupee_rounded),
              const SizedBox(height: 10),
              _dialogField(locationC, 'Location', Icons.location_on_rounded),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category_rounded, color: Color(0xFF1B8F5A), size: 18),
                  filled: true,
                  fillColor: const Color(0xFFF8FAF7),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: ['Grains', 'Vegetables', 'Fruits']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setD(() => category = v!),
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.black45)),
            ),
            ElevatedButton(
              onPressed: () => _submitAddItem(ctx, nameC, priceC, locationC, category),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B8F5A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitAddItem(
    BuildContext ctx,
    TextEditingController nameC,
    TextEditingController priceC,
    TextEditingController locationC,
    String category,
  ) async {
    if (nameC.text.isEmpty || priceC.text.isEmpty || locationC.text.isEmpty) {
      widget.onSnack('Fill all fields', isError: true);
      return;
    }
    try {
      final result = await widget.supabase.from('items').insert({
        'name': nameC.text.trim(),
        'category': category,
        'price': priceC.text.trim(),
        'location': locationC.text.trim(),
        'image_url': '',
      }).select().single();
      if (ctx.mounted) Navigator.pop(ctx);
      if (mounted) {
        setState(() => _items.insert(0, Map<String, dynamic>.from(result)));
      }
      widget.onRefresh();
      widget.onSnack('✅ Item added!');
    } catch (e) {
      widget.onSnack('Error: $e', isError: true);
    }
  }

  void _confirmDelete(BuildContext context, String name, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Item?'),
        content: Text('Delete "$name" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController c, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1B8F5A), size: 18),
        filled: true,
        fillColor: const Color(0xFFF8FAF7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Color _catColor(String? cat) {
    if (cat == 'Vegetables') return const Color(0xFF27AE60);
    if (cat == 'Fruits') return const Color(0xFFE74C3C);
    return const Color(0xFFE67E22);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F4F0),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1B8F5A))),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        backgroundColor: const Color(0xFF1B8F5A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _items.isEmpty
          ? const Center(child: Text('No items found', style: TextStyle(color: Colors.black45)))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
                final color = _catColor(item['category']);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.grass_rounded, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                        const SizedBox(height: 2),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(item['category'] ?? '',
                                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Text(item['price'] ?? '',
                              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
                        ]),
                        Text(item['location'] ?? '',
                            style: const TextStyle(fontSize: 11, color: Colors.black38)),
                      ]),
                    ),
                    GestureDetector(
                      onTap: () => _confirmDelete(context, item['name'], item['id']),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.delete_rounded, color: Colors.red, size: 18),
                      ),
                    ),
                  ]),
                );
              },
            ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TAB 4 — TRACTORS
// ══════════════════════════════════════════════════════════════
class _TractorsTab extends StatefulWidget {
  final SupabaseClient supabase;
  final Function(String, {bool isError}) onSnack;
  final VoidCallback onRefresh;
  const _TractorsTab({required this.supabase, required this.onSnack, required this.onRefresh});

  @override
  State<_TractorsTab> createState() => _TractorsTabState();
}

class _TractorsTabState extends State<_TractorsTab> {
  List<Map<String, dynamic>> _tractors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTractors();
  }

  Future<void> _loadTractors() async {
    try {
      final data = await widget.supabase
          .from('tractors')
          .select()
          .order('id', ascending: false);
      if (mounted) {
        setState(() {
          _tractors = List<Map<String, dynamic>>.from(data);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      widget.onSnack('Error loading tractors: $e', isError: true);
    }
  }

  Future<void> _deleteTractor(int id) async {
    try {
      await widget.supabase.from('tractors').delete().eq('id', id);
      if (mounted) {
        setState(() => _tractors.removeWhere((t) => t['id'] == id));
      }
      widget.onRefresh();
      widget.onSnack('✅ Tractor deleted');
    } catch (e) {
      widget.onSnack('Error: $e', isError: true);
    }
  }

  Future<void> _toggleAvailability(int id, bool current) async {
    try {
      await widget.supabase.from('tractors').update({'available': !current}).eq('id', id);
      final idx = _tractors.indexWhere((t) => t['id'] == id);
      if (idx != -1 && mounted) {
        setState(() => _tractors[idx] = {..._tractors[idx], 'available': !current});
      }
      widget.onSnack('✅ Tractor marked as ${!current ? "Available" : "Unavailable"}');
    } catch (e) {
      widget.onSnack('Error: $e', isError: true);
    }
  }

  void _showAddTractorDialog() {
    final nameC = TextEditingController();
    final ownerC = TextEditingController();
    final priceC = TextEditingController();
    final locationC = TextEditingController();
    final capacityC = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.agriculture_rounded, color: Color(0xFF8E44AD), size: 22),
          SizedBox(width: 8),
          Text('Add Tractor', style: TextStyle(fontSize: 16)),
        ]),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _dialogField(nameC, 'Tractor Name', Icons.agriculture_rounded),
            const SizedBox(height: 10),
            _dialogField(ownerC, 'Owner Name', Icons.person_rounded),
            const SizedBox(height: 10),
            _dialogField(priceC, 'Price per Hour (₹)', Icons.currency_rupee_rounded,
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _dialogField(locationC, 'Location', Icons.location_on_rounded),
            const SizedBox(height: 10),
            _dialogField(capacityC, 'Capacity (e.g. 50 HP)', Icons.speed_rounded),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black45)),
          ),
          ElevatedButton(
            onPressed: () => _submitAddTractor(context, nameC, ownerC, priceC, locationC, capacityC),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8E44AD),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Add Tractor', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAddTractor(
    BuildContext ctx,
    TextEditingController nameC,
    TextEditingController ownerC,
    TextEditingController priceC,
    TextEditingController locationC,
    TextEditingController capacityC,
  ) async {
    if (nameC.text.isEmpty || ownerC.text.isEmpty || priceC.text.isEmpty || locationC.text.isEmpty) {
      widget.onSnack('Fill all fields', isError: true);
      return;
    }
    try {
      final result = await widget.supabase.from('tractors').insert({
        'name': nameC.text.trim(),
        'owner': ownerC.text.trim(),
        'price': int.tryParse(priceC.text) ?? 0,
        'location': locationC.text.trim(),
        'capacity': capacityC.text.trim(),
        'available': true,
        'fuel_type': 'Diesel',
        'image_url': '',
      }).select().single();
      if (ctx.mounted) Navigator.pop(ctx);
      if (mounted) {
        setState(() => _tractors.insert(0, Map<String, dynamic>.from(result)));
      }
      widget.onRefresh();
      widget.onSnack('✅ Tractor added!');
    } catch (e) {
      widget.onSnack('Error: $e', isError: true);
    }
  }

  void _confirmDeleteTractor(BuildContext context, String name, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Tractor?'),
        content: Text('Delete "$name" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTractor(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController c, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF8E44AD), size: 18),
        filled: true,
        fillColor: const Color(0xFFF8FAF7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F4F0),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF8E44AD))),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTractorDialog,
        backgroundColor: const Color(0xFF8E44AD),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Tractor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _tractors.isEmpty
          ? const Center(child: Text('No tractors found', style: TextStyle(color: Colors.black45)))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: _tractors.length,
              itemBuilder: (_, i) {
                final t = _tractors[i];
                final available = t['available'] == true;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(children: [
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: available ? const Color(0xFF1B8F5A) : Colors.red,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(children: [
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8E44AD).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.agriculture_rounded, color: Color(0xFF8E44AD), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(t['name'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                            const SizedBox(height: 2),
                            Text('${t['owner']} • ₹${t['price']}/hr',
                                style: const TextStyle(fontSize: 12, color: Colors.black45)),
                            Text('${t['location']} • ${t['capacity'] ?? ''}',
                                style: const TextStyle(fontSize: 11, color: Colors.black38)),
                          ]),
                        ),
                        Column(children: [
                          GestureDetector(
                            onTap: () => _toggleAvailability(t['id'], available),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: available
                                    ? const Color(0xFF1B8F5A).withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                available ? 'Available' : 'Unavailable',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: available ? const Color(0xFF1B8F5A) : Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => _confirmDeleteTractor(context, t['name'], t['id']),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.delete_rounded, color: Colors.red, size: 16),
                            ),
                          ),
                        ]),
                      ]),
                    ),
                  ]),
                );
              },
            ),
    );
  }
}

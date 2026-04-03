import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final supabase = Supabase.instance.client;
  int _selectedTab = 0;
  final tabs = ['All', 'Pending', 'Confirmed', 'Delivered', 'Cancelled'];

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    var query = supabase
        .from('orders')
        .select()
        .eq('user_id', user.id)
        .order('order_date', ascending: false);

    final data = await query;
    return List<Map<String, dynamic>>.from(data);
  }

  List<Map<String, dynamic>> _filterOrders(
      List<Map<String, dynamic>> orders) {
    if (_selectedTab == 0) return orders;
    final statusMap = {
      1: 'pending',
      2: 'confirmed',
      3: 'delivered',
      4: 'cancelled',
    };
    return orders
        .where((o) => o['status'] == statusMap[_selectedTab])
        .toList();
  }

  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = fetchOrders();
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final dt = DateTime.tryParse(date.toString());
    if (dt == null) return 'N/A';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  // Status config
  Map<String, dynamic> _statusConfig(String status) {
    switch (status) {
      case 'delivered':
        return {
          'color': 0xFF1B8F5A,
          'bg': 0xFFE8F5E9,
          'icon': Icons.check_circle_rounded,
          'label': 'Delivered'
        };
      case 'confirmed':
        return {
          'color': 0xFF2980B9,
          'bg': 0xFFE3F2FD,
          'icon': Icons.verified_rounded,
          'label': 'Confirmed'
        };
      case 'pending':
        return {
          'color': 0xFFE67E22,
          'bg': 0xFFFFF3E0,
          'icon': Icons.hourglass_empty_rounded,
          'label': 'Pending'
        };
      case 'processing':
        return {
          'color': 0xFF8E44AD,
          'bg': 0xFFF3E5F5,
          'icon': Icons.sync_rounded,
          'label': 'Processing'
        };
      case 'cancelled':
        return {
          'color': 0xFFE74C3C,
          'bg': 0xFFFFEBEE,
          'icon': Icons.cancel_rounded,
          'label': 'Cancelled'
        };
      default:
        return {
          'color': 0xFF7F8C8D,
          'bg': 0xFFF5F5F5,
          'icon': Icons.info_rounded,
          'label': status
        };
    }
  }

  // Item type icon
  IconData _typeIcon(String? type) {
    switch (type) {
      case 'tractor': return Icons.agriculture_rounded;
      case 'fertilizer': return Icons.science_rounded;
      case 'livestock': return Icons.pets_rounded;
      default: return Icons.grass_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F4F0),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F5C35),
          foregroundColor: Colors.white,
          title: const Text('My Orders',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B8F5A).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_bag_outlined,
                    size: 60, color: Color(0xFF1B8F5A)),
              ),
              const SizedBox(height: 20),
              const Text('Not Logged In',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Please login to view your orders',
                  style: TextStyle(color: Colors.black45)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginPage())),
                icon: const Icon(Icons.login_rounded,
                    color: Colors.white),
                label: const Text('Login',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B8F5A),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(snapshot.data ?? []),
              SliverToBoxAdapter(
                child: _buildTabBar(),
              ),
              if (snapshot.connectionState ==
                  ConnectionState.waiting)
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF1B8F5A)),
                    ),
                  ),
                )
              else if (snapshot.hasError)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Error: ${snapshot.error}',
                          style:
                              const TextStyle(color: Colors.red)),
                    ),
                  ),
                )
              else
                _buildOrdersList(snapshot.data ?? []),
            ],
          );
        },
      ),
    );
  }

  // ── APP BAR ──────────────────────────────────────────────────
  Widget _buildAppBar(List<Map<String, dynamic>> orders) {
    final totalSpent = orders
        .where((o) => o['status'] != 'cancelled')
        .fold<int>(
            0, (sum, o) => sum + (o['total_price'] as int? ?? 0));

    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: const Color(0xFF0A3D22),
      foregroundColor: Colors.white,
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text('BizKhet',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  letterSpacing: 1.5)),
                          Text('My Orders',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: const Icon(
                            Icons.shopping_bag_rounded,
                            color: Colors.white,
                            size: 26),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    _badge(Icons.receipt_long_rounded,
                        '${orders.length} Orders'),
                    const SizedBox(width: 8),
                    _badge(Icons.currency_rupee_rounded,
                        '₹$totalSpent Spent'),
                  ]),
                ],
              ),
            ),
          ),
        ),
        title: const Text('My Orders',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  Widget _badge(IconData icon, String label) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11)),
        ]),
      );

  // ── TAB BAR ──────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.asMap().entries.map((e) {
            final selected = _selectedTab == e.key;
            return GestureDetector(
              onTap: () => setState(() => _selectedTab = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF1B8F5A)
                      : const Color(0xFFF2F4F0),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                              color: const Color(0xFF1B8F5A)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ]
                      : [],
                ),
                child: Text(e.value,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : Colors.black54)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── ORDERS LIST ──────────────────────────────────────────────
  Widget _buildOrdersList(List<Map<String, dynamic>> allOrders) {
    final orders = _filterOrders(allOrders);

    if (orders.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox_rounded,
                    size: 64, color: Colors.black26),
                const SizedBox(height: 12),
                Text(
                  _selectedTab == 0
                      ? 'No orders yet'
                      : 'No ${tabs[_selectedTab].toLowerCase()} orders',
                  style: const TextStyle(
                      color: Colors.black45, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildOrderCard(orders[index]),
          childCount: orders.length,
        ),
      ),
    );
  }

  // ── ORDER CARD ───────────────────────────────────────────────
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] ?? 'pending';
    final config = _statusConfig(status);
    final color = Color(config['color'] as int);
    final bg = Color(config['bg'] as int);

    return GestureDetector(
      onTap: () => _showOrderDetail(order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(children: [
          // Top color strip
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              Row(children: [
                // Type icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_typeIcon(order['item_type']),
                      color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(order['item_name'] ?? '',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(Icons.person_rounded,
                            size: 12, color: Colors.black38),
                        const SizedBox(width: 4),
                        Text(order['seller_name'] ?? '',
                            style: const TextStyle(
                                color: Colors.black45,
                                fontSize: 12)),
                      ]),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    Icon(config['icon'] as IconData,
                        color: color, size: 13),
                    const SizedBox(width: 4),
                    Text(config['label'] as String,
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ]),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Bottom row
              Row(children: [
                // Date
                Row(children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 12, color: Colors.black38),
                  const SizedBox(width: 4),
                  Text(_formatDate(order['order_date']),
                      style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 12)),
                ]),
                const Spacer(),
                // Quantity
                Text(
                    'Qty: ${order['quantity']}  •  ',
                    style: const TextStyle(
                        color: Colors.black45, fontSize: 12)),
                // Total
                Text('₹${order['total_price']}',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── ORDER DETAIL SHEET ───────────────────────────────────────
  void _showOrderDetail(Map<String, dynamic> order) {
    final status = order['status'] ?? 'pending';
    final config = _statusConfig(status);
    final color = Color(config['color'] as int);
    final bg = Color(config['bg'] as int);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
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
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                  // Header
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(16)),
                      child: Icon(
                          _typeIcon(order['item_type']),
                          color: color,
                          size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                        Text(order['item_name'] ?? '',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            Icon(config['icon'] as IconData,
                                color: color, size: 13),
                            const SizedBox(width: 4),
                            Text(config['label'] as String,
                                style: TextStyle(
                                    color: color,
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.bold)),
                          ]),
                        ),
                      ]),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Order details card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAF7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(children: [
                      _detailRow(Icons.tag_rounded, 'Order ID',
                          '#${order['id']}'),
                      const Divider(height: 16),
                      _detailRow(
                          Icons.calendar_today_rounded,
                          'Order Date',
                          _formatDate(order['order_date'])),
                      const Divider(height: 16),
                      _detailRow(
                          Icons.person_rounded,
                          'Seller',
                          order['seller_name'] ?? 'N/A'),
                      const Divider(height: 16),
                      _detailRow(
                          Icons.location_on_rounded,
                          'Location',
                          order['location'] ?? 'N/A'),
                      const Divider(height: 16),
                      _detailRow(
                          Icons.inventory_2_rounded,
                          'Quantity',
                          '${order['quantity']} units'),
                      const Divider(height: 16),
                      _detailRow(
                          Icons.currency_rupee_rounded,
                          'Price per unit',
                          '₹${order['price']}'),
                    ]),
                  ),

                  const SizedBox(height: 14),

                  // Total price card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.08),
                          color.withValues(alpha: 0.03),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: color.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text('₹${order['total_price']}',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: color)),
                      ],
                    ),
                  ),

                  // Order tracking
                  if (status != 'cancelled') ...[
                    const SizedBox(height: 20),
                    const Text('Order Timeline',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    _buildTimeline(status),
                  ],

                  const SizedBox(height: 20),

                  // Action buttons
                  if (status == 'pending') ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _cancelOrder(order['id']),
                        icon: const Icon(Icons.cancel_rounded,
                            color: Colors.red, size: 18),
                        label: const Text('Cancel Order',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Colors.red),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ] else if (status == 'delivered') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: const Text(
                                  '⭐ Review feature coming soon!'),
                              backgroundColor:
                                  const Color(0xFF1B8F5A),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                          );
                        },
                        icon: const Icon(Icons.star_rounded,
                            color: Colors.white, size: 18),
                        label: const Text('Write a Review',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF1B8F5A),
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
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) =>
      Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.black45),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
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
        ),
      ]);

  // ── ORDER TIMELINE ───────────────────────────────────────────
  Widget _buildTimeline(String status) {
    final steps = [
      {'label': 'Order Placed', 'icon': Icons.shopping_bag_rounded},
      {'label': 'Confirmed', 'icon': Icons.verified_rounded},
      {'label': 'Processing', 'icon': Icons.sync_rounded},
      {'label': 'Delivered', 'icon': Icons.check_circle_rounded},
    ];

    final stepIndex = {
      'pending': 0,
      'confirmed': 1,
      'processing': 2,
      'delivered': 3,
    }[status] ?? 0;

    return Row(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final done = i <= stepIndex;
        final active = i == stepIndex;

        return Expanded(
          child: Row(children: [
            Column(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: active ? 36 : 30,
                height: active ? 36 : 30,
                decoration: BoxDecoration(
                  color: done
                      ? const Color(0xFF1B8F5A)
                      : Colors.black12,
                  shape: BoxShape.circle,
                  boxShadow: active
                      ? [
                          BoxShadow(
                              color: const Color(0xFF1B8F5A)
                                  .withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ]
                      : [],
                ),
                child: Icon(step['icon'] as IconData,
                    color: done ? Colors.white : Colors.black26,
                    size: active ? 18 : 14),
              ),
              const SizedBox(height: 4),
              Text(step['label'] as String,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: active
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: done
                          ? const Color(0xFF1B8F5A)
                          : Colors.black38),
                  textAlign: TextAlign.center),
            ]),
            if (i < steps.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  color: i < stepIndex
                      ? const Color(0xFF1B8F5A)
                      : Colors.black12,
                ),
              ),
          ]),
        );
      }).toList(),
    );
  }

  // ── CANCEL ORDER ─────────────────────────────────────────────
  Future<void> _cancelOrder(int orderId) async {
    Navigator.pop(context);
    try {
      await supabase
          .from('orders')
          .update({'status': 'cancelled'})
          .eq('id', orderId);

      setState(() => _ordersFuture = fetchOrders());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order cancelled successfully'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}

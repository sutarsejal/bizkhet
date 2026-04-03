import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sell_crop_form_page.dart';

class MarketPlacePage extends StatefulWidget {
  const MarketPlacePage({super.key});

  @override
  State<MarketPlacePage> createState() => _MarketPlacePageState();
}

class _MarketPlacePageState extends State<MarketPlacePage> {
  int selectedCategory = 0;
  final categories = ["All", "Grains", "Vegetables", "Fruits"];
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final categoryIcons = [
    Icons.apps_rounded,
    Icons.grass_rounded,
    Icons.eco_rounded,
    Icons.apple_rounded,
  ];

  final categoryColors = [
    Color(0xFF1B8F5A),
    Color(0xFFE67E22),
    Color(0xFF27AE60),
    Color(0xFFE74C3C),
  ];

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      var query = supabase.from('items').select('*');
      if (selectedCategory != 0) {
        query = query.eq('category', categories[selectedCategory]);
      }
      final data = await query;
      final allProducts = List<Map<String, dynamic>>.from(data);
      if (_searchQuery.isEmpty) return allProducts;
      return allProducts.where((item) {
        final name = item['name']?.toString().toLowerCase() ?? '';
        final category = item['category']?.toString().toLowerCase() ?? '';
        final location = item['location']?.toString().toLowerCase() ?? '';
        final q = _searchQuery.toLowerCase();
        return name.contains(q) || category.contains(q) || location.contains(q);
      }).toList();
    } catch (e) {
      debugPrint('ERROR: $e');
      return [];
    }
  }

  late Future<List<Map<String, dynamic>>> productsFuture;

  @override
  void initState() {
    super.initState();
    productsFuture = fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();
      productsFuture = fetchProducts();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      productsFuture = fetchProducts();
    });
  }

  // ✅ BUY NOW BOTTOM SHEET
  void _showBuySheet(Map<String, dynamic> item, Color accentColor) {
    int quantity = 1;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          final price = int.tryParse(
                item['price']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
          final total = price * quantity;

          return Container(
            margin: const EdgeInsets.all(12),
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item['image_url'] != null &&
                            item['image_url'].toString().isNotEmpty
                        ? Image.network(
                            item['image_url'].toString(),
                            height: 60, width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              height: 60, width: 60,
                              color: accentColor.withValues(alpha: 0.1),
                              child: Icon(Icons.grass_rounded,
                                  color: accentColor, size: 28),
                            ),
                          )
                        : Container(
                            height: 60, width: 60,
                            color: accentColor.withValues(alpha: 0.1),
                            child: Icon(Icons.grass_rounded,
                                color: accentColor, size: 28),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name']?.toString() ?? '',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 3),
                        Row(children: [
                          const Icon(Icons.location_on_rounded,
                              size: 12, color: Colors.black38),
                          const SizedBox(width: 3),
                          Text(item['location']?.toString() ?? '',
                              style: const TextStyle(
                                  color: Colors.black45, fontSize: 12)),
                        ]),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 18, color: Colors.black54),
                    ),
                  ),
                ]),

                const SizedBox(height: 20),

                // Price per unit
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: accentColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Price per unit',
                          style: TextStyle(
                              color: Colors.black54, fontSize: 14)),
                      Text(item['price']?.toString() ?? '',
                          style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Quantity selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Quantity',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: accentColor.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        GestureDetector(
                          onTap: () {
                            if (quantity > 1) {
                              setSheetState(() => quantity--);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Icon(Icons.remove_rounded,
                                color: accentColor, size: 20),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          color: accentColor.withValues(alpha: 0.08),
                          child: Text('$quantity',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: accentColor)),
                        ),
                        GestureDetector(
                          onTap: () => setSheetState(() => quantity++),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Icon(Icons.add_rounded,
                                color: accentColor, size: 20),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Features
                ...[
                  [Icons.verified_rounded, 'Quality verified by BizKhet'],
                  [Icons.local_shipping_rounded, 'Home delivery available'],
                  [Icons.security_rounded, 'Secure payment guaranteed'],
                ].map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(f[0] as IconData,
                          color: accentColor, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Text(f[1] as String,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54)),
                  ]),
                )),

                const SizedBox(height: 16),

                // Total + Buy button
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(
                        price > 0
                            ? '₹$total'
                            : item['price']?.toString() ?? '',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: accentColor),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      // ✅ Save order to Supabase
                      final user = supabase.auth.currentUser;
                      if (user != null) {
                        try {
                          await supabase.from('orders').insert({
                            'user_id': user.id,
                            'item_name': item['name'],
                            'item_type': 'product',
                            'quantity': quantity,
                            'price': price,
                            'total_price': price > 0 ? total : 0,
                            'status': 'pending',
                            'seller_name': 'BizKhet Market',
                            'location': item['location'] ?? '',
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '✅ Order placed for ${item['name']}!'),
                                backgroundColor: accentColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error placing order: $e'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                            );
                          }
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  '⚠️ Please login to place order'),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.shopping_cart_rounded,
                        color: Colors.white, size: 18),
                    label: Text(
                      'Confirm Order — ${price > 0 ? '₹$total' : item['price']?.toString() ?? ''}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F0),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildCategorySection()),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF1B8F5A)),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)),
                  );
                }

                final products = snapshot.data ?? [];

                if (products.isEmpty) {
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded,
                              size: 64, color: Colors.black26),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No products found'
                                : 'No results for "$_searchQuery"',
                            style: const TextStyle(
                                color: Colors.black45, fontSize: 16),
                          ),
                          if (_searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _clearSearch,
                              child: const Text('Clear Search',
                                  style: TextStyle(
                                      color: Color(0xFF1B8F5A))),
                            ),
                          ]
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Text('${products.length} Products',
                                style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            if (_searchQuery.isNotEmpty) ...[
                              const Text(' for ',
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13)),
                              Text('"$_searchQuery"',
                                  style: const TextStyle(
                                      color: Color(0xFF1B8F5A),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ]
                          ],
                        ),
                      ),
                      ...products.map((p) => _buildProductCard(p)),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // ✅ Sell Produce FAB — SellCropFormPage opens
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SellCropFormPage(cropName: ''),
            ),
          );
        },
        backgroundColor: const Color(0xFF1B8F5A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Sell Produce',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ── SLIVER APP BAR ──────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1B8F5A),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F6E41),
                Color(0xFF1B8F5A),
                Color(0xFF27AE60)
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('BizKhet Market',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5)),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Fresh directly from farmers',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
        title: const Text('Marketplace',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        collapseMode: CollapseMode.pin,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8)
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search crops, grains, location...',
              hintStyle:
                  const TextStyle(color: Colors.black38, fontSize: 14),
              prefixIcon: const Icon(Icons.search,
                  color: Colors.black38, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.black38, size: 18),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 16),
            ),
          ),
        ),
      ),
    );
  }

  // ── CATEGORY CHIPS ───────────────────────────────────────────
  Widget _buildCategorySection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Categories',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              categories.length,
              (i) => Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = i;
                      productsFuture = fetchProducts();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selectedCategory == i
                          ? categoryColors[i]
                          : const Color(0xFFF4F6F0),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: selectedCategory == i
                          ? [
                              BoxShadow(
                                color: categoryColors[i]
                                    .withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        Icon(categoryIcons[i],
                            color: selectedCategory == i
                                ? Colors.white
                                : Colors.black54,
                            size: 22),
                        const SizedBox(height: 4),
                        Text(categories[i],
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: selectedCategory == i
                                    ? Colors.white
                                    : Colors.black54)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PRODUCT CARD ─────────────────────────────────────────────
  Widget _buildProductCard(Map<String, dynamic> item) {
    final category = item['category']?.toString() ?? '';
    Color accentColor = const Color(0xFF1B8F5A);
    if (category == 'Grains') accentColor = const Color(0xFFE67E22);
    if (category == 'Vegetables') accentColor = const Color(0xFF27AE60);
    if (category == 'Fruits') accentColor = const Color(0xFFE74C3C);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              bottomLeft: Radius.circular(18),
            ),
            child: item['image_url'] != null &&
                    item['image_url'].toString().isNotEmpty
                ? Image.network(
                    item['image_url'].toString(),
                    height: 110,
                    width: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _placeholderImage(accentColor),
                  )
                : _placeholderImage(accentColor),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(category,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                            letterSpacing: 0.5)),
                  ),
                  const SizedBox(height: 6),

                  // Product name
                  Text(item['name']?.toString() ?? '',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 4),

                  // Location
                  Row(children: [
                    const Icon(Icons.location_on_rounded,
                        size: 12, color: Colors.black38),
                    const SizedBox(width: 3),
                    Text(item['location']?.toString() ?? '',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black45)),
                  ]),
                  const SizedBox(height: 10),

                  // Price + Buy Now button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['price']?.toString() ?? '',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: accentColor)),

                      // ✅ BUY NOW — Opens bottom sheet
                      GestureDetector(
                        onTap: () => _showBuySheet(item, accentColor),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text('Buy Now',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage(Color color) {
    return Container(
      height: 110,
      width: 110,
      color: color.withValues(alpha: 0.1),
      child: Icon(Icons.grass_rounded, color: color, size: 36),
    );
  }
}

import 'package:flutter/material.dart';

class LivestockPage extends StatefulWidget {
  const LivestockPage({super.key});

  @override
  State<LivestockPage> createState() => _LivestockPageState();
}

class _LivestockPageState extends State<LivestockPage> {
  int _selectedCategory = 0;
  final categories = ['All', 'Cattle', 'Small Animals', 'Poultry'];

  final List<Map<String, dynamic>> livestockData = [
    {
      'name': 'Gir Cow',
      'breed': 'Gir (Desi)',
      'category': 'Cattle',
      'price': '₹50,000',
      'priceNum': 50000,
      'age': '3 yrs',
      'weight': '350 kg',
      'milk': '12 L/day',
      'rating': 4.8,
      'location': 'Gujarat',
      'tag': 'Best Seller',
      'tagColor': 0xFF1B8F5A,
      'color': 0xFF1B8F5A,
      'image': 'https://girorganic.com/cdn/shop/articles/what-is-gir-cow-453725.jpg?v=1673547600',
    },
    {
      'name': 'Murrah Buffalo',
      'breed': 'Murrah',
      'category': 'Cattle',
      'price': '₹60,000',
      'priceNum': 60000,
      'age': '4 yrs',
      'weight': '450 kg',
      'milk': '18 L/day',
      'rating': 4.9,
      'location': 'Haryana',
      'tag': 'High Yield',
      'tagColor': 0xFF2980B9,
      'color': 0xFF2980B9,
      'image': 'https://cpimg.tistatic.com/6271764/b/1/murrah-black-buffalo.jpg',
    },
    {
      'name': 'Barbari Goat',
      'breed': 'Barbari',
      'category': 'Small Animals',
      'price': '₹12,000',
      'priceNum': 12000,
      'age': '1.5 yrs',
      'weight': '28 kg',
      'milk': '2 L/day',
      'rating': 4.5,
      'location': 'Uttar Pradesh',
      'tag': 'Popular',
      'tagColor': 0xFFE67E22,
      'color': 0xFFE67E22,
      'image': 'https://mannapro.com/cdn/shop/articles/dairy-goats-1_2x_49a19023-b661-41ef-8796-8e044e5dfb46.jpg?v=1740003408',
    },
    {
      'name': 'Deccani Sheep',
      'breed': 'Deccani',
      'category': 'Small Animals',
      'price': '₹10,000',
      'priceNum': 10000,
      'age': '2 yrs',
      'weight': '35 kg',
      'milk': '1 L/day',
      'rating': 4.3,
      'location': 'Maharashtra',
      'tag': 'Value Buy',
      'tagColor': 0xFF8E44AD,
      'color': 0xFF8E44AD,
      'image': 'https://static.wixstatic.com/media/nsplsh_fd7f216c819d4c77b39930440473c219~mv2.jpg/v1/fill/w_1000,h_563,al_c,q_85,usm_0.66_1.00_0.01/nsplsh_fd7f216c819d4c77b39930440473c219~mv2.jpg',
    },
    {
      'name': 'Kadaknath Hen',
      'breed': 'Kadaknath',
      'category': 'Poultry',
      'price': '₹800',
      'priceNum': 800,
      'age': '6 months',
      'weight': '2 kg',
      'milk': '200 eggs/yr',
      'rating': 4.6,
      'location': 'Madhya Pradesh',
      'tag': 'Premium',
      'tagColor': 0xFFD35400,
      'color': 0xFFD35400,
      'image': 'https://ik.imagekit.io/iwcam3r8ka/prod/blog-header/202508/e0a25fe5-60dc-407f-aea7-68c74862e4ae.jpg',
    },
    {
      'name': 'Sahiwal Cow',
      'breed': 'Sahiwal',
      'category': 'Cattle',
      'price': '₹65,000',
      'priceNum': 65000,
      'age': '5 yrs',
      'weight': '400 kg',
      'milk': '15 L/day',
      'rating': 4.7,
      'location': 'Punjab',
      'tag': 'Top Rated',
      'tagColor': 0xFF27AE60,
      'color': 0xFF27AE60,
      'image': 'https://cdn.shopify.com/s/files/1/0299/3163/4781/files/Sahiwal_Cow__Identification_Milk_Yield_and_Profit_Potential_in_Dairy_Farming2.jpg?v=1751440846',
    },
  ];

  List<Map<String, dynamic>> get filteredData {
    if (_selectedCategory == 0) return livestockData;
    return livestockData
        .where((item) => item['category'] == categories[_selectedCategory])
        .toList();
  }

  void _openDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LivestockDetailPage(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(child: _buildCategoryFilter()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildLivestockCard(filteredData[index]),
                childCount: filteredData.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSellDialog(),
        backgroundColor: const Color(0xFF1B8F5A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Sell Animal',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ── APP BAR ──────────────────────────────────────────────────
  Widget _buildAppBar() {
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
              colors: [Color(0xFF0A3D22), Color(0xFF0F5C35), Color(0xFF1B8F5A)],
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
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BizKhet',
                              style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1.5)),
                          Text('Livestock',
                              style: TextStyle(color: Colors.white, fontSize: 30,
                                  fontWeight: FontWeight.bold, height: 1.1)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.pets_rounded, color: Colors.white, size: 26),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _badge(Icons.verified_rounded, 'Verified Sellers'),
                      const SizedBox(width: 8),
                      _badge(Icons.health_and_safety_rounded, 'Health Checked'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        title: const Text('Livestock',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  Widget _badge(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: Colors.white70, size: 12),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ]),
  );

  // ── STATS ROW ────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _stat('${livestockData.length}+', 'Animals', Icons.pets_rounded),
          _vDiv(),
          _stat('4.6★', 'Avg Rating', Icons.star_rounded),
          _vDiv(),
          _stat('3 States', 'Available', Icons.location_on_rounded),
        ],
      ),
    );
  }

  Widget _stat(String val, String label, IconData icon) => Expanded(
    child: Column(children: [
      Icon(icon, color: const Color(0xFF1B8F5A), size: 18),
      const SizedBox(height: 4),
      Text(val, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.black38)),
    ]),
  );

  Widget _vDiv() => Container(width: 1, height: 36, color: Colors.black12);

  // ── CATEGORY FILTER ──────────────────────────────────────────
  Widget _buildCategoryFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: List.generate(categories.length, (i) {
              final selected = _selectedCategory == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF1B8F5A) : const Color(0xFFF2F4F0),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: selected
                          ? [BoxShadow(color: const Color(0xFF1B8F5A).withValues(alpha: 0.3),
                              blurRadius: 8, offset: const Offset(0, 3))]
                          : [],
                    ),
                    child: Text(categories[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : Colors.black45,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── LIVESTOCK CARD ───────────────────────────────────────────
  Widget _buildLivestockCard(Map<String, dynamic> item) {
    final color = Color(item['color'] as int);
    final tagColor = Color(item['tagColor'] as int);

    return GestureDetector(
      onTap: () => _openDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 14, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            // Image banner with overlays
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Image.network(
                    item['image'],
                    width: double.infinity,
                    height: 170,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 170,
                      color: color.withValues(alpha: 0.1),
                      child: Icon(Icons.pets_rounded, size: 60, color: color.withValues(alpha: 0.3)),
                    ),
                  ),
                  // Tag badge
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: tagColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(item['tag'],
                          style: const TextStyle(color: Colors.white,
                              fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  // Price badge
                  Positioned(
                    top: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(item['price'],
                          style: const TextStyle(color: Colors.white,
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  // Rating
                  Positioned(
                    bottom: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 14),
                        const SizedBox(width: 3),
                        Text('${item['rating']}',
                            style: const TextStyle(fontSize: 12,
                                fontWeight: FontWeight.bold, color: Color(0xFF795548))),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'],
                              style: const TextStyle(fontSize: 17,
                                  fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 2),
                          Text('Breed: ${item['breed']}',
                              style: const TextStyle(color: Colors.black45, fontSize: 12)),
                        ],
                      ),
                      Row(children: [
                        const Icon(Icons.location_on_rounded, size: 13, color: Colors.black38),
                        const SizedBox(width: 3),
                        Text(item['location'],
                            style: const TextStyle(fontSize: 12, color: Colors.black38)),
                      ]),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Specs row
                  Row(
                    children: [
                      _specChip(Icons.cake_rounded, item['age'], color),
                      const SizedBox(width: 8),
                      _specChip(Icons.monitor_weight_rounded, item['weight'], color),
                      const SizedBox(width: 8),
                      _specChip(Icons.water_drop_rounded, item['milk'], color),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showContactDialog(item),
                          icon: Icon(Icons.phone_rounded, size: 16, color: color),
                          label: Text('Contact', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: color.withValues(alpha: 0.4)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openDetail(item),
                          icon: const Icon(Icons.visibility_rounded, size: 16, color: Colors.white),
                          label: const Text('View Details',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specChip(IconData icon, String label, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
            textAlign: TextAlign.center),
      ]),
    ),
  );

  void _showContactDialog(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1B8F5A).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_rounded, color: Color(0xFF1B8F5A), size: 28),
          ),
          const SizedBox(height: 14),
          Text('Contact Seller', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Interested in ${item['name']}?',
              style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 18),
              label: const Text('Call Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B8F5A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.message_rounded, size: 18),
              label: const Text('Send Message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _showSellDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('List Your Animal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Reach thousands of buyers across India',
                style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 20),
            ...[
              [Icons.pets_rounded, 'Add animal details & photos'],
              [Icons.currency_rupee_rounded, 'Set your price'],
              [Icons.people_rounded, 'Connect with buyers instantly'],
            ].map((row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B8F5A).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(row[0] as IconData, color: const Color(0xFF1B8F5A), size: 18),
                ),
                const SizedBox(width: 12),
                Text(row[1] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ]),
            )),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B8F5A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Start Listing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── DETAIL PAGE ──────────────────────────────────────────────
class LivestockDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;
  const LivestockDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = Color(item['color'] as int);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF0A3D22),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: color.withValues(alpha: 0.2),
                      child: Icon(Icons.pets_rounded, size: 80, color: color.withValues(alpha: 0.4)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16, left: 16,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item['name'],
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                      Text('Breed: ${item['breed']}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ]),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Price + rating card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Price', style: TextStyle(color: Colors.black38, fontSize: 12)),
                        Text(item['price'], style: TextStyle(
                            color: color, fontSize: 26, fontWeight: FontWeight.bold)),
                      ]),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Row(children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 18),
                          const SizedBox(width: 4),
                          Text('${item['rating']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ]),
                        const Text('Seller Rating',
                            style: TextStyle(color: Colors.black38, fontSize: 12)),
                      ]),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Specs grid
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Animal Details',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.5,
                      children: [
                        _detailTile(Icons.cake_rounded, 'Age', item['age'], color),
                        _detailTile(Icons.monitor_weight_rounded, 'Weight', item['weight'], color),
                        _detailTile(Icons.water_drop_rounded, 'Yield', item['milk'], color),
                        _detailTile(Icons.location_on_rounded, 'Location', item['location'], color),
                      ],
                    ),
                  ]),
                ),

                const SizedBox(height: 14),

                // Health badges
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Health Status',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      _healthBadge('Vaccinated', Icons.vaccines_rounded, Colors.green),
                      _healthBadge('Dewormed', Icons.healing_rounded, Colors.blue),
                      _healthBadge('Vet Checked', Icons.medical_services_rounded, Colors.teal),
                      _healthBadge('Insured', Icons.shield_rounded, Colors.orange),
                    ]),
                  ]),
                ),

                const SizedBox(height: 20),

                // CTA buttons
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_rounded, color: color, size: 18),
                      label: Text('Back', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: color.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Enquiry sent for ${item['name']}!'),
                            backgroundColor: color,
                          ),
                        );
                      },
                      icon: const Icon(Icons.handshake_rounded, color: Colors.white, size: 18),
                      label: const Text('Send Enquiry',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black38)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
      ]),
    ]),
  );

  Widget _healthBadge(String label, IconData icon, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    ]),
  );
}

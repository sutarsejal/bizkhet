import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookTractorPage extends StatefulWidget {
  const BookTractorPage({super.key});

  @override
  State<BookTractorPage> createState() => _BookTractorPageState();
}

class _BookTractorPageState extends State<BookTractorPage> {
  final supabase = Supabase.instance.client;
  int _selectedFilter = 0;
  final filters = ['All', 'Available', 'Low Price', 'High HP'];

  Future<List<Map<String, dynamic>>> fetchTractors() async {
    final data = await supabase
        .from('tractors')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  late Future<List<Map<String, dynamic>>> _tractorsFuture;

  @override
  void initState() {
    super.initState();
    _tractorsFuture = fetchTractors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(child: _buildFilterRow()),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _tractorsFuture,
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
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 60, color: Colors.black26),
                          const SizedBox(height: 12),
                          Text('Error: ${snapshot.error}',
                              style:
                                  const TextStyle(color: Colors.black45)),
                        ],
                      ),
                    ),
                  );
                }
                final tractors = snapshot.data ?? [];
                if (tractors.isEmpty) {
                  return const SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.agriculture_rounded,
                              size: 64, color: Colors.black26),
                          SizedBox(height: 12),
                          Text('No tractors available',
                              style: TextStyle(
                                  color: Colors.black45, fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  child: Column(
                    children: tractors
                        .map((t) => _buildTractorCard(t))
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BizKhet',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  letterSpacing: 1.5)),
                          Text('Book Tractor',
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
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.agriculture_rounded,
                            color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    _badge(Icons.verified_rounded, 'Verified Owners'),
                    const SizedBox(width: 8),
                    _badge(Icons.access_time_rounded, 'Book Instantly'),
                  ]),
                ],
              ),
            ),
          ),
        ),
        title: const Text('Book Tractor',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
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

  // ── STATS ROW ────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(children: [
        _statItem('5+', 'Tractors', Icons.agriculture_rounded),
        _vDiv(),
        _statItem('4.7★', 'Rating', Icons.star_rounded),
        _vDiv(),
        _statItem('1hr', 'Min Booking', Icons.access_time_rounded),
      ]),
    );
  }

  Widget _statItem(String val, String label, IconData icon) =>
      Expanded(
        child: Column(children: [
          Icon(icon, color: const Color(0xFF1B8F5A), size: 20),
          const SizedBox(height: 4),
          Text(val,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: Colors.black38)),
        ]),
      );

  Widget _vDiv() =>
      Container(width: 1, height: 36, color: Colors.black12);

  // ── FILTER ROW ───────────────────────────────────────────────
  Widget _buildFilterRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(children: [
        const Divider(height: 1),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.asMap().entries.map((e) {
              final selected = _selectedFilter == e.key;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedFilter = e.key),
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
      ]),
    );
  }

  // ── TRACTOR CARD ─────────────────────────────────────────────
  Widget _buildTractorCard(Map<String, dynamic> tractor) {
    final isAvailable = tractor['available'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(children: [
        // Image banner
        ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
          child: Stack(children: [
            tractor['image_url'] != null
                ? Image.network(
                    tractor['image_url'],
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _placeholderImage(),
                  )
                : _placeholderImage(),

            // Available badge
            Positioned(
              top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? const Color(0xFF1B8F5A)
                      : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  Icon(Icons.circle,
                      color: Colors.white, size: 8),
                  const SizedBox(width: 4),
                  Text(isAvailable ? 'Available' : 'Booked',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ]),
              ),
            ),

            // Price badge
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '₹${tractor['price']}/${tractor['unit']}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ]),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(tractor['name'] ?? 'Unknown',
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.person_rounded,
                          size: 13, color: Colors.black38),
                      const SizedBox(width: 4),
                      Text(tractor['owner'] ?? '',
                          style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 12)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on_rounded,
                          size: 13, color: Colors.black38),
                      const SizedBox(width: 4),
                      Text(tractor['location'] ?? '',
                          style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 12)),
                    ]),
                  ]),
                ),
                // Rating
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(children: [
                    Icon(Icons.star_rounded,
                        color: Color(0xFFFFB300), size: 16),
                    SizedBox(width: 3),
                    Text('4.8',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF795548))),
                  ]),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Spec chips
            Row(children: [
              _specChip(Icons.speed_rounded,
                  tractor['capacity'] ?? 'N/A'),
              const SizedBox(width: 8),
              _specChip(Icons.local_gas_station_rounded,
                  tractor['fuel_type'] ?? 'Diesel'),
              const SizedBox(width: 8),
              _specChip(Icons.verified_rounded, 'Verified'),
            ]),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Buttons
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _showTractorDetail(tractor),
                  icon: const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Color(0xFF1B8F5A)),
                  label: const Text('Details',
                      style: TextStyle(
                          color: Color(0xFF1B8F5A),
                          fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Color(0xFF1B8F5A),
                        width: 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isAvailable
                      ? () => _showBookingSheet(tractor)
                      : null,
                  icon: const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: Colors.white),
                  label: Text(
                      isAvailable ? 'Book Now' : 'Unavailable',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAvailable
                        ? const Color(0xFF1B8F5A)
                        : Colors.grey,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _specChip(IconData icon, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1B8F5A).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [
            Icon(icon,
                size: 14, color: const Color(0xFF1B8F5A)),
            const SizedBox(height: 3),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B8F5A)),
                textAlign: TextAlign.center),
          ]),
        ),
      );

  Widget _placeholderImage() => Container(
        width: double.infinity,
        height: 180,
        color: const Color(0xFF1B8F5A).withValues(alpha: 0.1),
        child: const Icon(Icons.agriculture_rounded,
            size: 70,
            color: Color(0xFF1B8F5A)),
      );

  // ── TRACTOR DETAIL SHEET ──────────────────────────────────────
  void _showTractorDetail(Map<String, dynamic> tractor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
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
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: tractor['image_url'] != null
                        ? Image.network(
                            tractor['image_url'],
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _placeholderImage(),
                          )
                        : _placeholderImage(),
                  ),
                  const SizedBox(height: 16),
                  Text(tractor['name'] ?? '',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.person_rounded,
                        size: 14, color: Colors.black38),
                    const SizedBox(width: 6),
                    Text('Owner: ${tractor['owner'] ?? ''}',
                        style: const TextStyle(
                            color: Colors.black54)),
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on_rounded,
                        size: 14, color: Colors.black38),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(tractor['location'] ?? '',
                          style: const TextStyle(
                              color: Colors.black54),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  // Specs grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.5,
                    children: [
                      _detailTile(Icons.speed_rounded,
                          'Capacity',
                          tractor['capacity'] ?? 'N/A'),
                      _detailTile(
                          Icons.local_gas_station_rounded,
                          'Fuel',
                          tractor['fuel_type'] ?? 'Diesel'),
                      _detailTile(
                          Icons.currency_rupee_rounded,
                          'Rate',
                          '₹${tractor['price']}/${tractor['unit']}'),
                      _detailTile(Icons.circle,
                          'Status',
                          (tractor['available'] ?? true)
                              ? 'Available'
                              : 'Booked'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showBookingSheet(tractor);
                      },
                      icon: const Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.white,
                          size: 18),
                      label: const Text('Book This Tractor',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
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
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value) =>
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B8F5A).withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(icon,
              size: 16, color: const Color(0xFF1B8F5A)),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: Colors.black38)),
            Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ]),
        ]),
      );

  // ── BOOKING SHEET ─────────────────────────────────────────────
  void _showBookingSheet(Map<String, dynamic> tractor) {
    final user = supabase.auth.currentUser;
    if (user == null) {
      _showSnack('Please login to book a tractor', isError: true);
      return;
    }

    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    int selectedHours = 4;
    bool isBooking = false;
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B8F5A)
                              .withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Icon(
                            Icons.agriculture_rounded,
                            color: Color(0xFF1B8F5A),
                            size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                          Text(tractor['name'] ?? '',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold)),
                          Text(
                              '₹${tractor['price']}/${tractor['unit']}',
                              style: const TextStyle(
                                  color: Color(0xFF1B8F5A),
                                  fontWeight:
                                      FontWeight.bold)),
                        ]),
                      ),
                    ]),

                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // Date picker
                    const Text('Select Date',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now()
                              .add(const Duration(days: 1)),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 30)),
                          builder: (context, child) =>
                              Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme:
                                  const ColorScheme.light(
                                primary: Color(0xFF1B8F5A),
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setModalState(
                              () => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF1B8F5A)
                                  .withValues(alpha: 0.07),
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFF1B8F5A)
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Row(children: [
                          const Icon(
                              Icons.calendar_today_rounded,
                              color: Color(0xFF1B8F5A),
                              size: 20),
                          const SizedBox(width: 12),
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          const Icon(Icons.edit_rounded,
                              color: Colors.black38, size: 16),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Hours selector
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Number of Hours',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54)),
                        Text('$selectedHours hrs',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B8F5A))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: [1, 2, 4, 6, 8, 10]
                          .map((h) => GestureDetector(
                                onTap: () => setModalState(
                                    () => selectedHours = h),
                                child: AnimatedContainer(
                                  duration: const Duration(
                                      milliseconds: 200),
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: selectedHours == h
                                        ? const Color(
                                            0xFF1B8F5A)
                                        : const Color(
                                            0xFFF2F4F0),
                                    borderRadius:
                                        BorderRadius.circular(
                                            12),
                                    boxShadow: selectedHours == h
                                        ? [
                                            BoxShadow(
                                                color: const Color(
                                                        0xFF1B8F5A)
                                                    .withValues(
                                                        alpha:
                                                            0.3),
                                                blurRadius: 8,
                                                offset:
                                                    const Offset(
                                                        0, 3))
                                          ]
                                        : [],
                                  ),
                                  child: Center(
                                    child: Text('$h',
                                        style: TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                            color:
                                                selectedHours == h
                                                    ? Colors.white
                                                    : Colors
                                                        .black54)),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),

                    const SizedBox(height: 20),

                    // Notes
                    const Text('Notes (Optional)',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText:
                            'Any special requirements...',
                        hintStyle: const TextStyle(
                            color: Colors.black38,
                            fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF8FAF7),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Price summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1B8F5A)
                                .withValues(alpha: 0.08),
                            const Color(0xFF1B8F5A)
                                .withValues(alpha: 0.03),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFF1B8F5A)
                                .withValues(alpha: 0.2)),
                      ),
                      child: Column(children: [
                        _summaryRow('Rate',
                            '₹${tractor['price']}/${tractor['unit']}'),
                        const SizedBox(height: 8),
                        _summaryRow(
                            'Hours', '$selectedHours hrs'),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount',
                                style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 15)),
                            Text(
                              '₹${(tractor['price'] as int) * selectedHours}',
                              style: const TextStyle(
                                  color: Color(0xFF1B8F5A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ],
                        ),
                      ]),
                    ),

                    const SizedBox(height: 20),

                    // Book button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isBooking
                            ? null
                            : () async {
                                setModalState(
                                    () => isBooking = true);
                                try {
                                  await supabase
                                      .from('tractor_bookings')
                                      .insert({
                                    'tractor_id':
                                        tractor['id'],
                                    'user_id': user.id,
                                    'booking_date':
                                        selectedDate
                                            .toIso8601String()
                                            .split('T')[0],
                                    'hours': selectedHours,
                                    'total_price':
                                        (tractor['price']
                                                as int) *
                                            selectedHours,
                                    'status': 'pending',
                                    'notes': notesController
                                        .text.trim(),
                                  });

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    _showBookingSuccess(
                                        tractor,
                                        selectedDate,
                                        selectedHours);
                                  }
                                } catch (e) {
                                  setModalState(
                                      () => isBooking = false);
                                  _showSnack(
                                      'Booking failed: $e',
                                      isError: true);
                                }
                              },
                        icon: isBooking
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2))
                            : const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 18),
                        label: Text(
                            isBooking
                                ? 'Booking...'
                                : 'Confirm Booking',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
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
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.black54, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      );

  // ── BOOKING SUCCESS ───────────────────────────────────────────
  void _showBookingSuccess(Map<String, dynamic> tractor,
      DateTime date, int hours) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B8F5A)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: Color(0xFF1B8F5A), size: 50),
          ),
          const SizedBox(height: 16),
          const Text('Booking Confirmed! 🎉',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '${tractor['name']} booked for\n${date.day}/${date.month}/${date.year} — $hours hours',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B8F5A)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Total: ₹${(tractor['price'] as int) * hours}',
              style: const TextStyle(
                  color: Color(0xFF1B8F5A),
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Owner will contact you shortly.',
            style: TextStyle(color: Colors.black38, fontSize: 12),
          ),
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
              child: const Text('Done!',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? Colors.red : const Color(0xFF1B8F5A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));
  }
}

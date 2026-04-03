import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'services/market_service.dart';

class SellCropFormPage extends StatefulWidget {
  final String? cropName;
  const SellCropFormPage({super.key, this.cropName});

  @override
  State<SellCropFormPage> createState() => _SellCropFormPageState();
}

class _SellCropFormPageState extends State<SellCropFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _cropNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedQuality = 'A';
  String _selectedUnit = 'Quintal';
  String _selectedCategory = 'Grains';
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isPosting = false;

  String _trend = '';
  String _suggestion = '';
  List<Map<String, dynamic>> _buyerRequests = [];

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.cropName != null && widget.cropName!.isNotEmpty) {
      _cropNameController.text = widget.cropName!;
      _selectedCategory = _getCategoryFromCrop(widget.cropName!);
      _loadMarketData(widget.cropName!);
    }
  }

  void _loadMarketData(String cropName) {
    try {
      final cropData = MarketService.getMarketDataForCrop(cropName);
      final price = cropData['pricePerQuintal'];
      if (mounted) {
        setState(() {
          _trend = MarketService.calculateTrend(
              price, cropData['yesterdayPrice']);
          _suggestion = MarketService.suggestedPriceRange(price);
          _priceController.text = price.toString();
          _buyerRequests = [
            {
              'name': 'Ramesh Traders',
              'price': price + 50,
              'distance': 5,
              'rating': 4.5
            },
            {
              'name': 'Shyam Agro',
              'price': price - 20,
              'distance': 12,
              'rating': 4.0
            },
            {
              'name': 'Mohan Traders',
              'price': price + 30,
              'distance': 8,
              'rating': 5.0
            },
          ];
        });
      }
    } catch (e) {
      debugPrint('Market data error: $e');
    }
  }

  String _getCategoryFromCrop(String name) {
    final vegetables = [
      'tomato', 'potato', 'onion', 'carrot', 'brinjal',
      'cabbage', 'spinach', 'cauliflower', 'pea', 'garlic'
    ];
    final fruits = [
      'mango', 'banana', 'apple', 'grapes', 'orange',
      'papaya', 'guava', 'watermelon', 'pomegranate'
    ];
    final lower = name.toLowerCase();
    if (vegetables.any((v) => lower.contains(v))) return 'Vegetables';
    if (fruits.any((f) => lower.contains(f))) return 'Fruits';
    return 'Grains';
  }

  Future<void> _pickImage() async {
    if (_images.length >= 3) {
      _showSnack('Maximum 3 images allowed', isError: true);
      return;
    }
    final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _images.add(File(picked.path)));
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1B8F5A),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dateController.text =
          '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  Future<void> _postForSale() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isPosting = true);

    try {
      // ✅ Simple insert — only existing columns
      await supabase.from('items').insert({
        'name': _cropNameController.text.trim(),
        'category': _selectedCategory,
        'price':
            '₹${_priceController.text.trim()} / $_selectedUnit',
        'location': _locationController.text.trim(),
        'image_url': '',
      });

      if (mounted) {
        _showSnack('✅ Crop posted for sale successfully!');
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) _showBuyerRequestsSheet();
      }
    } catch (e) {
      debugPrint('Insert error: $e');
      _showSnack('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
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

  void _showBuyerRequestsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BuyerRequestsSheet(
        buyerRequests: _buyerRequests,
        cropName: _cropNameController.text,
      ),
    );
  }

  @override
  void dispose() {
    _cropNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_trend.isNotEmpty) ...[
                      _buildTrendCard(),
                      const SizedBox(height: 16),
                    ],
                    _buildFormCard(),
                    const SizedBox(height: 16),
                    _buildImageCard(),
                    const SizedBox(height: 16),
                    if (_buyerRequests.isNotEmpty) ...[
                      _buildBuyersPreview(),
                      const SizedBox(height: 16),
                    ],
                    _buildPostButton(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── APP BAR ──────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
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
              colors: [
                Color(0xFF0A3D22),
                Color(0xFF0F5C35),
                Color(0xFF1B8F5A)
              ],
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
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              letterSpacing: 1.5)),
                      SizedBox(height: 4),
                      Text('Sell Your Crop',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.spa_rounded,
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

  // ── TREND CARD ───────────────────────────────────────────────
  Widget _buildTrendCard() {
    final isUp = _trend.contains('↑') ||
        _trend.toLowerCase().contains('up');
    final trendColor =
        isUp ? const Color(0xFF1B8F5A) : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
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
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: trendColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
              isUp
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: trendColor,
              size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            const Text('Market Intelligence',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 3),
            Text(_trend,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: trendColor)),
            const SizedBox(height: 2),
            Text(_suggestion,
                style: const TextStyle(
                    fontSize: 12, color: Colors.black54)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: trendColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('Live',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: trendColor)),
        ),
      ]),
    );
  }

  // ── FORM CARD ─────────────────────────────────────────────────
// ── FORM CARD ─────────────────────────────────────────────────
  Widget _buildFormCard() {
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
      child: Column(children: [
        // Header
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B8F5A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.edit_note_rounded,
                color: Color(0xFF1B8F5A), size: 18),
          ),
          const SizedBox(width: 10),
          const Text('Crop Details',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ]),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),

        // Crop name
        _buildField(
          controller: _cropNameController,
          label: 'Crop Name',
          hint: 'e.g. Wheat, Rice, Tomato',
          icon: Icons.grass_rounded,
          validator: (v) =>
              v == null || v.isEmpty ? 'Enter crop name' : null,
          onChanged: (v) {
            if (v.length > 2) {
              setState(() {
                _selectedCategory = _getCategoryFromCrop(v);
              });
              _loadMarketData(v);
            }
          },
        ),
        const SizedBox(height: 14),

        // ✅ Category — value instead of initialValue
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAF7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedCategory, // ✅ value use karo
            isExpanded: true, // ✅ overflow fix
            decoration: const InputDecoration(
              labelText: 'Category',
              border: InputBorder.none,
              isDense: true,
              prefixIcon: Icon(Icons.category_rounded,
                  color: Color(0xFF1B8F5A), size: 20),
            ),
            items: ['Grains', 'Vegetables', 'Fruits']
                .map((c) => DropdownMenuItem(
                    value: c, child: Text(c)))
                .toList(),
            onChanged: (v) =>
                setState(() => _selectedCategory = v!),
          ),
        ),
        const SizedBox(height: 14),

        // ✅ Quantity + Unit — fixed overflow
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Expanded(
            flex: 2,
            child: _buildField(
              controller: _quantityController,
              label: 'Quantity',
              hint: '0',
              icon: Icons.scale_rounded,
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter quantity' : null,
            ),
          ),
          const SizedBox(width: 10),
          
          Expanded(
            child: Container(
              height: 56, 
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedUnit,
                  isExpanded: true, // ✅ overflow fix
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF1B8F5A),
                    size: 20,
                  ),
                  items: ['Quintal', 'Kg', 'Ton']
                      .map((u) => DropdownMenuItem(
                          value: u,
                          child: Text(u,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14))))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedUnit = v!),
                ),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 14),

        // Price
        _buildField(
          controller: _priceController,
          label: 'Expected Price (₹)',
          hint: 'Enter your price',
          icon: Icons.currency_rupee_rounded,
          keyboardType: TextInputType.number,
          validator: (v) =>
              v == null || v.isEmpty ? 'Enter price' : null,
        ),
        const SizedBox(height: 14),

        // Location
        _buildField(
          controller: _locationController,
          label: 'Location / Mandi',
          hint: 'e.g. Pune, Maharashtra',
          icon: Icons.location_on_rounded,
          validator: (v) =>
              v == null || v.isEmpty ? 'Enter location' : null,
        ),
        const SizedBox(height: 14),

        // Date
        GestureDetector(
          onTap: _selectDate,
          child: AbsorbPointer(
            child: _buildField(
              controller: _dateController,
              label: 'Available From Date',
              hint: 'Select date',
              icon: Icons.calendar_today_rounded,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Select date' : null,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // ✅ Quality — value instead of initialValue
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAF7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedQuality, // ✅ value use karo
            isExpanded: true, // ✅ overflow fix
            decoration: const InputDecoration(
              labelText: 'Quality Grade',
              border: InputBorder.none,
              isDense: true,
              prefixIcon: Icon(Icons.star_rounded,
                  color: Color(0xFF1B8F5A), size: 20),
            ),
            items: [
              DropdownMenuItem(
                  value: 'A',
                  child: Row(children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text('Grade A — Premium',
                        style: TextStyle(fontSize: 13)),
                  ])),
              DropdownMenuItem(
                  value: 'B',
                  child: Row(children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text('Grade B — Standard',
                        style: TextStyle(fontSize: 13)),
                  ])),
              DropdownMenuItem(
                  value: 'C',
                  child: Row(children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text('Grade C — Economy',
                        style: TextStyle(fontSize: 13)),
                  ])),
            ],
            onChanged: (v) =>
                setState(() => _selectedQuality = v!),
          ),
        ),
        const SizedBox(height: 14),

        // Description
        _buildField(
          controller: _descController,
          label: 'Description (Optional)',
          hint: 'Any additional details...',
          icon: Icons.description_rounded,
          maxLines: 3,
        ),
      ]),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style:
          const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(
            color: Colors.black26, fontSize: 13),
        prefixIcon:
            Icon(icon, color: const Color(0xFF1B8F5A), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAF7),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
                color: Color(0xFF1B8F5A), width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Colors.red, width: 1)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
      ),
    );
  }

  // ── IMAGE CARD ───────────────────────────────────────────────
  Widget _buildImageCard() {
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
              color: const Color(0xFF8E44AD).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.photo_library_rounded,
                color: Color(0xFF8E44AD), size: 18),
          ),
          const SizedBox(width: 10),
          const Text('Crop Photos',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const Spacer(),
          Text('${_images.length}/3',
              style: const TextStyle(
                  color: Colors.black38, fontSize: 13)),
        ]),
        const SizedBox(height: 6),
        const Text('Add up to 3 photos of your crop',
            style:
                TextStyle(color: Colors.black38, fontSize: 12)),
        const SizedBox(height: 16),

        Row(children: [
          ..._images.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(e.value,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(
                          () => _images.removeAt(e.key)),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                ]),
              )),

          if (_images.length < 3)
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF8E44AD)
                      .withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF8E44AD)
                          .withValues(alpha: 0.3),
                      width: 1.5),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_rounded,
                        color: Color(0xFF8E44AD), size: 24),
                    SizedBox(height: 4),
                    Text('Add Photo',
                        style: TextStyle(
                            color: Color(0xFF8E44AD),
                            fontSize: 10)),
                  ],
                ),
              ),
            ),
        ]),
      ]),
    );
  }

  // ── BUYERS PREVIEW ───────────────────────────────────────────
  Widget _buildBuyersPreview() {
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
              color: const Color(0xFF2980B9).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.people_rounded,
                color: Color(0xFF2980B9), size: 18),
          ),
          const SizedBox(width: 10),
          const Text('Nearby Buyers',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2980B9).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${_buyerRequests.length} buyers',
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2980B9),
                    fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 14),

        ..._buyerRequests.map((buyer) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF2980B9)
                        .withValues(alpha: 0.1)),
              ),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2980B9)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                        buyer['name'].toString()[0],
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2980B9))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                    Text(buyer['name'].toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87)),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.location_on_rounded,
                          size: 11, color: Colors.black38),
                      const SizedBox(width: 2),
                      Text('${buyer['distance']} km away',
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black45)),
                      const SizedBox(width: 8),
                      ...List.generate(
                          5,
                          (i) => Icon(
                                i < (buyer['rating'] as double).round()
                                    ? Icons.star_rounded
                                    : Icons
                                        .star_border_rounded,
                                size: 11,
                                color: Colors.orange,
                              )),
                    ]),
                  ]),
                ),
                Text('₹${buyer['price']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1B8F5A))),
              ]),
            )),

        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showBuyerRequestsSheet,
            icon: const Icon(Icons.open_in_new_rounded,
                color: Color(0xFF2980B9), size: 16),
            label: const Text('View All & Negotiate',
                style: TextStyle(
                    color: Color(0xFF2980B9),
                    fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2980B9)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ]),
    );
  }

  // ── POST BUTTON ──────────────────────────────────────────────
  Widget _buildPostButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isPosting ? null : _postForSale,
        icon: _isPosting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.upload_rounded,
                color: Colors.white, size: 20),
        label: Text(
          _isPosting ? 'Posting...' : 'Post Crop for Sale',
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B8F5A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }
}

// ── BUYER REQUESTS SHEET ──────────────────────────────────────
class _BuyerRequestsSheet extends StatefulWidget {
  final List<Map<String, dynamic>> buyerRequests;
  final String cropName;

  const _BuyerRequestsSheet({
    required this.buyerRequests,
    required this.cropName,
  });

  @override
  State<_BuyerRequestsSheet> createState() =>
      _BuyerRequestsSheetState();
}

class _BuyerRequestsSheetState
    extends State<_BuyerRequestsSheet> {
  late List<Map<String, dynamic>> buyers;

  @override
  void initState() {
    super.initState();
    buyers = List.from(widget.buyerRequests);
  }

  void _showNegotiateDialog(int index) {
    final controller = TextEditingController(
        text: buyers[index]['price'].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.handshake_rounded,
              color: Color(0xFFE67E22), size: 22),
          const SizedBox(width: 8),
          Expanded(
              child: Text(
                  'Negotiate — ${buyers[index]['name']}',
                  style: const TextStyle(fontSize: 15))),
        ]),
        content:
            Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Current offer: ₹${buyers[index]['price']}',
              style: const TextStyle(color: Colors.black45)),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Your Counter Price (₹)',
              prefixIcon: const Icon(
                  Icons.currency_rupee_rounded,
                  color: Color(0xFF1B8F5A),
                  size: 18),
              filled: true,
              fillColor: const Color(0xFFF8FAF7),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black45)),
          ),
          ElevatedButton(
            onPressed: () {
              final newPrice =
                  int.tryParse(controller.text);
              if (newPrice != null) {
                setState(
                    () => buyers[index]['price'] = newPrice);
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(
                  content: Text(
                      '✅ Counter offer ₹$newPrice sent!'),
                  backgroundColor: const Color(0xFFE67E22),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE67E22),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Send Offer',
                style:
                    TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _acceptDeal(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.check_circle_rounded,
              color: Color(0xFF1B8F5A), size: 22),
          SizedBox(width: 8),
          Text('Confirm Deal',
              style: TextStyle(fontSize: 16)),
        ]),
        content: Text(
            'Accept deal with ${buyers[index]['name']} at ₹${buyers[index]['price']}?',
            style: const TextStyle(color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black45)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(
                content: Text(
                    '🎉 Deal with ${buyers[index]['name']} at ₹${buyers[index]['price']} confirmed!'),
                backgroundColor: const Color(0xFF1B8F5A),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B8F5A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Accept',
                style:
                    TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2980B9)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people_rounded,
                    color: Color(0xFF2980B9), size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Interested Buyers',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text('for ${widget.cropName}',
                    style: const TextStyle(
                        color: Colors.black45, fontSize: 12)),
              ]),
              const Spacer(),
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
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: controller,
              padding: const EdgeInsets.all(16),
              itemCount: buyers.length,
              itemBuilder: (_, i) {
                final buyer = buyers[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: Colors.black
                            .withValues(alpha: 0.06)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Column(children: [
                    Container(
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2980B9),
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(18)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(children: [
                        Row(children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2980B9)
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                  buyer['name']
                                      .toString()[0],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          Color(0xFF2980B9))),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                              Text(buyer['name'].toString(),
                                  style: const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 15,
                                      color:
                                          Colors.black87)),
                              const SizedBox(height: 3),
                              Row(children: [
                                const Icon(
                                    Icons.location_on_rounded,
                                    size: 12,
                                    color: Colors.black38),
                                const SizedBox(width: 3),
                                Text(
                                    '${buyer['distance']} km',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color:
                                            Colors.black45)),
                                const SizedBox(width: 8),
                                ...List.generate(
                                    5,
                                    (s) => Icon(
                                          s < (buyer['rating'] as double).round()
                                              ? Icons
                                                  .star_rounded
                                              : Icons
                                                  .star_border_rounded,
                                          size: 13,
                                          color: Colors.orange,
                                        )),
                              ]),
                            ]),
                          ),
                          Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                            Text('₹${buyer['price']}',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Color(0xFF1B8F5A))),
                            const Text('/quintal',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black38)),
                          ]),
                        ]),
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // Action buttons
                        Row(children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _acceptDeal(i),
                              icon: const Icon(
                                  Icons.check_circle_rounded,
                                  size: 15,
                                  color: Colors.white),
                              label: const Text('Accept',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF1B8F5A),
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _showNegotiateDialog(i),
                              icon: const Icon(
                                  Icons.handshake_rounded,
                                  size: 15,
                                  color: Colors.white),
                              label: const Text('Negotiate',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFE67E22),
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      '📞 Calling ${buyer['name']}...'),
                                  backgroundColor:
                                      const Color(0xFF2980B9),
                                  behavior:
                                      SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                              12)),
                                ));
                              },
                              icon: const Icon(
                                  Icons.call_rounded,
                                  size: 15,
                                  color: Colors.white),
                              label: const Text('Call',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF2980B9),
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            10)),
                              ),
                            ),
                          ),
                        ]),
                      ]),
                    ),
                  ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

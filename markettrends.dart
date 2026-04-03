import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MarketTrendsPage extends StatefulWidget {
  const MarketTrendsPage({super.key});

  @override
  State<MarketTrendsPage> createState() => _MarketTrendsPageState();
}

class _MarketTrendsPageState extends State<MarketTrendsPage> {
  int _selectedCrop = 0;
  int _selectedRange = 0;
  int? _touchedIndex;

  final crops = ['Wheat', 'Rice', 'Maize', 'Soybean'];
  final ranges = ['6M', '1Y', '2Y'];

  final cropColors = [
    Color(0xFF1B8F5A),
    Color(0xFF2980B9),
    Color(0xFFE67E22),
    Color(0xFF8E44AD),
  ];

  final cropIcons = [
    Icons.grass_rounded,
    Icons.rice_bowl_rounded,
    Icons.agriculture_rounded,
    Icons.spa_rounded,
  ];

  // Data for each crop [6M, 1Y, 2Y]
  final Map<String, Map<String, List<FlSpot>>> cropData = {
    'Wheat': {
      '6M': [FlSpot(0,2400),FlSpot(1,2300),FlSpot(2,2350),FlSpot(3,2450),FlSpot(4,2550),FlSpot(5,2650)],
      '1Y': [FlSpot(0,2100),FlSpot(1,2200),FlSpot(2,2150),FlSpot(3,2300),FlSpot(4,2400),FlSpot(5,2300),FlSpot(6,2350),FlSpot(7,2450),FlSpot(8,2500),FlSpot(9,2550),FlSpot(10,2600),FlSpot(11,2650)],
      '2Y': [FlSpot(0,1900),FlSpot(1,2000),FlSpot(2,2100),FlSpot(3,2050),FlSpot(4,2200),FlSpot(5,2300),FlSpot(6,2250),FlSpot(7,2350),FlSpot(8,2400),FlSpot(9,2500),FlSpot(10,2450),FlSpot(11,2550),FlSpot(12,2600),FlSpot(13,2650),FlSpot(14,2700),FlSpot(15,2750),FlSpot(16,2700),FlSpot(17,2800),FlSpot(18,2750),FlSpot(19,2850),FlSpot(20,2900),FlSpot(21,2950),FlSpot(22,3000),FlSpot(23,3050)],
    },
    'Rice': {
      '6M': [FlSpot(0,3200),FlSpot(1,3300),FlSpot(2,3250),FlSpot(3,3400),FlSpot(4,3350),FlSpot(5,3500)],
      '1Y': [FlSpot(0,2900),FlSpot(1,3000),FlSpot(2,3100),FlSpot(3,3050),FlSpot(4,3200),FlSpot(5,3150),FlSpot(6,3250),FlSpot(7,3300),FlSpot(8,3350),FlSpot(9,3400),FlSpot(10,3450),FlSpot(11,3500)],
      '2Y': [FlSpot(0,2500),FlSpot(1,2600),FlSpot(2,2700),FlSpot(3,2800),FlSpot(4,2750),FlSpot(5,2900),FlSpot(6,2850),FlSpot(7,3000),FlSpot(8,3100),FlSpot(9,3200),FlSpot(10,3150),FlSpot(11,3250),FlSpot(12,3300),FlSpot(13,3350),FlSpot(14,3400),FlSpot(15,3450),FlSpot(16,3500),FlSpot(17,3550),FlSpot(18,3500),FlSpot(19,3600),FlSpot(20,3650),FlSpot(21,3700),FlSpot(22,3750),FlSpot(23,3800)],
    },
    'Maize': {
      '6M': [FlSpot(0,1800),FlSpot(1,1850),FlSpot(2,1900),FlSpot(3,1950),FlSpot(4,1900),FlSpot(5,2000)],
      '1Y': [FlSpot(0,1600),FlSpot(1,1650),FlSpot(2,1700),FlSpot(3,1750),FlSpot(4,1800),FlSpot(5,1850),FlSpot(6,1900),FlSpot(7,1850),FlSpot(8,1950),FlSpot(9,2000),FlSpot(10,1950),FlSpot(11,2050)],
      '2Y': [FlSpot(0,1400),FlSpot(1,1450),FlSpot(2,1500),FlSpot(3,1550),FlSpot(4,1600),FlSpot(5,1650),FlSpot(6,1700),FlSpot(7,1750),FlSpot(8,1800),FlSpot(9,1850),FlSpot(10,1900),FlSpot(11,1950),FlSpot(12,2000),FlSpot(13,2050),FlSpot(14,2100),FlSpot(15,2150),FlSpot(16,2100),FlSpot(17,2200),FlSpot(18,2150),FlSpot(19,2250),FlSpot(20,2300),FlSpot(21,2350),FlSpot(22,2400),FlSpot(23,2450)],
    },
    'Soybean': {
      '6M': [FlSpot(0,4200),FlSpot(1,4300),FlSpot(2,4250),FlSpot(3,4400),FlSpot(4,4500),FlSpot(5,4600)],
      '1Y': [FlSpot(0,3800),FlSpot(1,3900),FlSpot(2,4000),FlSpot(3,4100),FlSpot(4,4050),FlSpot(5,4200),FlSpot(6,4150),FlSpot(7,4300),FlSpot(8,4350),FlSpot(9,4400),FlSpot(10,4500),FlSpot(11,4600)],
      '2Y': [FlSpot(0,3200),FlSpot(1,3300),FlSpot(2,3400),FlSpot(3,3500),FlSpot(4,3600),FlSpot(5,3700),FlSpot(6,3800),FlSpot(7,3900),FlSpot(8,4000),FlSpot(9,4100),FlSpot(10,4200),FlSpot(11,4300),FlSpot(12,4400),FlSpot(13,4500),FlSpot(14,4600),FlSpot(15,4700),FlSpot(16,4600),FlSpot(17,4800),FlSpot(18,4750),FlSpot(19,4900),FlSpot(20,4950),FlSpot(21,5000),FlSpot(22,5100),FlSpot(23,5200)],
    },
  };

  final Map<String, Map<String, dynamic>> cropStats = {
    'Wheat':   {'current': '₹2,650/q', 'change': '+10.4%', 'up': true, 'forecast': 'High Demand', 'tip': 'Sell in next 2 weeks', 'min': '₹2,300', 'max': '₹2,700'},
    'Rice':    {'current': '₹3,500/q', 'change': '+9.3%',  'up': true, 'forecast': 'Stable',      'tip': 'Hold for now',         'min': '₹3,200', 'max': '₹3,600'},
    'Maize':   {'current': '₹2,000/q', 'change': '+11.1%', 'up': true, 'forecast': 'Rising',      'tip': 'Good time to sell',    'min': '₹1,800', 'max': '₹2,100'},
    'Soybean': {'current': '₹4,600/q', 'change': '+9.5%',  'up': true, 'forecast': 'Peak Season', 'tip': 'Sell now for max profit','min': '₹4,200', 'max': '₹4,800'},
  };

  List<FlSpot> get _currentSpots {
    final cropName = crops[_selectedCrop];
    final range = ranges[_selectedRange];
    return cropData[cropName]![range]!;
  }

  double get _minY {
    final spots = _currentSpots;
    return (spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 200);
  }

  double get _maxY {
    final spots = _currentSpots;
    return (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 200);
  }

  final monthLabels6  = ['Jan','Feb','Mar','Apr','May','Jun'];
  final monthLabels12 = ['J','F','M','A','M','J','J','A','S','O','N','D'];
  final monthLabels24 = ['J','F','M','A','M','J','J','A','S','O','N','D','J','F','M','A','M','J','J','A','S','O','N','D'];

  String _getLabel(int index) {
    switch (_selectedRange) {
      case 0: return index < monthLabels6.length  ? monthLabels6[index]  : '';
      case 1: return index < monthLabels12.length ? monthLabels12[index] : '';
      case 2: return index < monthLabels24.length ? monthLabels24[index] : '';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cropName  = crops[_selectedCrop];
    final color     = cropColors[_selectedCrop];
    final stats     = cropStats[cropName]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(cropName, color, stats),
          SliverToBoxAdapter(child: _buildCropSelector()),
          SliverToBoxAdapter(child: _buildStatsRow(stats, color)),
          SliverToBoxAdapter(child: _buildChartCard(color)),
          SliverToBoxAdapter(child: _buildForecastCards()),
          SliverToBoxAdapter(child: _buildRecommendation(cropName, stats, color)),
          SliverToBoxAdapter(child: _buildAllCropsPriceTable()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // ── APP BAR ──────────────────────────────────────────────────
  Widget _buildAppBar(String cropName, Color color, Map stats) {
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
                          Text('Market', style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1.5)),
                          Text('Trends', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, height: 1.1)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 26),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _appBarBadge(Icons.calendar_today_rounded, 'Live Prices'),
                      const SizedBox(width: 8),
                      _appBarBadge(Icons.location_on_rounded, 'All India'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        title: const Text('Market Trends', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  Widget _appBarBadge(IconData icon, String label) => Container(
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

  // ── CROP SELECTOR ────────────────────────────────────────────
  Widget _buildCropSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Crop', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Row(
            children: List.generate(crops.length, (i) {
              final selected = _selectedCrop == i;
              final color = cropColors[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() { _selectedCrop = i; _touchedIndex = null; }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? color : const Color(0xFFF2F4F0),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: selected ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))] : [],
                    ),
                    child: Column(children: [
                      Icon(cropIcons[i], color: selected ? Colors.white : Colors.black45, size: 20),
                      const SizedBox(height: 4),
                      Text(crops[i], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : Colors.black45)),
                    ]),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── STATS ROW ────────────────────────────────────────────────
  Widget _buildStatsRow(Map stats, Color color) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _statBox('Current', stats['current'], color),
          _vDivider(),
          _statBox('Change', stats['change'], stats['up'] ? Colors.green : Colors.red),
          _vDivider(),
          _statBox('52W Low', stats['min'], Colors.black54),
          _vDivider(),
          _statBox('52W High', stats['max'], Colors.black54),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) => Expanded(
    child: Column(children: [
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.w500)),
      const SizedBox(height: 5),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
    ]),
  );

  Widget _vDivider() => Container(width: 1, height: 36, color: Colors.black12);

  // ── CHART CARD ───────────────────────────────────────────────
  Widget _buildChartCard(Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + range selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Price History',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
              Row(
                children: List.generate(ranges.length, (i) => GestureDetector(
                  onTap: () => setState(() { _selectedRange = i; _touchedIndex = null; }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _selectedRange == i ? color : const Color(0xFFF2F4F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(ranges[i], style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: _selectedRange == i ? Colors.white : Colors.black45,
                    )),
                  ),
                )),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (_currentSpots.length - 1).toDouble(),
                minY: _minY,
                maxY: _maxY,
                lineTouchData: LineTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (response?.lineBarSpots != null && response!.lineBarSpots!.isNotEmpty) {
                        _touchedIndex = response.lineBarSpots![0].spotIndex;
                      } else {
                        _touchedIndex = null;
                      }
                    });
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => color.withValues(alpha: 0.9),
                    getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                      '₹${s.y.toInt()}',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    )).toList(),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (_maxY - _minY) / 4,
                  getDrawingHorizontalLine: (_) => FlLine(color: Colors.black.withValues(alpha: 0.06), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      interval: (_maxY - _minY) / 4,
                      getTitlesWidget: (val, _) => Text(
                        '₹${val.toInt()}',
                        style: const TextStyle(fontSize: 10, color: Colors.black38),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _selectedRange == 2 ? 4 : (_selectedRange == 1 ? 2 : 1),
                      getTitlesWidget: (val, _) => Text(
                        _getLabel(val.toInt()),
                        style: const TextStyle(fontSize: 10, color: Colors.black38),
                      ),
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _currentSpots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, _, index) => FlDotCirclePainter(
                        radius: _touchedIndex == index ? 6 : 3,
                        color: color,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.0)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FORECAST CARDS ───────────────────────────────────────────
  Widget _buildForecastCards() {
    final forecastData = [
      {'crop': 'Wheat',   'status': 'High Demand', 'icon': Icons.trending_up_rounded,    'color': 0xFF1B8F5A},
      {'crop': 'Rice',    'status': 'Stable',       'icon': Icons.trending_flat_rounded,  'color': 0xFF2980B9},
      {'crop': 'Maize',   'status': 'Rising',       'icon': Icons.trending_up_rounded,    'color': 0xFFE67E22},
      {'crop': 'Soybean', 'status': 'Peak Season',  'icon': Icons.star_rounded,           'color': 0xFF8E44AD},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Market Forecast', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.4,
            children: forecastData.map((f) {
              final color = Color(f['color'] as int);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0,3))],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(f['icon'] as IconData, color: color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(f['crop'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
                        Text(f['status'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                      ],
                    )),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── RECOMMENDATION ───────────────────────────────────────────
  Widget _buildRecommendation(String cropName, Map stats, Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.08), color.withValues(alpha: 0.02)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(Icons.lightbulb_rounded, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text('AI Recommendation', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 14),
          _recommendationRow(Icons.check_circle_rounded, '$cropName: ${stats['tip']}', color),
          const SizedBox(height: 8),
          _recommendationRow(Icons.info_rounded, 'Forecast: ${stats['forecast']}', Colors.black54),
          const SizedBox(height: 8),
          _recommendationRow(Icons.trending_up_rounded, 'Price change: ${stats['change']} (6M)', Colors.black54),
        ],
      ),
    );
  }

  Widget _recommendationRow(IconData icon, String text, Color color) => Row(
    children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500))),
    ],
  );

  // ── ALL CROPS PRICE TABLE ────────────────────────────────────
  Widget _buildAllCropsPriceTable() {
    final tableData = [
      {'crop': 'Wheat',   'price': '₹2,650', 'change': '+10.4%', 'up': true,  'color': 0xFF1B8F5A},
      {'crop': 'Rice',    'price': '₹3,500', 'change': '+9.3%',  'up': true,  'color': 0xFF2980B9},
      {'crop': 'Maize',   'price': '₹2,000', 'change': '+11.1%', 'up': true,  'color': 0xFFE67E22},
      {'crop': 'Soybean', 'price': '₹4,600', 'change': '+9.5%',  'up': true,  'color': 0xFF8E44AD},
      {'crop': 'Cotton',  'price': '₹6,800', 'change': '-2.1%',  'up': false, 'color': 0xFF7F8C8D},
      {'crop': 'Bajra',   'price': '₹2,400', 'change': '+5.2%',  'up': true,  'color': 0xFFD35400},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Today\'s Mandi Prices', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B8F5A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Live', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1B8F5A))),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...tableData.map((row) {
            final color = Color(row['color'] as int);
            final isUp = row['up'] as bool;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Center(child: Text(
                          (row['crop'] as String).substring(0, 1),
                          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                        )),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(row['crop'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87))),
                      Text(row['price'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isUp ? Colors.green : Colors.red).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                              size: 12, color: isUp ? Colors.green : Colors.red),
                          const SizedBox(width: 2),
                          Text(row['change'] as String, style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold,
                              color: isUp ? Colors.green : Colors.red)),
                        ]),
                      ),
                    ],
                  ),
                ),
                if (row != tableData.last) const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            );
          }),
        ],
      ),
    );
  }
}

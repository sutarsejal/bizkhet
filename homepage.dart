import 'package:bizkhet/booking_page.dart';
import 'package:bizkhet/livestock_page.dart';
import 'package:bizkhet/login_page.dart';
import 'package:bizkhet/logout_page.dart';
import 'package:bizkhet/market_trends.dart';
import 'package:bizkhet/register_page.dart';
import 'package:bizkhet/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/weather_services.dart';
import 'services/market_service.dart';
import 'services/Fertilizer_service.dart';
import 'sell_crop_form_page.dart';
import 'market_place_page.dart';
import 'forum_page.dart';
import 'profile_page.dart';
import 'book_tractor_page.dart';
import 'my_orders_page.dart';
import 'ai_chat_page.dart'; 
import 'admin_panel_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  int _selectedIndex = 0;
  late AnimationController _sunController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _selectedLang = 'English';
  final List<String> _languages = ['English', 'हिंदी', 'मराठी'];

  final Map<String, List<Map<String, dynamic>>> _newsData = {
    'English': [
      {
        'icon': Icons.wb_sunny_rounded,
        'color': 0xFFE67E22,
        'bg': 0xFFFFF3E0,
        'tag': 'Weather',
        'tagColor': 0xFFE67E22,
        'title': 'Monsoon Advisory',
        'desc': 'Heavy rains expected this week. Protect your crops from waterlogging and fungal infections.',
        'fullDesc': '''🌧️ Monsoon Advisory — Full Details

Heavy and continuous rainfall is expected across Maharashtra, Karnataka, and Goa this week.

📌 Farmers should take the following precautions:

- Ensure proper drainage in fields to avoid waterlogging
- Avoid spraying pesticides or fertilizers during heavy rain
- Harvest mature crops immediately if possible
- Cover stored grains with waterproof sheets
- Check bunds and field boundaries for damage
- Watch out for fungal diseases like blast and blight in paddy

🌡️ Temperature: 24°C - 29°C
💧 Rainfall Expected: 80-120mm
📅 Duration: Next 5-7 days

Stay safe and monitor your crops daily!''',
      },
      {
        'icon': Icons.pest_control_rounded,
        'color': 0xFFE74C3C,
        'bg': 0xFFFFEBEE,
        'tag': 'Alert',
        'tagColor': 0xFFE74C3C,
        'title': 'Pest Alert',
        'desc': 'Locust activity reported in Rajasthan. Immediate action recommended for nearby farmers.',
        'fullDesc': '''🦗 Pest Alert — Locust Activity

Locust swarms have been reported in parts of Rajasthan and Gujarat.

📌 Immediate Actions:

- Spray Chlorpyrifos 20% EC early morning
- Use noise-making devices to drive away swarms
- Contact local agriculture department immediately
- Helpline: 1800-180-1551

🗺️ Affected Districts:
Barmer, Jaisalmer, Bikaner (Rajasthan)
Kutch, Banaskantha (Gujarat)

⚠️ High Risk Crops: Wheat, Mustard, Vegetables''',
      },
      {
        'icon': Icons.currency_rupee_rounded,
        'color': 0xFF1B8F5A,
        'bg': 0xFFE8F5E9,
        'tag': 'Policy',
        'tagColor': 0xFF1B8F5A,
        'title': 'MSP Update 2024',
        'desc': 'Govt increases Minimum Support Price for Kharif crops by 8%. Know your benefits.',
        'fullDesc': '''📢 MSP Update — Kharif 2024-25

Government of India has increased MSP for major Kharif crops.

💰 New MSP Rates:

- Paddy (Common): ₹2,183/quintal (+5.3%)
- Jowar (Hybrid): ₹3,371/quintal (+7.6%)
- Bajra: ₹2,500/quintal (+7.5%)
- Maize: ₹2,090/quintal (+5.8%)
- Moong: ₹8,682/quintal (+10.4%)
- Cotton (Medium): ₹7,121/quintal (+8.3%)

📌 How to avail MSP:
1. Register at nearest APMC mandi
2. Carry Aadhaar + land documents
3. Sell through govt procurement centers

Helpline: 1800-270-0224 (Toll Free)''',
      },
    ],
    'हिंदी': [
      {
        'icon': Icons.wb_sunny_rounded,
        'color': 0xFFE67E22,
        'bg': 0xFFFFF3E0,
        'tag': 'मौसम',
        'tagColor': 0xFFE67E22,
        'title': 'मानसून सलाह',
        'desc': 'इस हफ्ते भारी बारिश की संभावना है। फसल को जलभराव और फफूंद से बचाएं।',
        'fullDesc': '''🌧️ मानसून सलाह — पूरी जानकारी

महाराष्ट्र, कर्नाटक और गोवा में इस हफ्ते भारी बारिश होने की संभावना है।

📌 किसान भाई ये सावधानियां बरतें:

- खेत में पानी जमा न होने दें — नाली साफ रखें
- भारी बारिश में कीटनाशक या खाद न डालें
- पकी हुई फसल तुरंत काट लें
- रखे हुए अनाज को तिरपाल से ढक दें
- मेड़ और खेत की सीमाएं जांचें
- धान में झुलसा रोग से सावधान रहें

🌡️ तापमान: 24°C - 29°C
💧 बारिश का अनुमान: 80-120mm
📅 अवधि: अगले 5-7 दिन

सुरक्षित रहें और रोज़ाना फसल की निगरानी करें!''',
      },
      {
        'icon': Icons.pest_control_rounded,
        'color': 0xFFE74C3C,
        'bg': 0xFFFFEBEE,
        'tag': 'अलर्ट',
        'tagColor': 0xFFE74C3C,
        'title': 'कीट चेतावनी',
        'desc': 'राजस्थान में टिड्डी दल देखा गया है। पास के किसान भाई सतर्क रहें।',
        'fullDesc': '''🦗 कीट चेतावनी — टिड्डी दल

राजस्थान और गुजरात में टिड्डी दल देखे गए हैं।

📌 तुरंत करें ये काम:

- सुबह जल्दी क्लोरपाइरीफॉस 20% EC का छिड़काव करें
- शोर मचाने वाले उपकरण इस्तेमाल करें
- अपने जिले के कृषि विभाग से संपर्क करें
- हेल्पलाइन: 1800-180-1551

🗺️ प्रभावित जिले:
बाड़मेर, जैसलमेर, बीकानेर (राजस्थान)
कच्छ, बनासकांठा (गुजरात)

⚠️ खतरे में फसलें: गेहूं, सरसों, सब्जियां''',
      },
      {
        'icon': Icons.currency_rupee_rounded,
        'color': 0xFF1B8F5A,
        'bg': 0xFFE8F5E9,
        'tag': 'नीति',
        'tagColor': 0xFF1B8F5A,
        'title': 'MSP अपडेट 2024',
        'desc': 'सरकार ने खरीफ फसलों का न्यूनतम समर्थन मूल्य 8% बढ़ाया।',
        'fullDesc': '''📢 MSP अपडेट — खरीफ 2024-25

भारत सरकार ने खरीफ फसलों का न्यूनतम समर्थन मूल्य बढ़ाया है।

💰 नई MSP दरें:

- धान (सामान्य): ₹2,183/क्विंटल (+5.3%)
- ज्वार (हाइब्रिड): ₹3,371/क्विंटल (+7.6%)
- बाजरा: ₹2,500/क्विंटल (+7.5%)
- मक्का: ₹2,090/क्विंटल (+5.8%)
- मूंग: ₹8,682/क्विंटल (+10.4%)
- कपास (मध्यम): ₹7,121/क्विंटल (+8.3%)

📌 MSP का फायदा कैसे लें:
1. नजदीकी APMC मंडी में रजिस्टर करें
2. आधार + जमीन के कागज साथ लाएं
3. सरकारी खरीद केंद्र पर बेचें

हेल्पलाइन: 1800-270-0224 (टोल फ्री)''',
      },
    ],
    'मराठी': [
      {
        'icon': Icons.wb_sunny_rounded,
        'color': 0xFFE67E22,
        'bg': 0xFFFFF3E0,
        'tag': 'हवामान',
        'tagColor': 0xFFE67E22,
        'title': 'पावसाळी सूचना',
        'desc': 'या आठवड्यात मुसळधार पाऊस अपेक्षित आहे. पिकाला जलभराव व बुरशीपासून वाचवा.',
        'fullDesc': '''🌧️ पावसाळी सूचना — संपूर्ण माहिती

या आठवड्यात महाराष्ट्र, कर्नाटक आणि गोव्यात मुसळधार पाऊस होण्याची शक्यता आहे.

📌 शेतकरी बंधूंनी ही काळजी घ्यावी:

- शेतात पाणी साचू नये म्हणून चर स्वच्छ ठेवा
- मुसळधार पावसात कीटकनाशक किंवा खत फवारू नका
- पिकलेले पीक तात्काळ काढून घ्या
- साठवलेले धान्य ताडपत्रीने झाकून ठेवा
- बांध आणि शेताच्या सीमा तपासा
- भाताला करपा रोगापासून सावध राहा

🌡️ तापमान: 24°C - 29°C
💧 पावसाचा अंदाज: 80-120mm
📅 कालावधी: पुढील 5-7 दिवस

सुरक्षित राहा आणि दररोज पिकाची देखरेख करा!''',
      },
      {
        'icon': Icons.pest_control_rounded,
        'color': 0xFFE74C3C,
        'bg': 0xFFFFEBEE,
        'tag': 'इशारा',
        'tagColor': 0xFFE74C3C,
        'title': 'कीड सावधानता',
        'desc': 'राजस्थानमध्ये टोळधाड दिसून आली आहे. जवळच्या शेतकऱ्यांनी सतर्क राहावे.',
        'fullDesc': '''🦗 कीड सावधानता — टोळधाड

राजस्थान आणि गुजरातच्या काही भागात टोळधाड आढळली आहे.

📌 त्वरित करायच्या गोष्टी:

- सकाळी लवकर क्लोरपायरीफॉस 20% EC फवारा
- आवाज करणारी उपकरणे वापरा
- जिल्हा कृषी विभागाशी त्वरित संपर्क साधा
- हेल्पलाइन: 1800-180-1551

🗺️ प्रभावित जिल्हे:
बाडमेर, जैसलमेर, बीकानेर (राजस्थान)
कच्छ, बनासकांठा (गुजरात)

⚠️ धोक्यात असलेली पिके: गहू, मोहरी, भाजीपाला''',
      },
      {
        'icon': Icons.currency_rupee_rounded,
        'color': 0xFF1B8F5A,
        'bg': 0xFFE8F5E9,
        'tag': 'धोरण',
        'tagColor': 0xFF1B8F5A,
        'title': 'MSP अपडेट 2024',
        'desc': 'सरकारने खरीप पिकांचा किमान आधारभूत किंमत 8% वाढवला.',
        'fullDesc': '''📢 MSP अपडेट — खरीप 2024-25

भारत सरकारने खरीप पिकांचा किमान आधारभूत किंमत वाढवला आहे.

💰 नवीन MSP दर:

- भात (सामान्य): ₹2,183/क्विंटल (+5.3%)
- ज्वारी (हायब्रिड): ₹3,371/क्विंटल (+7.6%)
- बाजरी: ₹2,500/क्विंटल (+7.5%)
- मका: ₹2,090/क्विंटल (+5.8%)
- मूग: ₹8,682/क्विंटल (+10.4%)
- कापूस (मध्यम): ₹7,121/क्विंटल (+8.3%)

📌 MSP चा फायदा कसा घ्यावा:
1. जवळच्या APMC बाजार समितीत नोंदणी करा
2. आधार + जमिनीचे कागदपत्र सोबत आणा
3. शासकीय खरेदी केंद्रावर विक्री करा

हेल्पलाइन: 1800-270-0224 (टोल फ्री)''',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    loadWeather();
    _sunController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _sunController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    if (hour < 21) return 'Good Evening,';
    return 'Good Night,';
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.wb_cloudy_rounded;
    if (hour < 21) return Icons.nights_stay_rounded;
    return Icons.bedtime_rounded;
  }

  Future<void> loadWeather() async {
    try {
      final data = await WeatherService.getWeather();
      setState(() {
        weatherData = data;
        isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() => _selectedIndex = 0);
      return;
    }
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const MarketPlacePage()));
    } else if (index == 2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const LivestockPage()));
    } else if (index == 3) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => MarketTrendsPage()));
    } else if (index == 4) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ForumPage()));
    } else if (index == 5) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const BookingPage()));
    }
  }

  void _showFertilizerBuySheet(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
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
            Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2980B9).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.science_rounded,
                    color: Color(0xFF2980B9), size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  if (item['details'] != null)
                    Text(item['details'],
                        style: const TextStyle(
                            color: Colors.black45, fontSize: 13)),
                ],
              )),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2980B9).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF2980B9).withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Price',
                      style: TextStyle(color: Colors.black54, fontSize: 14)),
                  Text('₹${item['price']} / ${item['unit']}',
                      style: const TextStyle(
                          color: Color(0xFF2980B9),
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...[
              [Icons.verified_rounded, 'Government certified fertilizer'],
              [Icons.local_shipping_rounded, 'Home delivery available'],
              [Icons.currency_rupee_rounded, 'Subsidy applicable'],
            ].map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2980B9).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(f[0] as IconData,
                      color: const Color(0xFF2980B9), size: 16),
                ),
                const SizedBox(width: 10),
                Text(f[1] as String,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54)),
              ]),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ ${item['name']} order placed!'),
                      backgroundColor: const Color(0xFF2980B9),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart_rounded,
                    color: Colors.white, size: 18),
                label: const Text('Buy Now',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2980B9),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: isLoading
          ? _buildLoader()
          : weatherData == null
              ? _buildError()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeroSection(),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ AI Banner
                              _buildAiBanner(),
                              const SizedBox(height: 20),
                              _buildQuickActions(),
                              const SizedBox(height: 24),
                              _buildSectionHeader('Market Prices',
                                  Icons.trending_up_rounded, () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => MarketFullListPage()));
                              }),
                              const SizedBox(height: 12),
                              _marketHorizontalList(),
                              const SizedBox(height: 24),
                              _buildSectionHeader('Fertilizer Prices',
                                  Icons.science_rounded, () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => FertilizerFullListPage()));
                              }),
                              const SizedBox(height: 12),
                              _fertilizerHorizontalList(),
                              const SizedBox(height: 24),
                              _buildNewsSection(),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── APP BAR ──────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              'assets/images/bizkhetlogo.png',
              height: 30, width: 30,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                  Icons.grass_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 8),
          const Text('BizKhet',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20)),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 14,
              child: Icon(Icons.person_rounded,
                  color: Color(0xFF1B8F5A), size: 18),
            ),
          ),
          onSelected: (value) {
            if (value == 'register') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()));
            } else if (value == 'login') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginPage()));
            } else if (value == 'profile') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyProfilePage()));
            } else if (value == 'logout') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LogoutPage()));
            } else if (value == 'orders') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyOrdersPage()));
            } else if (value == 'settings') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()));
            } else if (value == 'admin') {
              Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminPanelPage()));
            }
          },
          itemBuilder: (context) => [
            if (Supabase.instance.client.auth.currentUser != null)
              _menuItem(Icons.admin_panel_settings_rounded, 'admin', 'Admin Panel'),
            _menuItem(Icons.person_add_rounded, 'register', 'Register'),
            _menuItem(Icons.login_rounded, 'login', 'Login'),
            const PopupMenuDivider(),
            _menuItem(Icons.account_circle_rounded, 'profile', 'My Profile'),
            _menuItem(Icons.shopping_bag_rounded, 'orders', 'My Orders'),
            _menuItem(Icons.settings_rounded, 'settings', 'Settings'),
            // Check karo user admin hai ya nahi
           
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: Row(children: const [
                Icon(Icons.logout_rounded, color: Colors.red, size: 18),
                SizedBox(width: 10),
                Text('Logout',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(
      IconData icon, String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, size: 18, color: const Color(0xFF1B8F5A)),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ]),
    );
  }

  // ── HERO SECTION ─────────────────────────────────────────────
  Widget _buildHeroSection() {
    final temp = weatherData!['main']['temp'];
    final desc = weatherData!['weather'][0]['description'];
    final humidity = weatherData!['main']['humidity'];
    final wind = weatherData!['wind']['speed'];

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A3D22), Color(0xFF0F5C35), Color(0xFF1B8F5A)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(_getGreeting(),
                  style: const TextStyle(color: Colors.white60, fontSize: 14)),
              Row(children: [
                const Text('Farmer! ',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                Icon(_getGreetingIcon(), color: Colors.white70, size: 20),
              ]),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.location_on_rounded,
                              color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          const Text('Mumbai, Maharashtra',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ]),
                        const SizedBox(height: 8),
                        Text('$temp°C',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                height: 1)),
                        const SizedBox(height: 4),
                        Text(desc,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 12),
                        Row(children: [
                          _weatherBadge(
                              Icons.water_drop_rounded, '$humidity%'),
                          const SizedBox(width: 10),
                          _weatherBadge(Icons.air_rounded, '${wind}km/h'),
                        ]),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _sunController,
                    builder: (_, child) => Transform.rotate(
                      angle: _sunController.value * 6.28,
                      child: child,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.wb_sunny_rounded,
                          color: Colors.orange, size: 48),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weatherBadge(IconData icon, String value) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 12)),
        ]),
      );

  // ✅ AI BANNER ─────────────────────────────────────────────────
  Widget _buildAiBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AiChatPage())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A3D22), Color(0xFF1B8F5A)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF1B8F5A).withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text('🌾', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KhetBot — AI Expert',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 3),
                Text('Farming ke sawaal? AI se poochein!',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Text('Chat Now',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
        ]),
      ),
    );
  }

  // ── QUICK ACTIONS ────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      {
        'label': 'Sell Crop',
        'icon': Icons.spa_rounded,
        'color': 0xFF1B8F5A,
        'bg': 0xFFE8F5E9
      },
      {
        'label': 'Book Tractor',
        'icon': Icons.agriculture_rounded,
        'color': 0xFF2980B9,
        'bg': 0xFFE3F2FD
      },
      {
        'label': 'Market',
        'icon': Icons.store_rounded,
        'color': 0xFFE67E22,
        'bg': 0xFFFFF3E0
      },
      {
        'label': 'KhetBot AI',
        'icon': Icons.smart_toy_rounded,
        'color': 0xFF1B8F5A,
        'bg': 0xFFE8F5E9
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 12),
        Row(
          children: actions.map((a) {
            final color = Color(a['color'] as int);
            final bg = Color(a['bg'] as int);
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (a['label'] == 'Sell Crop') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => SellCropFormPage(cropName: '')));
                  } else if (a['label'] == 'Book Tractor') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const BookTractorPage()));
                  } else if (a['label'] == 'Market') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const MarketPlacePage()));
                  } else if (a['label'] == 'KhetBot AI') {
                    // ✅ AI Chat page open
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const AiChatPage()));
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration:
                          BoxDecoration(color: bg, shape: BoxShape.circle),
                      child: Icon(a['icon'] as IconData,
                          color: color, size: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(a['label'] as String,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54),
                        textAlign: TextAlign.center),
                  ]),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      String title, IconData icon, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF1B8F5A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(icon, color: const Color(0xFF1B8F5A), size: 16),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ]),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1B8F5A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('View All',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _priceCard({
    required String title,
    String? subtitle,
    required String price,
    required String buttonText,
    required VoidCallback onButtonTap,
    Color accentColor = const Color(0xFF1B8F5A),
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.grass_rounded,
                color: accentColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: Colors.black38),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 8),
          Text(price,
              style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onButtonTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(buttonText,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _marketHorizontalList() {
    return SizedBox(
      height: 200,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: MarketService.getMarketData(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF1B8F5A)));
          }
          final data = snapshot.data!;
          final items =
              data.length > 5 ? data.sublist(0, 5) : data;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: 12),
            itemBuilder: (_, i) => _priceCard(
              title: items[i]['name'],
              price:
                  '${items[i]['pricePerQuintal']} ${items[i]['unit']}',
              buttonText: 'Sell',
              accentColor: const Color(0xFF1B8F5A),
              onButtonTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SellCropFormPage(
                          cropName: items[i]['name']))),
            ),
          );
        },
      ),
    );
  }

  Widget _fertilizerHorizontalList() {
    return SizedBox(
      height: 210,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: FertilizerService.getFertilizerData(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF1B8F5A)));
          }
          final data = snapshot.data!;
          final items =
              data.length > 5 ? data.sublist(0, 5) : data;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: 12),
            itemBuilder: (_, i) => _priceCard(
              title: data[i]['name'],
              subtitle: data[i]['details'],
              price: '₹${data[i]['price']} / ${data[i]['unit']}',
              buttonText: 'Buy',
              accentColor: const Color(0xFF2980B9),
              onButtonTap: () => _showFertilizerBuySheet(data[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsSection() {
    final currentNews = _newsData[_selectedLang]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B8F5A)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.newspaper_rounded,
                    color: Color(0xFF1B8F5A), size: 16),
              ),
              const SizedBox(width: 10),
              const Text('Agri News & Tips',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ]),
            GestureDetector(
              onTap: () => _showAllNewsSheet(currentNews),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B8F5A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('View All',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            children: _languages.map((lang) {
              final selected = _selectedLang == lang;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _selectedLang = lang),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF1B8F5A)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(lang,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: selected
                                ? Colors.white
                                : Colors.black45)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        ...currentNews.map((tip) {
          final color = Color(tip['color'] as int);
          final bg = Color(tip['bg'] as int);
          final tagColor = Color(tip['tagColor'] as int);
          return GestureDetector(
            onTap: () => _openNewsDetail(tip),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(children: [
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
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: bg,
                          borderRadius:
                              BorderRadius.circular(14)),
                      child: Icon(tip['icon'] as IconData,
                          color: color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: tagColor
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),
                            child: Text(tip['tag'] as String,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: tagColor)),
                          ),
                          const SizedBox(height: 5),
                          Text(tip['title'] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text(tip['desc'] as String,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black45,
                                  height: 1.4),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward_rounded,
                          color: color, size: 16),
                    ),
                  ]),
                ),
              ]),
            ),
          );
        }),
      ],
    );
  }

  void _openNewsDetail(Map<String, dynamic> tip) {
    final color = Color(tip['color'] as int);
    final bg = Color(tip['bg'] as int);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
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
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(tip['icon'] as IconData,
                      color: color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(tip['tag'] as String,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color)),
                    ),
                    const SizedBox(height: 5),
                    Text(tip['title'] as String,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                  ]),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          Colors.black.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        size: 18, color: Colors.black54),
                  ),
                ),
              ]),
            ),
            Container(
                height: 1,
                color: Colors.black.withValues(alpha: 0.06)),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Text(tip['fullDesc'] as String,
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.9)),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Got it!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _showAllNewsSheet(List<Map<String, dynamic>> tips) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, scrollController) => Container(
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
                  const Text('All Agri News & Tips',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
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
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: tips.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final tip = tips[i];
                  final color = Color(tip['color'] as int);
                  final bg = Color(tip['bg'] as int);
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _openNewsDetail(tip);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                            color:
                                color.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: bg,
                              borderRadius:
                                  BorderRadius.circular(12)),
                          child: Icon(
                              tip['icon'] as IconData,
                              color: color,
                              size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(tip['title'] as String,
                                style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 3),
                            Text(tip['desc'] as String,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45),
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis),
                          ],
                        )),
                        Icon(Icons.chevron_right_rounded,
                            color: color),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.store_rounded, 'label': 'Market'},
      {'icon': Icons.pets_rounded, 'label': 'Livestock'},
      {'icon': Icons.show_chart_rounded, 'label': 'Trends'},
      {'icon': Icons.forum_rounded, 'label': 'Forum'},
      {'icon': Icons.calendar_today_rounded, 'label': 'Booking'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final selected = _selectedIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onItemTapped(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF1B8F5A)
                                  .withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: selected
                              ? const Color(0xFF1B8F5A)
                              : Colors.black38,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(item['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: selected
                                ? const Color(0xFF1B8F5A)
                                : Colors.black38,
                          )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF1B8F5A)),
          SizedBox(height: 16),
          Text('Loading BizKhet...',
              style: TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded,
              size: 64, color: Colors.black26),
          const SizedBox(height: 12),
          const Text('Weather load nahi hua',
              style: TextStyle(color: Colors.black45)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() => isLoading = true);
              loadWeather();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B8F5A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Retry',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── FULL LIST PAGES ──────────────────────────────────────────
class MarketFullListPage extends StatelessWidget {
  const MarketFullListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5C35),
        foregroundColor: Colors.white,
        title: const Text('All Market Prices',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: MarketService.getMarketData(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF1B8F5A)));
          }
          final data = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: 12),
            itemBuilder: (_, i) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color:
                          Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B8F5A)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.grass_rounded,
                      color: Color(0xFF1B8F5A), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                  Text(data[i]['name'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  Text(
                      '${data[i]['pricePerQuintal']} ${data[i]['unit']}',
                      style: const TextStyle(
                          color: Color(0xFF1B8F5A),
                          fontWeight: FontWeight.bold)),
                ])),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SellCropFormPage(
                              cropName: data[i]['name']))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B8F5A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10)),
                  ),
                  child: const Text('Sell',
                      style: TextStyle(
                          fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class FertilizerFullListPage extends StatelessWidget {
  const FertilizerFullListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5C35),
        foregroundColor: Colors.white,
        title: const Text('All Fertilizer Prices',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: FertilizerService.getFertilizerData(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF1B8F5A)));
          }
          final data = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: 12),
            itemBuilder: (_, i) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color:
                          Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2980B9)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.science_rounded,
                      color: Color(0xFF2980B9), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                  Text(data[i]['name'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  if (data[i]['details'] != null)
                    Text(data[i]['details'],
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black38)),
                  Text(
                      '₹${data[i]['price']} / ${data[i]['unit']}',
                      style: const TextStyle(
                          color: Color(0xFF2980B9),
                          fontWeight: FontWeight.bold)),
                ])),
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (_) => Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(24)),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          Text(data[i]['name'],
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                              '₹${data[i]['price']} / ${data[i]['unit']}',
                              style: const TextStyle(
                                  color: Color(0xFF2980B9),
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold)),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      '✅ ${data[i]['name']} order placed!'),
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF2980B9),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            14)),
                                elevation: 0,
                              ),
                              child: const Text('Confirm Order',
                                  style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold)),
                            ),
                          ),
                        ]),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2980B9),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10)),
                  ),
                  child: const Text('Buy',
                      style: TextStyle(
                          fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

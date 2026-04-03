// services/market_service.dart
class MarketService {
  // -------------------- ASYNC FULL MARKET DATA --------------------
  static Future<List<Map<String, dynamic>>> getMarketData() async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network delay
    return getMarketDataList();
  }

  // -------------------- SYNC LIST WITH YESTERDAY PRICE --------------------
  static List<Map<String, dynamic>> getMarketDataList() {
    return [
      {"name": "Wheat", "pricePerQuintal": 2200, "unit": "₹/quintal", "yesterdayPrice": 2150},
      {"name": "Rice", "pricePerQuintal": 3500, "unit": "₹/quintal", "yesterdayPrice": 3550},
      {"name": "Maize", "pricePerQuintal": 1800, "unit": "₹/quintal", "yesterdayPrice": 1780},
      {"name": "Sugarcane", "pricePerQuintal": 3000, "unit": "₹/quintal", "yesterdayPrice": 2950},
      {"name": "Barley", "pricePerQuintal": 2000, "unit": "₹/quintal", "yesterdayPrice": 1980},
      {"name": "Oats", "pricePerQuintal": 2400, "unit": "₹/quintal", "yesterdayPrice": 2350},
      {"name": "Sorghum", "pricePerQuintal": 2100, "unit": "₹/quintal", "yesterdayPrice": 2120},
      {"name": "Cotton", "pricePerQuintal": 5000, "unit": "₹/quintal", "yesterdayPrice": 4900},
      {"name": "Soybean", "pricePerQuintal": 4000, "unit": "₹/quintal", "yesterdayPrice": 4050},
      {"name": "Groundnut", "pricePerQuintal": 4200, "unit": "₹/quintal", "yesterdayPrice": 4150},
      {"name": "Sunflower", "pricePerQuintal": 3800, "unit": "₹/quintal", "yesterdayPrice": 3750},
      {"name": "Mustard", "pricePerQuintal": 3600, "unit": "₹/quintal", "yesterdayPrice": 3550},
      {"name": "Tomato", "pricePerQuintal": 40, "unit": "₹/kg", "yesterdayPrice": 38},
      {"name": "Potato", "pricePerQuintal": 25, "unit": "₹/kg", "yesterdayPrice": 26},
      {"name": "Onion", "pricePerQuintal": 35, "unit": "₹/kg", "yesterdayPrice": 33},
      {"name": "Cabbage", "pricePerQuintal": 30, "unit": "₹/kg", "yesterdayPrice": 28},
      {"name": "Cauliflower", "pricePerQuintal": 50, "unit": "₹/kg", "yesterdayPrice": 52},
      {"name": "Carrot", "pricePerQuintal": 45, "unit": "₹/kg", "yesterdayPrice": 44},
      {"name": "Brinjal", "pricePerQuintal": 25, "unit": "₹/kg", "yesterdayPrice": 26},
      {"name": "Chili", "pricePerQuintal": 120, "unit": "₹/kg", "yesterdayPrice": 115},
      {"name": "Garlic", "pricePerQuintal": 150, "unit": "₹/kg", "yesterdayPrice": 148},
      {"name": "Ginger", "pricePerQuintal": 160, "unit": "₹/kg", "yesterdayPrice": 155},
      {"name": "Coriander", "pricePerQuintal": 80, "unit": "₹/kg", "yesterdayPrice": 78},
      {"name": "Mint", "pricePerQuintal": 70, "unit": "₹/kg", "yesterdayPrice": 68},
      {"name": "Cucumber", "pricePerQuintal": 20, "unit": "₹/kg", "yesterdayPrice": 19},
      {"name": "Pumpkin", "pricePerQuintal": 18, "unit": "₹/kg", "yesterdayPrice": 18},
      {"name": "Bitter Gourd", "pricePerQuintal": 35, "unit": "₹/kg", "yesterdayPrice": 36},
      {"name": "Bottle Gourd", "pricePerQuintal": 28, "unit": "₹/kg", "yesterdayPrice": 27},
      {"name": "Ladyfinger", "pricePerQuintal": 22, "unit": "₹/kg", "yesterdayPrice": 22},
      {"name": "Spinach", "pricePerQuintal": 15, "unit": "₹/kg", "yesterdayPrice": 14},
      {"name": "Fenugreek", "pricePerQuintal": 50, "unit": "₹/kg", "yesterdayPrice": 51},
      {"name": "Radish", "pricePerQuintal": 20, "unit": "₹/kg", "yesterdayPrice": 19},
      {"name": "Beetroot", "pricePerQuintal": 25, "unit": "₹/kg", "yesterdayPrice": 24},
      {"name": "Apple", "pricePerQuintal": 120, "unit": "₹/kg", "yesterdayPrice": 118},
      {"name": "Banana", "pricePerQuintal": 50, "unit": "₹/kg", "yesterdayPrice": 50},
      {"name": "Mango", "pricePerQuintal": 200, "unit": "₹/kg", "yesterdayPrice": 190},
      {"name": "Orange", "pricePerQuintal": 80, "unit": "₹/kg", "yesterdayPrice": 78},
      {"name": "Grapes", "pricePerQuintal": 180, "unit": "₹/kg", "yesterdayPrice": 175},
      {"name": "Papaya", "pricePerQuintal": 60, "unit": "₹/kg", "yesterdayPrice": 58},
      {"name": "Pineapple", "pricePerQuintal": 90, "unit": "₹/kg", "yesterdayPrice": 88},
      {"name": "Watermelon", "pricePerQuintal": 25, "unit": "₹/kg", "yesterdayPrice": 24},
      {"name": "Muskmelon", "pricePerQuintal": 30, "unit": "₹/kg", "yesterdayPrice": 29},
      {"name": "Strawberry", "pricePerQuintal": 500, "unit": "₹/kg", "yesterdayPrice": 480},
      {"name": "Blueberry", "pricePerQuintal": 700, "unit": "₹/kg", "yesterdayPrice": 680},
      {"name": "Pomegranate", "pricePerQuintal": 150, "unit": "₹/kg", "yesterdayPrice": 148},
      {"name": "Guava", "pricePerQuintal": 80, "unit": "₹/kg", "yesterdayPrice": 78},
      {"name": "Jackfruit", "pricePerQuintal": 40, "unit": "₹/kg", "yesterdayPrice": 42},
      {"name": "Lychee", "pricePerQuintal": 300, "unit": "₹/kg", "yesterdayPrice": 290},
      {"name": "Kiwi", "pricePerQuintal": 600, "unit": "₹/kg", "yesterdayPrice": 580},
      {"name": "Peach", "pricePerQuintal": 250, "unit": "₹/kg", "yesterdayPrice": 240},
      {"name": "Plum", "pricePerQuintal": 200, "unit": "₹/kg", "yesterdayPrice": 198},
      {"name": "Cherry", "pricePerQuintal": 800, "unit": "₹/kg", "yesterdayPrice": 780},
    ];
  }

  // -------------------- GET DATA FOR SPECIFIC CROP --------------------
  static Map<String, dynamic> getMarketDataForCrop(String cropName) {
    return getMarketDataList().firstWhere(
      (element) => element['name'].toString().toLowerCase() == cropName.toLowerCase(),
      orElse: () => {
        'name': cropName,
        'pricePerQuintal': 0,
        'unit': '₹/quintal',
        'yesterdayPrice': 0,
      },
    );
  }

  // -------------------- CALCULATE TREND --------------------
  static String calculateTrend(int todayPrice, int yesterdayPrice) {
    if (todayPrice > yesterdayPrice) return "Aaj rate badhne ke chances 📈";
    if (todayPrice < yesterdayPrice) return "Aaj rate girne ke chances 📉";
    return "Rate stable hai ➖";
  }

  // -------------------- SUGGESTED PRICE RANGE --------------------
  static String suggestedPriceRange(int currentPrice) {
    int lower = currentPrice + 100;
    int upper = currentPrice + 300;
    return "₹$lower – ₹$upper / quintal";
  }
}

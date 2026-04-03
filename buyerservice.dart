class BuyerService {
  // Mock buyers for crop
  static Future<List<Map<String, dynamic>>> getBuyerRequests(String cropName) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network call
    return [
      {"name": "Trader A", "offeredPrice": 2300, "unit": "₹/quintal", "distance": 5, "rating": 4},
      {"name": "Trader B", "offeredPrice": 2250, "unit": "₹/quintal", "distance": 12, "rating": 5},
      {"name": "Trader C", "offeredPrice": 2350, "unit": "₹/quintal", "distance": 8, "rating": 3},
    ];
  }
}

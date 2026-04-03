class FertilizerService {
  static Future<List<Map<String, dynamic>>> getFertilizerData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      {"name": "Urea", "price": 266, "unit": "45kg", "details": "Nitrogen rich"},
      {"name": "DAP", "price": 1350, "unit": "50kg", "details": "Phosphorus rich"},
      {"name": "MOP", "price": 1700, "unit": "50kg", "details": "Potassium"},
      {"name": "NPK 19:19:19", "price": 1450, "unit": "50kg", "details": "Balanced"},
      {"name": "SSP", "price": 450, "unit": "50kg", "details": "Sulphur source"},
      {"name": "Calcium Nitrate", "price": 1200, "unit": "25kg", "details": "Crop quality"},
      {"name": "Magnesium Sulphate", "price": 800, "unit": "25kg", "details": "Leaf growth"},
      {"name": "Zinc Sulphate", "price": 950, "unit": "25kg", "details": "Micronutrient"},
      {"name": "Boron", "price": 720, "unit": "10kg", "details": "Flowering"},
      {"name": "Sulphur Powder", "price": 600, "unit": "25kg", "details": "Soil health"},
      {"name": "Neem Cake", "price": 900, "unit": "50kg", "details": "Organic"},
      {"name": "Bio Potash", "price": 1100, "unit": "50kg", "details": "Organic"},
      {"name": "Bio Nitrogen", "price": 850, "unit": "50kg", "details": "Organic"},
      {"name": "Humic Acid", "price": 1300, "unit": "20kg", "details": "Root growth"},
      {"name": "Seaweed Granules", "price": 1600, "unit": "25kg", "details": "Growth booster"},
      {"name": "DAP Liquid", "price": 980, "unit": "20L", "details": "Fast absorption"},
      {"name": "NPK 12:32:16", "price": 1480, "unit": "50kg", "details": "High yield"},
      {"name": "Potash Liquid", "price": 1150, "unit": "20L", "details": "Fruit quality"},
      {"name": "Iron Chelate", "price": 1750, "unit": "5kg", "details": "Iron deficiency"},
      {"name": "Micronutrient Mix", "price": 890, "unit": "10kg", "details": "Complete mix"},
      // 👉 easily extendable (no limit)
    ];
  }
}

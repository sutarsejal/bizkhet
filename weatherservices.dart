import 'dart:convert';
import 'package:http/http.dart' as http;


class WeatherService {

  // 🔑 YAHAN API KEY DAALO
  static const String apiKey = "f41bf3e1edb5708cc3599293922872da";

  static const String city = "Mumbai";

  static Future<Map<String, dynamic>> getWeather() async {

    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Weather data load nahi hua");
    }
  }
}

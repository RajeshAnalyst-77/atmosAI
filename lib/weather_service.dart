import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = '4fc7da743a0dc6bf4d3b9b579ddd179b'; // replace with your key

  static Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$_apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }
}

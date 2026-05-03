import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "Your Api Key";
  final String baseUrl = "https://api.openweathermap.org/data/2.5";

  Future<Map<String, dynamic>> fetchWeather(String city, {String units = 'metric'}) async {
    final url = "$baseUrl/weather?q=$city&appid=$apiKey&units=$units";
    return _getResponse(url);
  }

  Future<Map<String, dynamic>> fetchWeatherByLocation(double lat, double lon, {String units = 'metric'}) async {
    final url = "$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=$units";
    return _getResponse(url);
  }

  Future<Map<String, dynamic>> fetchAirQuality(double lat, double lon) async {
    final url = "$baseUrl/air_pollution?lat=$lat&lon=$lon&appid=$apiKey";
    return _getResponse(url);
  }

  Future<Map<String, dynamic>> fetchForecast(String city, {String units = 'metric'}) async {
    final url = "$baseUrl/forecast?q=$city&appid=$apiKey&units=$units";
    return _getResponse(url);
  }

  Future<Map<String, dynamic>> fetchForecastByLocation(double lat, double lon, {String units = 'metric'}) async {
    final url = "$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=$units";
    return _getResponse(url);
  }

  Future<Map<String, dynamic>> _getResponse(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load weather data: ${response.reasonPhrase}");
    }
  }
}

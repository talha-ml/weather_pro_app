import 'package:intl/intl.dart';

class Weather {
  final String city;
  final double temp;
  final String description;
  final String mainCondition;
  final double humidity;
  final double windSpeed;
  final double windDeg;
  final double feelsLike;
  final double lat;
  final double lon;
  final int? aqi;
  final DateTime sunrise;
  final DateTime sunset;
  final double pressure;
  final double visibility;
  final double? rainChance;
  final DateTime lastUpdated;

  Weather({
    required this.city,
    required this.temp,
    required this.description,
    required this.mainCondition,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.feelsLike,
    required this.lat,
    required this.lon,
    this.aqi,
    required this.sunrise,
    required this.sunset,
    required this.pressure,
    required this.visibility,
    this.rainChance,
    required this.lastUpdated,
  });

  factory Weather.fromJson(Map<String, dynamic> json, {int? aqi}) {
    // Rain handling (OpenWeather returns it as rain['1h'] or rain['3h'])
    double? rain = 0;
    if (json['rain'] != null) {
      if (json['rain']['1h'] != null) {
        rain = (json['rain']['1h'] as num).toDouble();
      } else if (json['rain']['3h'] != null) {
        rain = (json['rain']['3h'] as num).toDouble();
      }
    }

    return Weather(
      city: json['name'] ?? 'Unknown',
      temp: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      mainCondition: json['weather'][0]['main'] ?? 'Clear',
      humidity: (json['main']['humidity'] as num).toDouble(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      windDeg: (json['wind']['deg'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      lat: (json['coord']['lat'] as num).toDouble(),
      lon: (json['coord']['lon'] as num).toDouble(),
      aqi: aqi,
      sunrise: DateTime.fromMillisecondsSinceEpoch((json['sys']['sunrise'] ?? 0) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch((json['sys']['sunset'] ?? 0) * 1000),
      pressure: (json['main']['pressure'] as num).toDouble(),
      visibility: (json['visibility'] as num).toDouble() / 1000, // to km
      rainChance: rain,
      lastUpdated: DateTime.now(),
    );
  }

  Weather copyWith({int? aqi}) {
    return Weather(
      city: city,
      temp: temp,
      description: description,
      mainCondition: mainCondition,
      humidity: humidity,
      windSpeed: windSpeed,
      windDeg: windDeg,
      feelsLike: feelsLike,
      lat: lat,
      lon: lon,
      aqi: aqi ?? this.aqi,
      sunrise: sunrise,
      sunset: sunset,
      pressure: pressure,
      visibility: visibility,
      rainChance: rainChance,
      lastUpdated: DateTime.now(),
    );
  }
}

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

final weatherServiceProvider = Provider((ref) => WeatherService());

final unitProvider = StateProvider<String>((ref) => 'metric');

// Provider to manage search history
final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList('search_history') ?? [];
  }

  Future<void> addCity(String city) async {
    final normalizedCity = city.trim();
    if (normalizedCity.isEmpty) return;
    
    final newState = [normalizedCity, ...state.where((c) => c.toLowerCase() != normalizedCity.toLowerCase())].take(5).toList();
    state = newState;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', state);
  }
}

final weatherStateProvider = StateNotifierProvider<WeatherNotifier, AsyncValue<Weather?>>((ref) {
  return WeatherNotifier(ref.watch(weatherServiceProvider), ref);
});

class WeatherNotifier extends StateNotifier<AsyncValue<Weather?>> {
  final WeatherService _service;
  final Ref _ref;

  WeatherNotifier(this._service, this._ref) : super(const AsyncValue.data(null));

  Future<void> fetchWeatherByCity(String city) async {
    state = const AsyncValue.loading();
    try {
      final unit = _ref.read(unitProvider);
      final weatherData = await _service.fetchWeather(city, units: unit);
      final weather = Weather.fromJson(weatherData);
      
      final aqiData = await _service.fetchAirQuality(weather.lat, weather.lon);
      final aqiValue = aqiData['list'][0]['main']['aqi'];
      
      state = AsyncValue.data(weather.copyWith(aqi: aqiValue));
      
      // Save to history and last city
      _ref.read(searchHistoryProvider.notifier).addCity(city);
      _saveLastCity(city);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> fetchWeatherByLocation() async {
    state = const AsyncValue.loading();
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        final unit = _ref.read(unitProvider);
        final weatherData = await _service.fetchWeatherByLocation(position.latitude, position.longitude, units: unit);
        final weather = Weather.fromJson(weatherData);
        
        final aqiData = await _service.fetchAirQuality(position.latitude, position.longitude);
        final aqiValue = aqiData['list'][0]['main']['aqi'];

        state = AsyncValue.data(weather.copyWith(aqi: aqiValue));
      } else {
        state = AsyncValue.error("Location permission denied", StackTrace.current);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _saveLastCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_city', city);
  }

  Future<void> loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    final city = prefs.getString('last_city');
    if (city != null) {
      fetchWeatherByCity(city);
    } else {
      fetchWeatherByLocation();
    }
  }
}

final forecastProvider = FutureProvider.family<List<dynamic>, String?>((ref, city) async {
  final service = ref.watch(weatherServiceProvider);
  final unit = ref.watch(unitProvider);
  if (city == null || city.isEmpty) return [];
  final data = await service.fetchForecast(city, units: unit);
  return data['list'];
});

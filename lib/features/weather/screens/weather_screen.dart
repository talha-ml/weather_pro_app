import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(weatherStateProvider.notifier).loadLastCity());
  }

  List<Color> _getBackgroundColors(String condition) {
    switch (condition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return [const Color(0xFF607D8B), const Color(0xFF90A4AE)];
      case 'rain':
      case 'drizzle':
        return [const Color(0xFF263238), const Color(0xFF455A64)];
      case 'thunderstorm':
        return [const Color(0xFF000000), const Color(0xFF37474F)];
      case 'snow':
        return [const Color(0xFFB0BEC5), const Color(0xFFECEFF1)];
      case 'clear':
        return [const Color(0xFF2196F3), const Color(0xFF90CAF9)];
      default:
        return [const Color(0xFF1A237E), const Color(0xFF3949AB)];
    }
  }

  String _getWeatherAnimation(String condition) {
    switch (condition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'https://assets5.lottiefiles.com/temp/lf20_S9S1pe.json';
      case 'rain':
      case 'drizzle':
        return 'https://assets5.lottiefiles.com/temp/lf20_rpC1Rd.json';
      case 'thunderstorm':
        return 'https://assets5.lottiefiles.com/temp/lf20_KuotS6.json';
      case 'snow':
        return 'https://assets5.lottiefiles.com/temp/lf20_BS9ulY.json';
      case 'clear':
        return 'https://assets5.lottiefiles.com/temp/lf20_Stda6L.json';
      default:
        return 'https://assets5.lottiefiles.com/temp/lf20_Stda6L.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherStateProvider);
    final unit = ref.watch(unitProvider);
    final searchHistory = ref.watch(searchHistoryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Weather Pro", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          TextButton(
            onPressed: () {
              final newUnit = unit == 'metric' ? 'imperial' : 'metric';
              ref.read(unitProvider.notifier).state = newUnit;
              final weather = ref.read(weatherStateProvider).value;
              if (weather != null) {
                ref.read(weatherStateProvider.notifier).fetchWeatherByCity(weather.city);
              }
            },
            child: Text(
              unit == 'metric' ? "°C" : "°F",
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: () =>
                ref.read(weatherStateProvider.notifier).fetchWeatherByLocation(),
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: weatherAsync.maybeWhen(
                  data: (w) => w != null ? _getBackgroundColors(w.mainCondition) : [const Color(0xFF1A237E), const Color(0xFF3949AB)],
                  orElse: () => [const Color(0xFF1A237E), const Color(0xFF3949AB)],
                ),
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildSearchBar(),
                  if (searchHistory.isNotEmpty && weatherAsync is! AsyncLoading)
                    _buildSearchHistory(searchHistory),
                  const SizedBox(height: 10),
                  weatherAsync.when(
                    data: (weather) => weather == null
                        ? _buildEmptyState()
                        : Expanded(
                            child: RefreshIndicator(
                              onRefresh: () => ref.read(weatherStateProvider.notifier).fetchWeatherByCity(weather.city),
                              color: Colors.white,
                              backgroundColor: Colors.transparent,
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    _buildCurrentWeather(weather),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Last updated: ${DateFormat.jm().format(weather.lastUpdated)}",
                                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildAQIIndicator(weather.aqi),
                                    const SizedBox(height: 20),
                                    _buildHourlyForecast(weather.city),
                                    const SizedBox(height: 20),
                                    _buildPrimaryDetails(weather, unit),
                                    const SizedBox(height: 20),
                                    _buildWindAndSunSection(weather),
                                    const SizedBox(height: 20),
                                    _buildSecondaryDetails(weather),
                                    const SizedBox(height: 30),
                                    _buildForecastSection(weather.city),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    loading: () => const Expanded(child: WeatherShimmer()),
                    error: (err, stack) => Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_off, color: Colors.white54, size: 80),
                            const SizedBox(height: 16),
                            const Text(
                              "City not found or network error.",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
                              onPressed: () => ref.read(weatherStateProvider.notifier).loadLastCity(),
                              child: const Text("Retry", style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search City (e.g. Islamabad)...",
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            ref.read(weatherStateProvider.notifier).fetchWeatherByCity(value);
            _controller.clear();
          }
        },
      ),
    );
  }

  Widget _buildSearchHistory(List<String> history) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: history.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              backgroundColor: Colors.white10,
              label: Text(history[index], style: const TextStyle(color: Colors.white, fontSize: 12)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: () {
                ref.read(weatherStateProvider.notifier).fetchWeatherByCity(history[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Expanded(
      child: Center(
        child: Text(
          "Enter a city to explore weather",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildCurrentWeather(Weather weather) {
    return Column(
      children: [
        Text(
          weather.city,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          DateFormat('EEEE, d MMMM').format(DateTime.now()),
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        SizedBox(
          height: 180,
          child: Lottie.network(
            _getWeatherAnimation(weather.mainCondition),
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.wb_sunny, size: 100, color: Colors.orangeAccent),
          ),
        ),
        Text(
          "${weather.temp.round()}°",
          style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w200, color: Colors.white),
        ),
        Text(
          weather.description.toUpperCase(),
          style: const TextStyle(fontSize: 18, letterSpacing: 3, color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAQIIndicator(int? aqi) {
    if (aqi == null) return const SizedBox.shrink();
    final List<String> statuses = ["Excellent", "Fair", "Moderate", "Poor", "Very Poor"];
    final List<Color> colors = [Colors.greenAccent, Colors.yellowAccent, Colors.orangeAccent, Colors.redAccent, Colors.purpleAccent];
    
    String status = aqi >= 1 && aqi <= 5 ? statuses[aqi - 1] : "Unknown";
    Color color = aqi >= 1 && aqi <= 5 ? colors[aqi - 1] : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.air, color: color, size: 18),
          const SizedBox(width: 8),
          Text("AQI: $status", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(String city) {
    final forecastAsync = ref.watch(forecastProvider(city));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Hourly Forecast", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          forecastAsync.when(
            data: (list) {
              final hourlyData = list.take(8).toList();
              return Column(
                children: [
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: hourlyData.length,
                      itemBuilder: (context, index) {
                        final item = hourlyData[index];
                        final time = DateTime.parse(item['dt_txt']);
                        return Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(DateFormat.j().format(time), style: const TextStyle(color: Colors.white70, fontSize: 10)),
                              const SizedBox(height: 5),
                              _getMiniIcon(item['weather'][0]['main']),
                              const SizedBox(height: 5),
                              Text("${(item['main']['temp'] as num).round()}°", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 80,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: hourlyData.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), (e.value['main']['temp'] as num).toDouble());
                            }).toList(),
                            isCurved: true,
                            color: Colors.white,
                            barWidth: 2,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: true, color: Colors.white.withOpacity(0.1)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const Center(child: Text("Hourly data unavailable", style: TextStyle(color: Colors.white54))),
          ),
        ],
      ),
    );
  }

  Widget _buildWindAndSunSection(Weather weather) {
    return Row(
      children: [
        // Wind Compass
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(25)),
            child: Column(
              children: [
                const Text("Wind", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 60, width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                    ),
                    Transform.rotate(
                      angle: (weather.windDeg * pi) / 180,
                      child: const Icon(Icons.navigation, color: Colors.white, size: 30),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text("${weather.windSpeed} km/h", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        // Sunrise/Sunset Visual
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(25)),
            child: Column(
              children: [
                const Text("Sun Schedule", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _sunTime(Icons.wb_twilight, weather.sunrise, "Rise"),
                    _sunTime(Icons.wb_sunny_outlined, weather.sunset, "Set"),
                  ],
                ),
                const SizedBox(height: 10),
                Text("Total Day: ${_calculateDayLength(weather.sunrise, weather.sunset)}", 
                  style: const TextStyle(color: Colors.white60, fontSize: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sunTime(IconData icon, DateTime time, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.yellowAccent, size: 20),
        const SizedBox(height: 5),
        Text(DateFormat.jm().format(time), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  String _calculateDayLength(DateTime rise, DateTime set) {
    final diff = set.difference(rise);
    return "${diff.inHours}h ${diff.inMinutes % 60}m";
  }

  Widget _buildPrimaryDetails(Weather weather, String unit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoItem(FontAwesomeIcons.droplet, "${weather.humidity}%", "Humidity"),
          _infoItem(FontAwesomeIcons.temperatureLow, "${weather.feelsLike.round()}°", "Feels Like"),
          _infoItem(FontAwesomeIcons.cloudRain, "${(weather.rainChance ?? 0).toStringAsFixed(1)} mm", "Rain (1h)"),
        ],
      ),
    );
  }

  Widget _buildSecondaryDetails(Weather weather) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _gridItemSimple(Icons.compress, "${weather.pressure} hPa", "Pressure"),
          _gridItemSimple(Icons.visibility_outlined, "${weather.visibility.toStringAsFixed(1)} km", "Visibility"),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        FaIcon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _gridItemSimple(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        )
      ],
    );
  }

  Widget _buildForecastSection(String city) {
    final forecastAsync = ref.watch(forecastProvider(city));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Next 5 Days", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 15),
        forecastAsync.when(
          data: (list) {
            final dailyData = list.where((item) => item['dt_txt'].contains("12:00:00")).toList();
            return Column(
              children: dailyData.map((item) {
                final date = DateTime.parse(item['dt_txt']);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(DateFormat('EEEE').format(date), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      ),
                      Expanded(
                        child: _getMiniIcon(item['weather'][0]['main']),
                      ),
                      Expanded(
                        child: Text("${(item['main']['temp_min'] as num).round()}° / ${(item['main']['temp_max'] as num).round()}°", 
                          style: const TextStyle(color: Colors.white70, fontSize: 13), textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => const Text("Forecast unavailable", style: TextStyle(color: Colors.white54)),
        ),
      ],
    );
  }

  Widget _getMiniIcon(String condition) {
    IconData icon = FontAwesomeIcons.cloud;
    Color color = Colors.white;
    if (condition.toLowerCase() == 'clear') { icon = FontAwesomeIcons.sun; color = Colors.yellowAccent; }
    if (condition.toLowerCase() == 'rain') { icon = FontAwesomeIcons.cloudRain; color = Colors.lightBlueAccent; }
    return FaIcon(icon, size: 24, color: color);
  }
}

class WeatherShimmer extends StatelessWidget {
  const WeatherShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white10,
      highlightColor: Colors.white24,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(height: 40, width: 150, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Container(height: 180, width: 180, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(height: 20),
            Container(height: 100, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25))),
            const SizedBox(height: 20),
            Container(height: 150, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25))),
          ],
        ),
      ),
    );
  }
}

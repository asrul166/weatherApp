import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../pages/weather_detail_page.dart';
import '../services/weather_api_service.dart';
import '../widgets/weather_card.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherApiService _api = WeatherApiService();
  WeatherModel? myLocationWeather;
  List<String> favoriteCities = [];
  List<WeatherModel> favoriteWeathers = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    await _loadMyLocation();
    await _loadFavorites();

    setState(() => isLoading = false);
  }

  Future<void> _loadMyLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    myLocationWeather =
        await _api.fetchCurrentWeatherByCoords(pos.latitude, pos.longitude);
    // ubah namanya jadi My Location
    myLocationWeather = myLocationWeather!.copyWith(city: "My Location");
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    favoriteCities = prefs.getStringList('favorites') ?? [];

    favoriteWeathers.clear();
    for (var city in favoriteCities) {
      try {
        final w = await _api.fetchCurrentWeather(city);
        favoriteWeathers.add(w);
      } catch (_) {}
    }
  }

  Future<void> _removeFavorite(String city) async {
    favoriteCities.remove(city);
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorites', favoriteCities);
    await _loadFavorites();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuaca Sekarang'),
        actions: [
          Switch(
            value: widget.isDarkMode,
            onChanged: (_) => widget.onThemeToggle(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                children: [
                  if (myLocationWeather != null)
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WeatherDetailPage(weather: myLocationWeather!),
                        ),
                      ),
                      child: WeatherCard(data: myLocationWeather!),
                    ),
                  ...favoriteWeathers.map(
                    (w) => Dismissible(
                      key: Key(w.city),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _removeFavorite(w.city),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WeatherDetailPage(weather: w),
                          ),
                        ),
                        child: WeatherCard(data: w),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

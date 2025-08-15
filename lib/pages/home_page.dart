import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_api_service.dart';
import '../widgets/weather_card.dart';
import 'weather_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherApiService _api = WeatherApiService();
  bool isLoading = true;
  List<WeatherModel> favoriteWeathers = [];
  WeatherModel? myLocationWeather;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() => isLoading = true);

    try {
      Position? position;
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) throw Exception("Location service off");

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw Exception("Location denied");
          }
        }

        position = await Geolocator.getCurrentPosition();
      } catch (_) {
        print("GPS gagal, pakai kota default Jakarta");
      }

      if (position != null) {
        myLocationWeather = await _api.fetchCurrentWeatherByCoords(
            position.latitude, position.longitude);
      } else {
        myLocationWeather = await _api.fetchCurrentWeather("Jakarta");
      }
      final prefs = await SharedPreferences.getInstance();
      final favCities = prefs.getStringList('favorites') ?? [];
      favoriteWeathers = [];
      for (String city in favCities) {
        try {
          final weather = await _api.fetchCurrentWeather(city);
          favoriteWeathers.add(weather);
        } catch (e) {
          print("Gagal ambil cuaca $city: $e");
        }
      }
    } catch (e) {
      print("Error load weather: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cuaca Sekarang"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeather,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (myLocationWeather != null) ...[
                  const Text("Lokasi Saya",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  WeatherCard(
                    weather: myLocationWeather!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WeatherDetailPage(
                            weather: myLocationWeather!,
                          ),
                        ),
                      ).then((_) => _loadWeather());
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                const Text("Kota Favorit",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (favoriteWeathers.isEmpty)
                  const Text("Belum ada kota favorit"),
                ...favoriteWeathers.map((weather) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: WeatherCard(
                        weather: weather,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WeatherDetailPage(
                                weather: weather,
                              ),
                            ),
                          ).then((_) => _loadWeather());
                        },
                      ),
                    )),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_api_service.dart';
import '../widgets/weather_card.dart';
import 'city_search_delegate.dart';
import 'weather_detail_page.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeToggle;

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
  WeatherModel? currentWeather;
  List<String> favorites = [];
  bool isLoadingCurrent = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _fetchCurrentLocationWeather();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  Future<void> searchCity() async {
    final result = await showSearch<String>(
      context: context,
      delegate: CitySearchDelegate(),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final weather = await _api.fetchCurrentWeather(result);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WeatherDetailPage(weather: weather),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal mencari kota"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _fetchCurrentLocationWeather() async {
    try {
      final weather = await _api.fetchCurrentWeatherByCoords();
      if (!mounted) return;
      setState(() {
        currentWeather = weather;
        isLoadingCurrent = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingCurrent = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuaca Sekarang'),
        actions: [
          Switch(
            value: widget.isDarkMode,
            onChanged: widget.onThemeToggle,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: searchCity,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCurrentLocationWeather,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isLoadingCurrent)
            const Center(child: CircularProgressIndicator())
          else if (currentWeather != null)
            WeatherCard(
              weather: currentWeather!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WeatherDetailPage(weather: currentWeather!),
                  ),
                );
              },
            )
          else
            const Text("Gagal memuat cuaca lokasi saat ini"),

          const SizedBox(height: 20),
          const Text(
            "Kota Favorit",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (favorites.isEmpty)
            const Text("Belum ada kota favorit")
          else
            Column(
              children: favorites.map((city) {
                return FutureBuilder<WeatherModel>(
                  future: _api.fetchCurrentWeather(city),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(8),
                        child: LinearProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return ListTile(title: Text("Gagal memuat $city"));
                    } else if (!snapshot.hasData) {
                      return ListTile(title: Text("Data kosong untuk $city"));
                    }
                    return WeatherCard(
                      weather: snapshot.data!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                WeatherDetailPage(weather: snapshot.data!),
                          ),
                        );
                      },
                    );
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

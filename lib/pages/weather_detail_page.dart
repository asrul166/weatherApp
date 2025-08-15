import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_api_service.dart';

class WeatherDetailPage extends StatefulWidget {
  final WeatherModel weather;

  const WeatherDetailPage({super.key, required this.weather});

  @override
  State<WeatherDetailPage> createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage> {
  final WeatherApiService _api = WeatherApiService();
  ForecastModel? forecast;
  bool isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadForecast();
    _checkFavorite();
  }

  Future<void> _loadForecast() async {
    try {
      final result =
          await _api.fetchForecast(widget.weather.lat, widget.weather.lon);
      setState(() {
        forecast = result;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? [];
    setState(() {
      isFavorite = favs.contains(widget.weather.city);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? [];

    if (isFavorite) {
      favs.remove(widget.weather.city);
    } else {
      favs.add(widget.weather.city);
    }

    await prefs.setStringList('favorites', favs);
    setState(() => isFavorite = !isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.weather.city),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            onPressed: _toggleFavorite,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : forecast == null
              ? const Center(child: Text("Gagal ambil ramalan cuaca"))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      "${widget.weather.temp.toStringAsFixed(1)}°C",
                      style: const TextStyle(
                          fontSize: 48, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.weather.description,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Info Cuaca 2 kolom per baris
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildInfoTile(
                            "Kelembapan", "${widget.weather.humidity}%"),
                        _buildInfoTile(
                            "Arah Angin", widget.weather.windDirection ?? "-"),
                        _buildInfoTile(
                            "Tekanan", "${widget.weather.pressure} hPa"),
                        _buildInfoTile(
                            "Kecepatan Angin",
                            "${widget.weather.windSpeed.toStringAsFixed(1)} m/s"),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Ramalan Harian",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...forecast!.daily.map((day) => ListTile(
                          title: Text(day.date as String),
                          subtitle: Text(day.description()),
                          trailing:
                              Text("${day.temp.toStringAsFixed(1)}°C"),
                        )),
                  ],
                ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Container(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

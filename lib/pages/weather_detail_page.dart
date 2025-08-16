import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      if (!mounted) return;
      setState(() {
        forecast = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? [];
    if (!mounted) return;
    setState(() {
      isFavorite = favs.contains(widget.weather.city);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? [];

    if (isFavorite) {
      favs.remove(widget.weather.city);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dihapus dari favorit")),
      );
    } else {
      favs.add(widget.weather.city);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ditambahkan ke favorit")),
      );
    }

    await prefs.setStringList('favorites', favs);
    if (!mounted) return;
    setState(() => isFavorite = !isFavorite);
  }

  String _formatDay(DateTime dt) {
    return DateFormat('EEE, d MMM', 'id_ID').format(dt);
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
                      "${widget.weather.temperature.toStringAsFixed(1)}°C",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.weather.description,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        InfoTile(title: "Kelembapan", value: "${widget.weather.humidity}%"),
                        InfoTile(title: "Arah Angin", value: widget.weather.windDirection),
                        InfoTile(title: "Tekanan", value: "${widget.weather.pressure} hPa"),
                        InfoTile(title: "Kecepatan Angin", value: "${widget.weather.windSpeed.toStringAsFixed(1)} m/s"),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Ramalan Harian",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    ...forecast!.daily.map(
                      (day) => ListTile(
                        title: Text(_formatDay(day.date)),
                        subtitle: Text(day.condition),
                        trailing: Text(
                          "${day.maxTemp.toStringAsFixed(0)}° / ${day.minTemp.toStringAsFixed(0)}°",
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const InfoTile({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
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

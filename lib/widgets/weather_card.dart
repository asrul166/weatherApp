import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel data;
  const WeatherCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(_getIcon(data.condition, data.isDay), size: 32),
        title: Text(
          data.city,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${data.temperature}° • ${data.condition.capitalize()}',
        ),
        trailing: Text('${data.high}° / ${data.low}°'),
      ),
    );
  }

  IconData _getIcon(String condition, bool isDay) {
    final lc = condition.toLowerCase();
    if (lc.contains('hujan')) return Icons.beach_access;
    if (lc.contains('awan')) return Icons.cloud;
    if (lc.contains('cerah') || lc.contains('clear')) {
      return isDay ? Icons.wb_sunny : Icons.nights_stay;
    }
    return Icons.wb_cloudy;
  }
}

extension StringCasing on String {
  String capitalize() => isEmpty
      ? ''
      : '${this[0].toUpperCase()}${substring(1)}';
}

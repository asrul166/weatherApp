// lib/services/weather_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherApiService {
  final String apiKey = '5f33107b99b28feb78327ac8a67f8b7d';

  /// Ambil cuaca saat ini berdasarkan nama kota
  Future<WeatherModel> fetchCurrentWeather(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&lang=id&appid=$apiKey';

    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return WeatherModel.fromJson(data);
    } else {
      throw Exception('Gagal ambil cuaca untuk kota: $city');
    }
  }

  /// Ambil cuaca berdasarkan lokasi device
  Future<WeatherModel> fetchWeatherByLocation() async {
    final position = await _determinePosition();
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&units=metric&lang=id&appid=$apiKey';

    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return WeatherModel.fromJson(data);
    } else {
      throw Exception('Gagal ambil cuaca berdasarkan lokasi');
    }
  }

  /// Cari kota (autocomplete)
  Future<List<WeatherModel>> searchCities(String query) async {
    final url =
        'https://api.openweathermap.org/data/2.5/find?q=$query&type=like&sort=population&cnt=5&units=metric&lang=id&appid=$apiKey';

    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final List list = data['list'] ?? [];
      return list.map((e) => WeatherModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mencari kota');
    }
  }

  /// Ambil ramalan cuaca (hourly & daily)
  Future<ForecastModel> fetchForecast(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=minutely,alerts&units=metric&lang=id&appid=$apiKey';

    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return ForecastModel.fromJson(data);
    } else {
      throw Exception('Gagal ambil ramalan cuaca');
    }
  }

  /// Minta izin dan ambil lokasi user
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi tidak aktif');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Izin lokasi ditolak permanen, atur di pengaturan perangkat.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<WeatherModel?> fetchCurrentWeatherByCoords(double latitude, double longitude) async {
    return null;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import 'package:geolocator/geolocator.dart';

class WeatherApiService {
  static const String _apiKey = "5f33107b99b28feb78327ac8a67f8b7d";
  static const String _baseUrl = "https://api.weatherapi.com/v1";

  Future<WeatherModel> fetchCurrentWeather(String city) async {
    final url = Uri.parse("$_baseUrl/forecast.json?key=$_apiKey&q=$city&days=1&aqi=no&alerts=no");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Gagal mengambil data cuaca");
    }

    final data = jsonDecode(response.body);
    return _mapToWeatherModel(data);
  }


  Future<WeatherModel> fetchCurrentWeatherByCoords() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather"
      "?lat=${position.latitude}&lon=${position.longitude}"
      "&appid=$_apiKey&units=metric&lang=id",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return WeatherModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Gagal ambil data lokasi");
    }
  }

  Future<List<WeatherModel>> searchCities(String query) async {
    final url = Uri.parse("$_baseUrl/search.json?key=$_apiKey&q=$query");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Gagal mencari kota");
    }

    final List results = jsonDecode(response.body);
    List<WeatherModel> weathers = [];

    for (var r in results) {
      weathers.add(await fetchCurrentWeather(r['name']));
    }

    return weathers;
  }

  Future<ForecastModel> fetchForecast(double lat, double lon) async {
    final url = Uri.parse("$_baseUrl/forecast.json?key=$_apiKey&q=$lat,$lon&days=7&aqi=no&alerts=no");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Gagal ambil ramalan cuaca");
    }

    final data = jsonDecode(response.body);
    return ForecastModel.fromJson(data);
  }

  WeatherModel _mapToWeatherModel(Map<String, dynamic> data) {
    final current = data['current'];
    final forecastDay = data['forecast']['forecastday'][0]['day'];
    final astro = data['forecast']['forecastday'][0]['astro'];
    final location = data['location'];

    return WeatherModel(
      city: location['name'],
      country: location['country'],
      lat: location['lat'].toDouble(),
      lon: location['lon'].toDouble(),
      temperature: current['temp_c'].toDouble(),
      high: forecastDay['maxtemp_c'].toDouble(),
      low: forecastDay['mintemp_c'].toDouble(),
      condition: current['condition']['text'],
      description: current['condition']['text'],
      icon: current['condition']['icon'],
      isDay: current['is_day'] == 1,
      windSpeed: current['wind_kph'].toDouble(),
      windDirection: current['wind_dir'],
      humidity: current['humidity'].toDouble(),
      uvIndex: current['uv'].toDouble(),
      precipitation: current['precip_mm'].toDouble(),
      feelsLike: current['feelslike_c'].toDouble(),
      visibility: current['vis_km'].toDouble(),
      pressure: current['pressure_mb'].toDouble(),
      sunrise: astro['sunrise'],
      sunset: astro['sunset'],
    );
  }
}

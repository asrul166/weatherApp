// lib/models/weather_model.dart
class WeatherModel {
  final String city;
  final String country;
  final double lat;
  final double lon;
  final double temp;
  final String description;
  final String icon;

  final double windSpeed;
  final String windDirection;
  final double humidity;
  final double uvIndex;
  final double precipitation;
  final double feelsLike;
  final double visibility;
  final double pressure;
  final String sunrise;
  final String sunset;

  WeatherModel({
    required this.city,
    required this.country,
    required this.lat,
    required this.lon,
    required this.temp,
    required this.description,
    required this.icon,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    required this.uvIndex,
    required this.precipitation,
    required this.feelsLike,
    required this.visibility,
    required this.pressure,
    required this.sunrise,
    required this.sunset,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['name'] ?? '',
      country: json['sys']?['country'] ?? '',
      lat: (json['coord']?['lat'] ?? 0).toDouble(),
      lon: (json['coord']?['lon'] ?? 0).toDouble(),
      temp: (json['main']?['temp'] ?? 0).toDouble(),
      description: json['weather'] != null && json['weather'].isNotEmpty
          ? json['weather'][0]['description'] ?? ''
          : '',
      icon: json['weather'] != null && json['weather'].isNotEmpty
          ? json['weather'][0]['icon'] ?? ''
          : '',
      windSpeed: (json['wind']?['speed'] ?? 0).toDouble(),
      windDirection: _degToCompass((json['wind']?['deg'] ?? 0).toDouble()),
      humidity: (json['main']?['humidity'] ?? 0).toDouble(),
      uvIndex: (json['uvi'] ?? 0).toDouble(), // Note: UVI biasanya dari API One Call
      precipitation: (json['rain']?['1h'] ?? 0).toDouble(),
      feelsLike: (json['main']?['feels_like'] ?? 0).toDouble(),
      visibility: ((json['visibility'] ?? 0) / 1000).toDouble(), // km
      pressure: (json['main']?['pressure'] ?? 0).toDouble(),
      sunrise: json['sys']?['sunrise'] != null
          ? _formatTime(json['sys']?['sunrise'])
          : '',
      sunset: json['sys']?['sunset'] != null
          ? _formatTime(json['sys']?['sunset'])
          : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': city,
      'country': country,
      'lat': lat,
      'lon': lon,
      'temp': temp,
      'description': description,
      'icon': icon,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'humidity': humidity,
      'uvIndex': uvIndex,
      'precipitation': precipitation,
      'feelsLike': feelsLike,
      'visibility': visibility,
      'pressure': pressure,
      'sunrise': sunrise,
      'sunset': sunset,
    };
  }

  // Convert derajat angin ke arah mata angin
  static String _degToCompass(double deg) {
    List<String> directions = [
      "N","NNE","NE","ENE","E","ESE","SE","SSE",
      "S","SSW","SW","WSW","W","WNW","NW","NNW"
    ];
    return directions[((deg / 22.5) + 0.5).floor() % 16];
  }

  // Format UNIX timestamp ke HH:mm
  static String _formatTime(int timestamp) {
    final date =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
            .toLocal();
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}

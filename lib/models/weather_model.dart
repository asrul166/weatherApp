class WeatherModel {
  final String city;
  final String country;
  final double lat;
  final double lon;

  final double temperature; 
  final double high; 
  final double low; 
  final String condition; 
  final String description;
  final String icon;
  final bool isDay;

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
    required this.temperature,
    required this.high,
    required this.low,
    required this.condition,
    required this.description,
    required this.icon,
    required this.isDay,
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

  WeatherModel copyWith({
    String? city,
    String? country,
    double? lat,
    double? lon,
    double? temperature,
    double? high,
    double? low,
    String? condition,
    String? description,
    String? icon,
    bool? isDay,
    double? windSpeed,
    String? windDirection,
    double? humidity,
    double? uvIndex,
    double? precipitation,
    double? feelsLike,
    double? visibility,
    double? pressure,
    String? sunrise,
    String? sunset,
  }
){
  return WeatherModel(
    city: city ?? this.city,
    country: country ?? this.country,
    lat: lat ?? this.lat,
    lon: lon ?? this.lon,
    temperature: temperature ?? this.temperature,
    high: high ?? this.high,
    low: low ?? this.low,
    condition: condition ?? this.condition,
    description: description ?? this.description,
    icon: icon ?? this.icon,
    isDay: isDay ?? this.isDay,
    windSpeed: windSpeed ?? this.windSpeed,
    windDirection: windDirection ?? this.windDirection,
    humidity: humidity ?? this.humidity,
    uvIndex: uvIndex ?? this.uvIndex,
    precipitation: precipitation ?? this.precipitation,
    feelsLike: feelsLike ?? this.feelsLike,
    visibility: visibility ?? this.visibility,
    pressure: pressure ?? this.pressure,
    sunrise: sunrise ?? this.sunrise,
    sunset: sunset ?? this.sunset,
  );
}


  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['name'] ?? '',
      country: json['sys']?['country'] ?? '',
      lat: (json['coord']?['lat'] ?? 0).toDouble(),
      lon: (json['coord']?['lon'] ?? 0).toDouble(),
      temperature: (json['main']?['temp'] ?? 0).toDouble(),
      high: (json['main']?['temp_max'] ?? 0).toDouble(),
      low: (json['main']?['temp_min'] ?? 0).toDouble(),
      condition: json['weather'] != null && json['weather'].isNotEmpty
          ? json['weather'][0]['main'] ?? ''
          : '',
      description: json['weather'] != null && json['weather'].isNotEmpty
          ? json['weather'][0]['description'] ?? ''
          : '',
      icon: json['weather'] != null && json['weather'].isNotEmpty
          ? json['weather'][0]['icon'] ?? ''
          : '',
      isDay: json['sys']?['sunrise'] != null && json['sys']?['sunset'] != null
          ? _isDayTime(json['sys']['sunrise'], json['sys']['sunset'])
          : true,
      windSpeed: (json['wind']?['speed'] ?? 0).toDouble(),
      windDirection: _degToCompass((json['wind']?['deg'] ?? 0).toDouble()),
      humidity: (json['main']?['humidity'] ?? 0).toDouble(),
      uvIndex: (json['uvi'] ?? 0).toDouble(), // ini kalau dari One Call API
      precipitation: (json['rain']?['1h'] ?? 0).toDouble(),
      feelsLike: (json['main']?['feels_like'] ?? 0).toDouble(),
      visibility: ((json['visibility'] ?? 0) / 1000).toDouble(),
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
      'temperature': temperature,
      'high': high,
      'low': low,
      'condition': condition,
      'description': description,
      'icon': icon,
      'isDay': isDay,
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

  // Konversi derajat jadi arah mata angin
  static String _degToCompass(double deg) {
    List<String> directions = [
      "N","NNE","NE","ENE","E","ESE","SE","SSE",
      "S","SSW","SW","WSW","W","WNW","NW","NNW"
    ];
    return directions[((deg / 22.5) + 0.5).floor() % 16];
  }

  // Cek apakah sekarang siang
  static bool _isDayTime(int sunrise, int sunset) {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    return now >= sunrise && now < sunset;
  }

  // Format waktu dari UNIX timestamp
  static String _formatTime(int timestamp) {
    final date =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
            .toLocal();
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}

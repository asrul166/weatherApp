class ForecastModel {
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  ForecastModel({required this.hourly, required this.daily});

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    List<HourlyForecast> hourlyList = [];
    if (json['hourly'] != null) {
      hourlyList = (json['hourly'] as List)
          .map((h) => HourlyForecast.fromJson(h))
          .toList();
    }

    List<DailyForecast> dailyList = [];
    if (json['daily'] != null) {
      dailyList = (json['daily'] as List)
          .map((d) => DailyForecast.fromJson(d))
          .toList();
    }

    return ForecastModel(hourly: hourlyList, daily: dailyList);
  }
}

class HourlyForecast {
  final DateTime time;
  final double temp;
  final String condition;

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.condition,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: false),
      temp: (json['temp'] as num).toDouble(),
      condition: json['weather'][0]['description'] ?? '',
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String condition;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
  });

  /// Ambil data dari JSON
  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: false),
      maxTemp: (json['temp']['max'] as num).toDouble(),
      minTemp: (json['temp']['min'] as num).toDouble(),
      condition: json['weather'][0]['description'] ?? '',
    );
  }

  /// Getter untuk rata-rata suhu harian
  double get temp => (maxTemp + minTemp) / 2;

  /// Getter untuk deskripsi
  String get description => condition;
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static Future<String> cityWeather({required String city}) async {
    // endpoint
    final uri =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=92f90171a9639b008090aa98c05df965';
    // http request
    try {
      final res = await http.get(Uri.parse(uri));
      if (res.statusCode == 200) {
        // print(res.body);
        final weather = cityWeatherFromJson(res.body);

        final formatedWeather = '''
        City: ${weather.name}
        Temperature: ${weather.main?.temp}°C
        Weather: ${weather.weather?[0].description}
        Humidity: ${weather.main?.humidity}%
        Wind Speed: ${weather.wind?.speed} m/s
        ''';
        return formatedWeather;
      } else {
        throw ('Error: cannot get weather data or city not found!');
      }
    } catch (e) {
      throw ('Error: $e');
    }
  }
}

// To parse this JSON data, do
//
//     final cityWeather = cityWeatherFromJson(jsonString);

CityWeather cityWeatherFromJson(String str) =>
    CityWeather.fromJson(json.decode(str));

String cityWeatherToJson(CityWeather data) => json.encode(data.toJson());

class CityWeather {
  final Coord? coord;
  final List<Weather>? weather;
  final String? base;
  final Main? main;
  final int? visibility;
  final Wind? wind;
  final Clouds? clouds;
  final int? dt;
  final Sys? sys;
  final int? timezone;
  final int? id;
  final String? name;
  final int? cod;

  CityWeather({
    this.coord,
    this.weather,
    this.base,
    this.main,
    this.visibility,
    this.wind,
    this.clouds,
    this.dt,
    this.sys,
    this.timezone,
    this.id,
    this.name,
    this.cod,
  });

  factory CityWeather.fromJson(Map<String, dynamic> json) => CityWeather(
    coord: json["coord"] == null ? null : Coord.fromJson(json["coord"]),
    weather:
        json["weather"] == null
            ? []
            : List<Weather>.from(
              json["weather"]!.map((x) => Weather.fromJson(x)),
            ),
    base: json["base"],
    main: json["main"] == null ? null : Main.fromJson(json["main"]),
    visibility: json["visibility"],
    wind: json["wind"] == null ? null : Wind.fromJson(json["wind"]),
    clouds: json["clouds"] == null ? null : Clouds.fromJson(json["clouds"]),
    dt: json["dt"],
    sys: json["sys"] == null ? null : Sys.fromJson(json["sys"]),
    timezone: json["timezone"],
    id: json["id"],
    name: json["name"],
    cod: json["cod"],
  );

  Map<String, dynamic> toJson() => {
    "coord": coord?.toJson(),
    "weather":
        weather == null
            ? []
            : List<dynamic>.from(weather!.map((x) => x.toJson())),
    "base": base,
    "main": main?.toJson(),
    "visibility": visibility,
    "wind": wind?.toJson(),
    "clouds": clouds?.toJson(),
    "dt": dt,
    "sys": sys?.toJson(),
    "timezone": timezone,
    "id": id,
    "name": name,
    "cod": cod,
  };
}

class Clouds {
  final int? all;

  Clouds({this.all});

  factory Clouds.fromJson(Map<String, dynamic> json) =>
      Clouds(all: json["all"]);

  Map<String, dynamic> toJson() => {"all": all};
}

class Coord {
  final double? lon;
  final double? lat;

  Coord({this.lon, this.lat});

  factory Coord.fromJson(Map<String, dynamic> json) =>
      Coord(lon: json["lon"]?.toDouble(), lat: json["lat"]?.toDouble());

  Map<String, dynamic> toJson() => {"lon": lon, "lat": lat};
}

class Main {
  final double? temp;
  final double? feelsLike;
  final double? tempMin;
  final double? tempMax;
  final int? pressure;
  final int? humidity;
  final int? seaLevel;
  final int? grndLevel;

  Main({
    this.temp,
    this.feelsLike,
    this.tempMin,
    this.tempMax,
    this.pressure,
    this.humidity,
    this.seaLevel,
    this.grndLevel,
  });

  factory Main.fromJson(Map<String, dynamic> json) => Main(
    temp: json["temp"]?.toDouble(),
    feelsLike: json["feels_like"]?.toDouble(),
    tempMin: json["temp_min"]?.toDouble(),
    tempMax: json["temp_max"]?.toDouble(),
    pressure: json["pressure"],
    humidity: json["humidity"],
    seaLevel: json["sea_level"],
    grndLevel: json["grnd_level"],
  );

  Map<String, dynamic> toJson() => {
    "temp": temp,
    "feels_like": feelsLike,
    "temp_min": tempMin,
    "temp_max": tempMax,
    "pressure": pressure,
    "humidity": humidity,
    "sea_level": seaLevel,
    "grnd_level": grndLevel,
  };
}

class Sys {
  final int? type;
  final int? id;
  final String? country;
  final int? sunrise;
  final int? sunset;

  Sys({this.type, this.id, this.country, this.sunrise, this.sunset});

  factory Sys.fromJson(Map<String, dynamic> json) => Sys(
    type: json["type"],
    id: json["id"],
    country: json["country"],
    sunrise: json["sunrise"],
    sunset: json["sunset"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "id": id,
    "country": country,
    "sunrise": sunrise,
    "sunset": sunset,
  };
}

class Weather {
  final int? id;
  final String? main;
  final String? description;
  final String? icon;

  Weather({this.id, this.main, this.description, this.icon});

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
    id: json["id"],
    main: json["main"],
    description: json["description"],
    icon: json["icon"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "main": main,
    "description": description,
    "icon": icon,
  };
}

class Wind {
  final double? speed;
  final int? deg;
  final double? gust;

  Wind({this.speed, this.deg, this.gust});

  factory Wind.fromJson(Map<String, dynamic> json) => Wind(
    speed: json["speed"]?.toDouble(),
    deg: json["deg"],
    gust: json["gust"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {"speed": speed, "deg": deg, "gust": gust};
}

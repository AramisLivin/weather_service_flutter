import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const BASE_URL = 'https://lazy-liger-49.telebit.io/cityweather';

  WeatherService();

  Future<WeatherModel> getWeather(String cityName) async {
    final uri =
        Uri.parse(BASE_URL).replace(queryParameters: {'cityName': cityName});

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body);
      return WeatherModel.fromJson(jsonMap);
    } else {
      print('Failed to load weather data: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load weather data');
    }
  }
}

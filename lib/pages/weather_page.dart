import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_service/models/weather_model.dart';
import 'package:weather_service/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<StatefulWidget> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService();
  WeatherModel? _weather;
  bool _isLoading = true;
  bool _showInputBox = false;
  bool _isExpanded = false;
  final TextEditingController _cityController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _lastCity = 'Batumi';

  @override
  void initState() {
    super.initState();
    _loadLastCity();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  _loadLastCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastCity = prefs.getString('lastCity') ?? 'Monaco';
      _fetchWeather();
    });
  }

  _saveLastCity(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastCity', city);
  }

  _fetchWeather() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final weather = await _weatherService.getWeather(_lastCity);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
    }
  }

  String getWeatherAnimation(String? condition) {
    if (condition == null) return 'assets/sunny.json';

    switch (condition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'overcast clouds':
      case 'scattered clouds':
      case 'broken clouds':
      case 'fog':
        return 'assets/clouds.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
      case 'thunderstorm':
        return 'assets/stormy.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle commonTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    BorderRadius _borderRadius = BorderRadius.circular(8);

    String capitalize(String text) {
      return toBeginningOfSentenceCase(text) ?? text;
    }

    return GestureDetector(
      onTap: () {
        if (_showInputBox) {
          setState(() {
            _showInputBox = false;
            _focusNode.unfocus();
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[800],
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _showInputBox
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _cityController,
                              focusNode: _focusNode,
                              decoration: InputDecoration(
                                hintText: 'Enter city name',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onSubmitted: (value) {
                                setState(() {
                                  _lastCity = value;
                                  _saveLastCity(_lastCity);
                                  _fetchWeather();
                                  _showInputBox = false;
                                  _focusNode.unfocus();
                                });
                              },
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _showInputBox = true;
                                Future.delayed(Duration(milliseconds: 100), () {
                                  _focusNode.requestFocus();
                                });
                              });
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: Text(_weather?.name ?? 'Change City'),
                          ),
                    if (_weather != null) ...[
                      Lottie.asset(
                        getWeatherAnimation(_weather?.weather[0].description),
                      ),
                      Text('${_weather?.main.temp.round()}°C',
                          style: commonTextStyle),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        icon: const Icon(Icons.info_outline),
                        label: Text(
                            capitalize(_weather?.weather[0].description ?? '')),
                      ),
                      AnimatedContainer(
                        decoration: BoxDecoration(
                          borderRadius: _borderRadius,
                          color: Colors.grey[700],
                        ),
                        duration: const Duration(milliseconds: 300),
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: _isExpanded ? 200 : 0, // Explicit height values
                        padding: const EdgeInsets.all(10),
                        child: SingleChildScrollView(
                          // Add scrollable container
                          child: _isExpanded && _weather != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.thermostat,
                                            color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Temperature: ${_weather!.main.temp}°C',
                                          style: commonTextStyle,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.device_thermostat,
                                            color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Feels Like: ${_weather!.main.feelsLike}°C',
                                          style: commonTextStyle,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.water_drop,
                                            color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Humidity: ${_weather!.main.humidity}%',
                                          style: commonTextStyle,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.speed,
                                            color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Pressure: ${_weather!.main.pressure} hPa',
                                          style: commonTextStyle,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.air,
                                            color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Wind Speed: ${_weather!.wind.speed} m/s',
                                          style: commonTextStyle,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.navigation,
                                            color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Wind Direction: ${_weather!.wind.deg}°',
                                          style: commonTextStyle,
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Container(),
                        ),
                      ),
                    ]
                  ],
                ),
        ),
      ),
    );
  }
}

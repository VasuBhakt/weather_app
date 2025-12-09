import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/cards/additional_info_card.dart';
import 'package:weather_app/cards/hourly_weather_card.dart';
import 'package:weather_app/cards/today_weather_card.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';
/*class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => 
       _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}*/

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double temp = 0;
  List<String> cities = [
    ' ',
    'Kolkata',
    'Delhi',
    'Mumbai',
    'Chennai',
    'Bengaluru',
  ];
  String cityName = 'Kolkata';
  Future<Map<String, dynamic>> weatherFuture = Future.value({});

  @override
  void initState() {
    super.initState();
    weatherFuture = getWeatherData();
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$openWeatherApiKey',
    );
    final response = await http.get(url);
    //print("current api called");
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getForecast() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherApiKey',
        ),
      );
      final data = jsonDecode(response.body);
      if (data['cod'] != '200') {
        throw 'An unexpected error occured';
      }
      //print("forecast api called");
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getWeatherData() async {
    final results = await Future.wait([getCurrentWeather(), getForecast()]);
    print("$cityName weather data fetched");
    return {'current': results[0], 'forecast': results[1]['list']};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false, // no back button
        title: Stack(
          alignment: Alignment.center,
          children: [
            // Title centered
            const Center(
              child: Text(
                "WeatherApp",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),

            // Left dropdown
            Align(
              alignment: Alignment.centerLeft,
              child: DropdownButton<String>(
                value: cityName,
                underline: SizedBox(),
                icon: Icon(Icons.keyboard_arrow_down),
                items: cities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city,),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null && value != ' ') {
                    setState(() {
                      cityName = value;
                      weatherFuture = getWeatherData();
                    });
                  }
                },
              ),
            ),

            // Right refresh button
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    weatherFuture = getWeatherData();
                  });
                },
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final current = snapshot.data!['current'];
          final forecast = snapshot.data!['forecast'];

          // Current Weather
          double currentTemp = (current['main']['temp']).toDouble();
          double currentFeelsLike = (current['main']['feels_like']).toDouble();
          double currentHumidity = (current['main']['humidity']).toDouble();
          double currentWindSpeed =
              ((current['wind']['speed']).toDouble()) * 3.6;
          String currentSky = current['weather'][0]['main'];

          // Kelvin to Celsius conversion
          double kToC(double k) => k - 273.15;

          // Forecast filtering
          final now = DateTime.now();
          final futureForecasts = forecast.where((item) {
            final forecastTime = DateTime.parse(item['dt_txt']);
            return forecastTime.isAfter(now);
          }).toList();

          // Next 6 intervals
          final nextSixForecasts = futureForecasts.take(6).toList();

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 30,

                  child: Center(
                    child: Text(
                      cityName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TodayWeatherCard(
                  temperature: kToC(currentTemp),
                  weather: currentSky,
                  time: DateFormat.Hm().format(now),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Additional Information",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AdditionalInfoCard(
                        attribute: "Humidity",
                        value: currentHumidity,
                        icon: const Icon(Icons.water_drop, size: 32),
                        additional: "%",
                      ),
                      AdditionalInfoCard(
                        attribute: "Wind Speed",
                        value: currentWindSpeed,
                        icon: const Icon(Icons.air, size: 32),
                        additional: "km/h",
                      ),
                      AdditionalInfoCard(
                        attribute: "Feels Like",
                        value: kToC(currentFeelsLike),
                        icon: const Icon(Icons.thermostat, size: 32),
                        additional: "C",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Hourly Forecast",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // HOURLY FORECAST
                SizedBox(
                  height: 165,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: nextSixForecasts.length,
                    itemBuilder: (context, index) {
                      final item = nextSixForecasts[index];
                      final dt = DateTime.parse(item['dt_txt']);
                      return HourlyWeatherCard(
                        time: DateFormat.Hm().format(dt),
                        weather: (item['weather'][0]['main']),
                        temperature: kToC((item['main']['temp']).toDouble()),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

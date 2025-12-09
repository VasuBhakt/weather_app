import 'dart:ui';

import 'package:flutter/material.dart';

class HourlyWeatherCard extends StatelessWidget {
  final String time;
  final double temperature;
  final String weather;
  const HourlyWeatherCard({
    super.key,
    required this.time,
    required this.temperature,
    required this.weather,
  });
  Icon _retIcon(String sky) {
    double hour = double.parse(time.split(":")[0]);
    if (sky == "Rain") {
      return Icon(Icons.cloudy_snowing, size: 64);
    } else if (sky == "Clouds") {
      return Icon(Icons.cloud, size: 64);
    } else if (sky == "Clear") {
      if(hour>=6 && hour<=18) {
        return Icon(Icons.wb_sunny, size: 64);
      } else {
        return Icon(Icons.nights_stay, size: 64);
      }
    } else if (sky == "Snow") {
      return Icon(Icons.ac_unit, size: 64);
    } else if (sky == "Thunderstorm") {
      return Icon(Icons.flash_on, size: 64);
    } else if (sky == "Drizzle") {
      return Icon(Icons.grain, size: 64);
    } else if (sky == "Mist" ||
        sky == "Smoke" ||
        sky == "Haze" ||
        sky == "Dust" ||
        sky == "Fog" ||
        sky == "Sand" ||
        sky == "Ash" ||
        sky == "Squall" ||
        sky == "Tornado") {
      return Icon(Icons.filter_drama, size: 64);
    } else {
       return Icon(Icons.question_mark);// fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 125,
      child: Card(
        //color: Color.fromARGB(255, 59, 64, 87),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _retIcon(weather),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${temperature.toStringAsFixed(2)} C",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

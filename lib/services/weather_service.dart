import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Get your key at pirateweather.net
  final String _apiKey = "APT4aa2hrBS0J61gjMO950GbEShEjOcC"; 
  
  // Bethel Township coordinates
  final double lat = 39.9614;
  final double lon = -84.0624;

  Future<Map<String, dynamic>> getWeatherData() async {
    final url = Uri.parse("https://api.pirateweather.net/forecast/$_apiKey/$lat,$lon?units=us");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['currently'];

        double temp = current['temperature'].toDouble();
        double dewPoint = current['dewPoint'].toDouble();
        double wind = current['windSpeed'].toDouble();
        double precip = current['precipProbability'].toDouble() * 100;
        String summary = current['summary'];

        // --- THE FROST TRIANGLE LOGIC ---
        String risk = "Low";
        if (temp <= 32) {
          risk = "Freeze";
        } else if (temp <= 37 && wind < 5 && (temp - dewPoint).abs() < 3) {
          risk = "High Frost";
        } else if (temp <= 40 && wind < 3) {
          risk = "Frost Watch";
        }

        return {
          'temp': temp.toStringAsFixed(0),
          'risk': risk,
          'wind': wind.toStringAsFixed(1),
          'precip': precip.toStringAsFixed(0),
          'summary': summary,
          'icon': _getWeatherIcon(current['icon']),
        };
      }
    } catch (e) {
      print("Weather Error: $e");
    }
    return {}; // Return empty if failed
  }

  String _getWeatherIcon(String iconType) {
    switch (iconType) {
      case 'clear-day': return '☀️';
      case 'clear-night': return '🌙';
      case 'rain': return '🌧️';
      case 'snow': return '❄️';
      case 'cloudy': return '☁️';
      case 'partly-cloudy-day': return '⛅';
      default: return '🌡️';
    }
  }
}
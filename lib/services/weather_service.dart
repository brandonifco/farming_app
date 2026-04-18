import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Get your key at pirateweather.net
  final String _apiKey = "APT4aa2hrBS0J61gjMO950GbEShEjOcC";

  // Bethel Township coordinates
  final double lat = 39.9614;
  final double lon = -84.0624;

  Future<Map<String, dynamic>> getWeatherData() async {
    final url = Uri.parse(
      "https://api.pirateweather.net/forecast/$_apiKey/$lat,$lon?units=us",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 'currently' is for the immediate weather
        final current = data['currently'];
        // 'daily' contains the high/low for the day (index 0 is today)
        final daily = data['daily']['data'][0];

        double temp = current['temperature'].toDouble();
        double dewPoint = current['dewPoint'].toDouble();
        double wind = current['windSpeed'].toDouble();
        double precip = current['precipProbability'].toDouble() * 100;
        double accum = daily['precipAccumulation'].toDouble();

        // Pull High/Low from the daily block, not the currently block
        double high = daily['temperatureHigh'].toDouble();
        double low = daily['temperatureLow'].toDouble();
        int highTime = daily['temperatureHighTime'];
        int lowTime = daily['temperatureLowTime'];
        String summary = current['summary'];

        // --- IMPROVED FROST LOGIC ---
        // We check the 'low' variable here because that's the real threat to plants
        String risk = "Low";
        if (low <= 32) {
          risk = "Freeze Warning";
        } else if (low <= 37 && wind < 5 && (low - dewPoint).abs() < 4) {
          risk = "Frost Likely";
        } else if (low <= 40) {
          risk = "Frost Watch";
        }
        String formatUnixTime(int timestamp) {
          var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
          
          // Get hour and minute
          int hour = date.hour;
          int minute = date.minute;
          
          // Determine AM/PM
          String period = hour >= 12 ? 'PM' : 'AM';
          
          // Convert to 12-hour format
          hour = hour % 12;
          if (hour == 0) hour = 12; // Handle Midnight/Noon
          
          // Pad minutes (e.g., 6:5 becomes 6:05)
          String minuteStr = minute < 10 ? '0$minute' : '$minute';
          
          return '$hour:$minuteStr$period';
        }

        return {
          'temp': temp.toStringAsFixed(0),
          'high': high.toStringAsFixed(0),
          'low': low.toStringAsFixed(0),
          'highTime': formatUnixTime(highTime),
          'lowTime': formatUnixTime(lowTime),
          'accum' : accum.toStringAsFixed(2),
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
    return {};
  }

  String _getWeatherIcon(String iconType) {
    switch (iconType) {
      case 'clear-day':
        return '☀️';
      case 'clear-night':
        return '🌙';
      case 'rain':
        return '🌧️';
      case 'snow':
        return '❄️';
      case 'cloudy':
        return '☁️';
      case 'partly-cloudy-day':
        return '⛅';
      default:
        return '🌡️';
    }
  }
}

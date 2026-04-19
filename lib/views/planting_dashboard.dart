import 'package:flutter/material.dart';
import '../services/planting_service.dart';
import '../services/config_service.dart';
import '../models/crop.dart';
import 'crop_detail_view.dart';
import 'full_calendar_view.dart';
import 'settings_view.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';

class PlantingDashboard extends StatefulWidget {
  const PlantingDashboard({super.key});

  @override
  State<PlantingDashboard> createState() => _PlantingDashboardState();
}

class _PlantingDashboardState extends State<PlantingDashboard> {
  final PlantingService _plantingService = PlantingService();
  final ConfigService _configService = ConfigService();
  final WeatherService _weatherService = WeatherService();
  final DateTime _today = DateTime.now();

  String _currentZone = "6b";
  String _currentLocation = "Loading...";
  String _farmName = "The Farm";

  @override
  void initState() {
    super.initState();
    _updateUIFromConfig();
  }

  Future<void> _updateUIFromConfig() async {
    final config = await _configService.loadConfig();
    setState(() {
      _currentZone = config['hardinessZone'];
      _currentLocation = config['location'] ?? "Unknown Location";
      _farmName = config['farmName'] ?? "My Farm";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_farmName),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          // REFRESH BUTTON: Forces FutureBuilders to rebuild
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () {
              setState(() {
                // Re-trigger the UI update from config and 
                // refresh the Weather/Planting FutureBuilders
                _updateUIFromConfig();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Full Calendar',
            onPressed: () async {
              // Using 'await' ensures that if the user changes selections,
              // we refresh the dashboard when they return.
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FullCalendarView(),
                ),
              );
              setState(() {}); // Refresh list after returning from calendar
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsView()),
              );
              _updateUIFromConfig();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.green[50],
            child: FutureBuilder<Map<String, dynamic>>(
              // The refresh button re-triggers this call
              future: _weatherService.getWeatherData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data ?? {};
                if (data.isEmpty) return const Text("Weather Unavailable");

                Color riskColor = data['risk'] == "Freeze"
                    ? Colors.red
                    : data['risk'] == "High Frost"
                    ? Colors.orange
                    : Colors.green;

                return Row(
                  children: [
                    Text(data['icon'], style: const TextStyle(fontSize: 40)),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMMM d, yyyy').format(_today),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                        Text(
                          'Currently ${data['temp']}°F - ${data['risk']} Risk',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                          ),
                        ),
                        Text(
                          'High ${data['high']}°F @ ${data['highTime']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                          ),
                        ),
                        Text(
                          'Low ${data['low']}°F @ ${data['lowTime']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                          ),
                        ),
                        Text(
                          '${data['summary']} • Wind: ${data['wind']}mph • Rain: ${data['precip']}%',
                        ),
                        Text(
                          'Accumulation ${data['accum']} in.',
                        ),
                        Text(
                          '$_currentLocation - Zone $_currentZone',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Planting Now',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Crop>>(
              // The refresh button re-triggers this filtered search
              future: _plantingService.getCropsToPlant(_today),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final crops = snapshot.data ?? [];

                if (crops.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'Nothing to plant today. Check the full calendar and make sure you have crops selected!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: crops.length,
                  itemBuilder: (context, index) {
                    final crop = crops[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.grass, color: Colors.green),
                        title: Text(
                          crop.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(crop.method),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CropDetailView(crop: crop),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
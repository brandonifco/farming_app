import 'package:flutter/material.dart';
import '../services/planting_service.dart';
import '../services/config_service.dart'; // New Import
import '../models/crop.dart';
import 'crop_detail_view.dart';
import 'full_calendar_view.dart';
import 'settings_view.dart';
import 'package:intl/intl.dart';

class PlantingDashboard extends StatefulWidget {
  const PlantingDashboard({super.key});

  @override
  State<PlantingDashboard> createState() => _PlantingDashboardState();
}

class _PlantingDashboardState extends State<PlantingDashboard> {
  final PlantingService _plantingService = PlantingService();
  final ConfigService _configService = ConfigService();
  final DateTime _today = DateTime.now();
  
  // Track the zone in the state
  String _currentZone = "6b"; 
  String _currentLocation = "Loading..."; 
  String _farmName = "The Farm";      

  @override
  void initState() {
    super.initState();
    _updateUIFromConfig(); 
  }

  // Load the zone on first startup
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
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsView()),
              );
              
              _updateUIFromConfig();
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FullCalendarView()),
              );
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
            child: Row(
              children: [
                const Icon(Icons.wb_sunny, color: Colors.orange, size: 40),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM d, yyyy').format(_today), // Dynamic formatting
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[900]),
                    ),
                    // Now using the dynamic state variable
                    Text('$_currentLocation - Zone $_currentZone'), 
                  ],
                ),
              ],
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
              future: _plantingService.getCropsToPlant(_today),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final crops = snapshot.data ?? [];

                if (crops.isEmpty) {
                  return const Center(
                    child: Text('Nothing to plant today. Check the full calendar!'),
                  );
                }

                return ListView.builder(
                  itemCount: crops.length,
                  itemBuilder: (context, index) {
                    final crop = crops[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.grass, color: Colors.green),
                        title: Text(crop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
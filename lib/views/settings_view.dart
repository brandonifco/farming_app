import '../services/config_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // Provides the 'json' decoder
import 'package:flutter/services.dart'; // Provides 'rootBundle'

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // Common Ohio/Midwest zones as a starting point
  final List<String> _zones = ['5a', '5b', '6a', '6b', '7a', '7b'];
  String _selectedZone = '6b'; // Default to your current zone
  final ConfigService _configService = ConfigService();

  @override
  void initState() {
    super.initState();
    _loadCurrentZone();
  }

  Future<void> _loadCurrentZone() async {
    final config = await _configService.loadConfig();
    setState(() {
      _selectedZone = config['hardinessZone'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Configuration'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Hardiness Zone",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text("This determines your spring and fall frost pivots."),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedZone,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Select Zone",
            ),
            items: _zones.map((zone) {
              return DropdownMenuItem(value: zone, child: Text("Zone $zone"));
            }).toList(),
            onChanged: (value) async {
            setState(() { _selectedZone = value!; });

            // 1. Load the zone lookup table from assets
            final String zoneDataString = await rootBundle.loadString('assets/zones.json');
            final Map<String, dynamic> zoneMap = json.decode(zoneDataString);
            
            // 2. Load your current personalized farm config
            final service = ConfigService();
            final config = await service.loadConfig();

            // 3. Update config with the new zone's data
            config['hardinessZone'] = value;
            config['lastFrostDate'] = zoneMap[value]['lastFrost'];
            config['firstFrostDate'] = zoneMap[value]['firstFrost'];

            // 4. Save the updated config to local storage
            await service.saveConfig(config);
            
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Updated to Zone $value. Spring Pivot: ${config['lastFrostDate']}")),
            );
            },
          ),
          const SizedBox(height: 30),
          const ListTile(
            leading: Icon(Icons.location_on),
            title: Text("Location"),
            subtitle: Text("Bethel Township, OH"),
          ),
        ],
      ),
    );
  }
}
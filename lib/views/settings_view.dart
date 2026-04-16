import '../services/config_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final ConfigService _configService = ConfigService();

  // Controllers for text input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final List<String> _zones = ['5a', '5b', '6a', '6b', '7a', '7b'];
  String _selectedZone = '6b';

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  Future<void> _getCurrentGPSLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    // 2. Handle Permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // 3. Get Coordinates
    Position position = await Geolocator.getCurrentPosition();

    // 4. Reverse Geocode (Lat/Lon -> City Name)
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      setState(() {
        _locationController.text =
            "${place.locality}, ${place.administrativeArea}";
      });
    }
  }

  // Load all data into controllers and dropdown
  Future<void> _loadCurrentConfig() async {
    final config = await _configService.loadConfig();
    setState(() {
      _selectedZone = config['hardinessZone'] ?? '6b';
      _nameController.text = config['farmName'] ?? 'The Farm';
      _locationController.text = config['location'] ?? 'Bethel Township, OH';
    });
  }

  // Centralized Save Function
  Future<void> _saveAllConfig() async {
    // 1. Load the zone lookup table
    final String zoneDataString = await rootBundle.loadString(
      'assets/zones.json',
    );
    final Map<String, dynamic> zoneMap = json.decode(zoneDataString);

    // 2. Build the new config map
    final Map<String, dynamic> newConfig = {
      'farmName': _nameController.text,
      'location': _locationController.text,
      'hardinessZone': _selectedZone,
      'lastFrostDate': zoneMap[_selectedZone]['lastFrost'],
      'firstFrostDate': zoneMap[_selectedZone]['firstFrost'],
    };

    // 3. Save to local storage
    await _configService.saveConfig(newConfig);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Farm Configuration Saved!")),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Configuration'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveAllConfig),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- SECTION 1: IDENTITY ---
          const Text(
            "General Info",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Farm Name",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.agriculture),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: "Location",
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.location_on),
              // ADD THIS SUFFIX ICON:
              suffixIcon: IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: _getCurrentGPSLocation,
                tooltip: "Get current location",
              ),
            ),
          ),
          const SizedBox(height: 30),

          // --- SECTION 2: CLIMATE ---
          const Text(
            "Hardiness Zone",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text("Determines your planting window based on frost dates."),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedZone,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: _zones.map((zone) {
              return DropdownMenuItem(value: zone, child: Text("Zone $zone"));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedZone = value!;
              });
            },
          ),
          const SizedBox(height: 40),

          ElevatedButton.icon(
            onPressed: _saveAllConfig,
            icon: const Icon(Icons.save),
            label: const Text("SAVE CONFIGURATION"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}

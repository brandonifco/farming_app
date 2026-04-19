import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/planting_service.dart';
import '../models/crop.dart';
import 'crop_detail_view.dart';

class FullCalendarView extends StatefulWidget {
  const FullCalendarView({super.key});

  @override
  State<FullCalendarView> createState() => _FullCalendarViewState();
}

class _FullCalendarViewState extends State<FullCalendarView> {
  final PlantingService _service = PlantingService();
  final DateTime _now = DateTime.now();
  List<Crop> _allCrops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCropsAndPreferences();
  }

  // Load crops and match them against saved preferences
  Future<void> _loadCropsAndPreferences() async {
    final crops = await _service.getAllCrops();
    final prefs = await SharedPreferences.getInstance();
    final List<String> selectedNames = prefs.getStringList('selected_crops') ?? [];

    for (var crop in crops) {
      if (selectedNames.contains(crop.name)) {
        crop.isSelected = true;
      }
    }

    setState(() {
      _allCrops = crops;
      _isLoading = false;
    });
  }

  // Save the selection to disk
  Future<void> _toggleCropSelection(Crop crop, bool? value) async {
    setState(() {
      crop.isSelected = value ?? false;
    });

    final prefs = await SharedPreferences.getInstance();
    final List<String> selectedNames = prefs.getStringList('selected_crops') ?? [];

    if (crop.isSelected) {
      if (!selectedNames.contains(crop.name)) selectedNames.add(crop.name);
    } else {
      selectedNames.remove(crop.name);
    }

    await prefs.setStringList('selected_crops', selectedNames);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active': return Colors.green;
      case 'Upcoming': return Colors.blue;
      case 'Past': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full 2026 Season'),
        backgroundColor: Colors.blueGrey[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allCrops.length,
              itemBuilder: (context, index) {
                final crop = _allCrops[index];
                final status = crop.getStatus(_now);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Checkbox(
                      activeColor: Colors.green[700],
                      value: crop.isSelected,
                      onChanged: (value) => _toggleCropSelection(crop, value),
                    ),
                    title: Text(crop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Window: ${crop.start!.month}/${crop.start!.day} - ${crop.end!.month}/${crop.end!.day}'),
                    trailing: Chip(
                      label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      backgroundColor: _getStatusColor(status),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CropDetailView(crop: crop)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
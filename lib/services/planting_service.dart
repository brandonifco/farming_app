import 'config_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added for persistence
import '../models/crop.dart';

class PlantingService {
  // Helper to fetch the specific frost dates from your config
  Future<Map<String, DateTime>> _getFrostDates() async {
    final config = await ConfigService().loadConfig();

    return {
      'spring': DateTime.parse(config['lastFrostDate']),
      'fall': DateTime.parse(config['firstFrostDate']),
    };
  }

  Future<List<Crop>> loadCrops() async {
    // 1. Get the environment anchors
    final frostDates = await _getFrostDates();

    // 2. Get the crop rules
    final String response = await rootBundle.loadString('assets/crops.json');
    final List<dynamic> data = json.decode(response);

    // 3. Get the persistent selections from disk
    final prefs = await SharedPreferences.getInstance();
    final List<String> selectedNames = prefs.getStringList('selected_crops') ?? [];

    // 4. Map to objects, calculate dates, and set selection state
    return data.map((json) {
      final crop = Crop.fromJson(json);
      crop.calculateDates(frostDates['spring']!, frostDates['fall']!);
      
      // Set the selection state based on what's saved in preferences
      crop.isSelected = selectedNames.contains(crop.name);
      
      return crop;
    }).toList();
  }

  Future<List<Crop>> getCropsToPlant(DateTime date) async {
    final allCrops = await loadCrops();
    return allCrops.where((crop) {
      if (crop.start == null || crop.end == null) return false;

      // Check if current date falls within the calculated window
      bool isWindowActive = (date.isAfter(crop.start!) ||
              date.isAtSameMomentAs(crop.start!)) &&
          (date.isBefore(crop.end!) || date.isAtSameMomentAs(crop.end!));
      
      // ONLY return crops that are in the window AND selected by the user
      return isWindowActive && crop.isSelected;
    }).toList();
  }

  Future<List<Crop>> getAllCrops() async {
    return await loadCrops();
  }
}
import 'config_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/crop.dart';

class PlantingService {
  // New helper to fetch the specific frost dates from your config
  Future<Map<String, DateTime>> _getFrostDates() async {
    // Switch from rootBundle to our new ConfigService
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

    // 3. Map to objects and calculate their specific dates
    return data.map((json) {
      final crop = Crop.fromJson(json);
      crop.calculateDates(frostDates['spring']!, frostDates['fall']!);
      return crop;
    }).toList();
  }

  Future<List<Crop>> getCropsToPlant(DateTime date) async {
    final allCrops = await loadCrops();
    return allCrops.where((crop) {
      if (crop.start == null || crop.end == null) return false;

      // Check if current date falls within the calculated window
      return (date.isAfter(crop.start!) ||
              date.isAtSameMomentAs(crop.start!)) &&
          (date.isBefore(crop.end!) || date.isAtSameMomentAs(crop.end!));
    }).toList();
  }

  Future<List<Crop>> getAllCrops() async {
    return await loadCrops();
  }
}

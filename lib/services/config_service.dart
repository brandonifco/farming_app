import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Add this for kIsWeb
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // We'll use this for Web

class ConfigService {
  static const String _fileName = 'farm_config.json';
  static const String _webKey = 'farm_config_data';

  // Load config: Unified logic for Web and Mobile
  Future<Map<String, dynamic>> loadConfig() async {
    // 1. Check Web Persistence
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final String? webData = prefs.getString(_webKey);
      if (webData != null) {
        return json.decode(webData);
      }
    } else {
      // 2. Check Mobile/Desktop Persistence
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      if (await file.exists()) {
        final contents = await file.readAsString();
        return json.decode(contents);
      }
    }

    // 3. Fallback: Asset (Factory Defaults)
    final String response = await rootBundle.loadString('assets/$_fileName');
    return json.decode(response);
  }

  // Save config: Unified logic
  Future<void> saveConfig(Map<String, dynamic> config) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_webKey, json.encode(config));
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      await file.writeAsString(json.encode(config));
    }
  }
}
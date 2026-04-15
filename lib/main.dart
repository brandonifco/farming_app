import 'package:flutter/material.dart';
import 'views/planting_dashboard.dart';

void main() {
  runApp(const FarmApp());
}

class FarmApp extends StatelessWidget {
  const FarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the "debug" banner
      title: 'The Farm App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true, // Uses the modern Android/Web look
      ),
      home: const PlantingDashboard(),
    );
  }
}
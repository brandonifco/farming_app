import 'package:flutter/material.dart';
import '../services/planting_service.dart';
import '../models/crop.dart';
import 'crop_detail_view.dart';

class FullCalendarView extends StatelessWidget {
  const FullCalendarView({super.key});

  // Helper to pick the color for the status tag
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
    final service = PlantingService();
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Full 2026 Season'),
        backgroundColor: Colors.blueGrey[700],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Crop>>(
        future: service.getAllCrops(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allCrops = snapshot.data ?? [];

          return ListView.builder(
            itemCount: allCrops.length,
            itemBuilder: (context, index) {
              final crop = allCrops[index];
              final status = crop.getStatus(now);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(crop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Window: ${crop.start!.month}/${crop.start!.day} - ${crop.end!.month}/${crop.end!.day}'),
                  trailing: Chip(
                    label: Text(
                      status, 
                      style: const TextStyle(color: Colors.white, fontSize: 12)
                    ),
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
          );
        },
      ),
    );
  }
}
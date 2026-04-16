import 'package:flutter/material.dart';
import '../models/crop.dart';
import 'package:intl/intl.dart';

class CropDetailView extends StatelessWidget {
  final Crop crop;

  const CropDetailView({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final String startDate = "${crop.start!.month}/${crop.start!.day}";
    final String endDate = "${crop.end!.month}/${crop.end!.day}";
    final String harvestRange = "${DateFormat('MMM d').format(crop.harvestStart!)} - ${DateFormat('MMM d').format(crop.harvestEnd!)}";

    return Scaffold(
      appBar: AppBar(
        title: Text(crop.name),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARD 1: Planting Window
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.green),
                title: const Text('Planting Window'),
                subtitle: Text('$startDate to $endDate'),
              ),
            ),
            const SizedBox(height: 10),
            // CARD 2: Harvest Projection (The new logic)
            Card(
              child: ListTile(
                leading: const Icon(Icons.shopping_basket, color: Colors.orange),
                title: const Text('Estimated Harvest'),
                subtitle: Text(harvestRange),
              ),
            ),
            const SizedBox(height: 10),
            // CARD 3: Method
            Card(
              child: ListTile(
                leading: const Icon(Icons.pan_tool, color: Colors.green),
                title: const Text('Method'),
                subtitle: Text(crop.method),
              ),
            ),
            const SizedBox(height: 10),
            // CARD 4: Notes
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.green),
                        SizedBox(width: 10),
                        Text('Planting Tips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(crop.notes, style: const TextStyle(fontSize: 14, height: 1.4)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
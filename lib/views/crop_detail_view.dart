import 'package:flutter/material.dart';
import '../models/crop.dart';
import 'package:intl/intl.dart';

class CropDetailView extends StatelessWidget {
  final Crop crop;

  const CropDetailView({super.key, required this.crop});

  // Helper to determine the color of the hardiness badge
  Color _getHardinessColor(String hardiness) {
    switch (hardiness.toLowerCase()) {
      case 'very tender': return Colors.red[700]!;
      case 'tender': return Colors.orange[700]!;
      case 'half-hardy': return Colors.blue[600]!;
      case 'hardy': return Colors.green[700]!;
      case 'extremely hardy': return Colors.purple[700]!;
      default: return Colors.grey;
    }
  }

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
      body: SingleChildScrollView( // Changed to ScrollView to avoid overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NEW CARD: Frost Resilience & Hardiness
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.ac_unit, color: _getHardinessColor(crop.hardiness)),
                title: const Text('Frost Resilience', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${crop.hardiness.toUpperCase()} (Safe to ${crop.criticalTemp}°F)'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getHardinessColor(crop.hardiness).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getHardinessColor(crop.hardiness)),
                  ),
                  child: Text(
                    crop.hardiness,
                    style: TextStyle(color: _getHardinessColor(crop.hardiness), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // CARD 1: Planting Window
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.green),
                title: const Text('Planting Window'),
                subtitle: Text('$startDate to $endDate'),
              ),
            ),
            const SizedBox(height: 10),
            // CARD 2: Harvest Projection
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
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
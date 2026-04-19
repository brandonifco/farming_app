class Crop {
  final String name;
  final String hardiness; // Add this
  final int criticalTemp;      // Add this
  final String pivot; // 'spring' or 'fall'
  final int relativeStart; // days relative to pivot
  final int relativeEnd; // days relative to pivot
  final int daysToHarvest; // New Field
  final String method;
  final String notes;
  bool isSelected = false; // Add this line

  // These will be calculated on the fly
  DateTime? start;
  DateTime? end;
  DateTime? harvestStart;
  DateTime? harvestEnd;

  Crop({
    required this.name,
    required this.hardiness,
    required this.criticalTemp,
    required this.pivot,
    required this.relativeStart,
    required this.relativeEnd,
    required this.daysToHarvest,
    required this.method,
    required this.notes,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      name: json['name'],
      hardiness: json['hardiness'] ?? 'Unknown',
      criticalTemp: json['criticalTemp'] is int 
        ? json['criticalTemp'] 
        : int.tryParse(json['criticalTemp'].toString()) ?? 32,      pivot: json['pivot'],
      relativeStart: json['relativeStart'],
      relativeEnd: json['relativeEnd'],
      daysToHarvest: json['daysToHarvest'],
      method: json['method'],
      notes: json['notes'],
    );
  }

  // The "Engine" logic: calculates actual dates based on frost dates
  void calculateDates(DateTime lastFrost, DateTime firstFrost) {
    DateTime anchor = (pivot == 'spring') ? lastFrost : firstFrost;

    // 1. Calculate the Planting Window
    start = anchor.add(Duration(days: relativeStart));
    end = anchor.add(Duration(days: relativeEnd));

    // 2. Calculate the Harvest Window
    // harvestStart is based on the first possible planting day
    harvestStart = start!.add(Duration(days: daysToHarvest));
    // harvestEnd is based on the last possible planting day
    harvestEnd = end!.add(Duration(days: daysToHarvest));
  }

  String getStatus(DateTime projectionDate) {
    if (start == null || end == null) return "Unknown";
    if (projectionDate.isBefore(start!)) return "Upcoming";
    if (projectionDate.isAfter(end!)) return "Past";
    return "Active";
  }
}

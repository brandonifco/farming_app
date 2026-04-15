class Crop {
  final String name;
  final String pivot; // 'spring' or 'fall'
  final int relativeStart; // days relative to pivot
  final int relativeEnd;   // days relative to pivot
  final int daysToHarvest; // New Field
  final String method;
  final String notes;

  // These will be calculated on the fly
  DateTime? start;
  DateTime? end;
  DateTime? harvestDate; // New Calculated Date

  Crop({
    required this.name,
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
      pivot: json['pivot'],
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
    start = anchor.add(Duration(days: relativeStart));
    end = anchor.add(Duration(days: relativeEnd));
    // Harvest is calculated from the start of the planting window
    harvestDate = start!.add(Duration(days: daysToHarvest));
  }

  String getStatus(DateTime projectionDate) {
      if (start == null || end == null) return "Unknown";
      if (projectionDate.isBefore(start!)) return "Upcoming";
      if (projectionDate.isAfter(end!)) return "Past";
      return "Active";
  }
}
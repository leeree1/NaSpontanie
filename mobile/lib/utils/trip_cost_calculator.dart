class TripCostCalculator {
  static Map<String, dynamic> calculateTripPlan({
    required double availableHours,
    required double userBudget,
    required String transportType,
  }) {
    double estimatedCost = 0.0;
    List<String> notes = [];

    if (availableHours > 3) {
      estimatedCost += 50.0;
      notes.add('Wliczono posiłek (czas trasy > 3h)');
    }

    if (transportType == 'Komunikacja miejska') {
      estimatedCost += 15.0;
    } else if (transportType == 'Samochód') {
      estimatedCost += 30.0;
    }

    estimatedCost += 40.0;

    return {
      'estimatedCost': estimatedCost,
      'isAffordable': userBudget >= estimatedCost,
      'notes': notes,
    };
  }
}

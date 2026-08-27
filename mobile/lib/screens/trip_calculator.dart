class TripCalculator {
  static Map<String, dynamic> calculateTripPlan({
    required double availableHours,
    required double userBudget,
    required String transportType,
  }) {
    double estimatedCost = 0.0;
    List<String> notes = [];

    // 1. Koszt posiłku, jeśli czas trasy > 3 godzin
    if (availableHours > 3) {
      estimatedCost += 50.0; // 50 zł na posiłek
      notes.add('Wliczono posiłek (czas trasy > 3h)');
    }

    // 2. Koszt transportu szacunkowy
    if (transportType == 'Komunikacja miejska') {
      estimatedCost += 15.0; 
    } else if (transportType == 'Samochód') {
      estimatedCost += 30.0; 
    } else if (transportType == 'Pociąg') {
      if (availableHours <= 3) {
        estimatedCost += 20.0; 
      } else {
        estimatedCost += 70.0; 
      }
    }

    // 3. Uśredniony koszt atrakcji/wejściówek
    double attractionCost = 30.0;
    estimatedCost += attractionCost;

    bool isAffordable = userBudget >= estimatedCost;

    return {
      'estimatedCost': estimatedCost,
      'isAffordable': isAffordable,
      'notes': notes,
    };
  }
}
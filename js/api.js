// Symulator bazy danych (Mock API)
const MockAPI = {
  fetchTrips: async () => {
    // Udajemy, że czekamy pół sekundy na odpowiedź z chmury
    await new Promise(resolve => setTimeout(resolve, 500));

    return [
      { id: 1, city: 'Wrocław',      title: 'Ostrów Tumski o świcie',   budget: 40,  hours: 3, color: '#fef9c3', icon: 'map-pin'  },
      { id: 2, city: 'Wałbrzych',    title: 'Zamek Książ i palmiarnia', budget: 120, hours: 6, color: '#dbeafe', icon: 'castle'   },
      { id: 3, city: 'Jelenia Góra', title: 'Perła Zachodu',            budget: 90,  hours: 5, color: '#fce7f3', icon: 'mountain' }
    ];
  }
};
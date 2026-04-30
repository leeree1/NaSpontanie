// Symulator bazy danych (Mock API)
const MockAPI = {
  fetchTrips: async () => {
    // Udajemy, że czekamy pół sekundy na odpowiedź z chmury
    await new Promise(resolve => setTimeout(resolve, 500));

    return [
      { 
        id: 'walbrzych', 
        city: 'Wałbrzych', 
        title: 'Zamek Książ i palmiarnia', 
        budget: 120, 
        hours: 7, 
        color: '#dbeafe', 
        icon: 'castle' 
      },
      { 
        id: 'swidnica', 
        city: 'Świdnica', 
        title: 'Kościół Pokoju i Rynek', 
        budget: 90, 
        hours: 5, 
        color: '#fef9c3', 
        icon: 'landmark' 
      }
    ];
  }
};
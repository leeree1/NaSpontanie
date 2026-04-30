// Nasz symulator bazy danych (Mock API)
const MockAPI = {
    fetchTrips: async () => {
        // Udajemy, że czekamy pół sekundy na odpowiedź z chmury
        await new Promise(resolve => setTimeout(resolve, 500));
        
        return [
            { 
                id: 'walbrzych', 
                city: 'Wałbrzych', 
                title: 'Zamek Książ i Stara Kopalnia', 
                budget: 120, 
                hours: 7, 
                color: '#dbeafe', 
                icon: 'castle' 
            },
            { 
                id: 'swidnica', 
                city: 'Świdnica', 
                title: 'Kościół Pokoju i piękny Rynek', 
                budget: 90, 
                hours: 5, 
                color: '#fef9c3', 
                icon: 'landmark' 
            }
        ];
    }
};

tailwind.config = {
  theme: {
    extend: {
      colors: {
        primary: '#0000FF',
        secondary: '#FACC15',
        accent: '#FB923C',
        bglight: '#FAFAFA',
        dark: '#111827'
      },
      fontFamily: {
        heading: ['Fraunces', 'serif'],
        body: ['DM Sans', 'sans-serif']
      }
    }
  }
}
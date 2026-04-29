const tripsData = {
    "walbrzych": {
        city: "Wałbrzych",
        distance: "Wrocław Główny → Wałbrzych",
        price: "120 zł",
        duration: "7h",
        transport: "pociąg + bus",
        timeline: [
            { time: '7:30', label: 'Wyjazd pociągiem z Wrocławia', type: 'transport' },
            { time: '9:00', label: 'Zamek Książ — zwiedzanie', type: 'sight' },
            { time: '11:15', label: 'Palmiarnia — egzotyczny ogród', type: 'sight' },
            { time: '13:00', label: 'Muzeum Porcelany', type: 'sight' },
            { time: '14:15', label: 'Stara Kopalnia — podziemia', type: 'sight' },
            { time: '17:00', label: 'Wieża Widokowa — panorama', type: 'sight' },
            { time: '19:00', label: 'Powrót do Wrocławia', type: 'transport' }
        ],
        attractions: [
            { title: 'Zamek Książ', desc: 'Trzeci największy zamek w Polsce.', icon: 'castle' },
            { title: 'Palmiarnia', desc: 'Egzotyczne rośliny i lemury.', icon: 'leaf' },
            { title: 'Stara Kopalnia', desc: 'Centrum Nauki i Sztuki.', icon: 'hammer' }
        ],
        budget: [
            { label: 'Pociąg (obie strony)', amount: '35 zł', icon: 'train' },
            { label: 'Bilet Explore Wałbrzych', amount: '75 zł', icon: 'ticket' },
            { label: 'Inne wydatki', amount: '10 zł', icon: 'circle' }
        ],
        practical: [
            { label: 'Bilety', value: 'Kup bilet Explore Wałbrzych', icon: 'ticket' },
            { label: 'Dojazd', value: 'Linia nr 8 do Zamku', icon: 'bus' }
        ]
    },
    "swidnica": {
        city: "Świdnica",
        distance: "Wrocław Główny → Świdnica",
        price: "90 zł",
        duration: "5h",
        transport: "pociąg",
        timeline: [
            { time: '9:30', label: 'Pociąg z Wrocławia', type: 'transport' },
            { time: '10:45', label: 'Kościół Pokoju (UNESCO)', type: 'sight' },
            { time: '12:30', label: 'Rynek i Wieża Ratuszowa', type: 'sight' },
            { time: '14:00', label: 'Katedra Świdnicka', type: 'sight' },
            { time: '15:30', label: 'Powrót do Wrocławia', type: 'transport' }
        ],
        attractions: [
            { title: 'Kościół Pokoju', desc: 'Drewniana perła baroku UNESCO.', icon: 'landmark' },
            { title: 'Wieża Ratuszowa', desc: 'Najlepszy widok na miasto.', icon: 'telescope' },
            { title: 'Rynek', desc: 'Kolorowe kamienice i fontanny.', icon: 'map' }
        ],
        budget: [
            { label: 'Pociąg (obie strony)', amount: '26 zł', icon: 'train' },
            { label: 'Wstępy (Kościół + Wieża)', amount: '35 zł', icon: 'ticket' },
            { label: 'Obiad w Rynku', amount: '29 zł', icon: 'coffee' }
        ],
        practical: [
            { label: 'UNESCO', value: 'Kościół Pokoju jest zamknięty podczas nabożeństw', icon: 'info' },
            { label: 'Dojazd', value: 'Z dworca do Rynku jest 5 min pieszo', icon: 'footprints' }
        ]
    }
};

// Globalne zmienne, które nadpiszemy przy kliknięciu (żeby render.js działał)
let timelineData = [];
let attractionsData = [];
let budgetItems = [];
let practicalData = [];
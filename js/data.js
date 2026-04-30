const tripsData = {
    "walbrzych": {
        city: "Wałbrzych",
        bgImage: "https://polskapogodzinach.pl/wp-content/uploads/2022/01/walbrzych-panorama-miasta.jpg",
        distance: "Wrocław Główny → Wałbrzych",
        price: "150 zł",
        duration: "10h",
        transport: "pociąg + bus",
        mapLabels: ["Wałbrzych", "Zamek Książ", "Palmiarnia", "Muzeum Porcelany", "Stara Kopalnia", "Wieża Widokowa", "Wrocław Główny"],
        timeline: [
            { time: '7:30', label: 'Wyjazd pociągiem z Wrocławia', type: 'transport' },
            { time: '9:00', label: 'Zamek Książ — zwiedzanie', type: 'sight' },
            { time: '11:15', label: 'Palmiarnia — spacer leśną ścieżką', type: 'sight' },
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
            { label: 'Bilety KD (Wrocław <-> Wałbrzych)', amount: '58 zł', icon: 'train' },
            { label: 'Bilet Explore (ulgowy/firmowy)', amount: '87 zł', icon: 'ticket' },
            { label: 'Transport lokalny (bus)', amount: '5 zł', icon: 'bus' }
        ],
        practical: [
            { label: 'Rezerwacja', value: 'Stara Kopalnia: zarezerwuj bilet online!', icon: 'ticket' },
            { label: 'Pro-Tip', value: 'W poniedziałek Muzeum Porcelany jest gratis.', icon: 'sparkles' },
        ]
    },
    "swidnica": {
        city: "Świdnica",
        distance: "Wrocław Główny → Świdnica",
        price: "90 zł",
        duration: "5h",
        transport: "pociąg",
        mapLabels: ["Kościół Pokoju", "Rynek", "Katedra"], // tu zmieniasz/dodajesz miasta do mapki
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


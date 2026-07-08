const tripsData = {
    "walbrzych": {
        city: "Wałbrzych",
        bgImage: "https://polskapogodzinach.pl/wp-content/uploads/2022/01/walbrzych-panorama-miasta.jpg",
        distance: "Wrocław Główny → Wałbrzych",
        price: "150 zł",
        duration: "10h",
        mapPath: "M60,260 C180,150 350,250 500,180 S700,200 760,120", 
        startCy: 260,
        mapLabels: [
            { text: "Wałbrzych", cx: 170, cy: 210, info: "Stacja docelowa Kolei Dolnośląskich. Ok. 1h 10min z Wrocławia." },
            { text: "Zamek Książ", cx: 280, cy: 206, info: "Trzeci największy zamek w Polsce i perła Dolnego Śląska." },
            { text: "Palmiarnia", cx: 390, cy: 205, info: "Egzotyczny ogród z ponad 200 gatunkami roślin i lemurami." },
            { text: "Muzeum Porcelany", cx: 510, cy: 175, info: "Ponad 10 000 eksponatów historycznej śląskiej porcelany." },
            { text: "Stara Kopalnia", cx: 630, cy: 150, info: "Zwiedzanie z byłym górnikiem, trasa podziemna i wieża widokowa." },
            { text: "Wieża Widokowa", cx: 710, cy: 155, info: "Nowość! Panorama 360 stopni na Wałbrzych, Góry Wałbrzyskie i Sudety." }
        ],
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
            { label: 'Pro-Tip', value: 'W poniedziałek Muzeum Porcelany jest gratis.', icon: 'sparkles' }
        ]
    },
    "swidnica": {
        city: "Świdnica",
        bgImage: "https://muzeumkolejnictwa.pl/wp-content/uploads/2022/06/Rynek_wieza-ratuszowa-1024x683.jpg",
        distance: "Wrocław Główny → Świdnica",
        price: "90 zł",
        duration: "5h",
        transport: "pociąg",
        // Zmieniłam początek linii z M60,150 na M60,260, żeby startowała równo z kropką Wrocławia!
        mapPath: "M60,150 C150,110 300,90 440,110 S650,110 760,120", 
        startCy: 150,
        mapLabels: [
            // Kościół Pokoju: zmiana cy ze 145 na 125 (idzie wyżej, prosto na linię)
            { text: "Kościół Pokoju", cx: 220, cy: 110, info: "Drewniana perła baroku wpisana na listę światowego dziedzictwa UNESCO." },
            // Rynek: cx: 440, cy: 110 zostaje, bo leży idealnie
            { text: "Rynek", cx: 440, cy: 110, info: "Kolorowe, zabytkowe kamienice i piękna Wieża Ratuszowa." },
            // Katedra: cx: 660, cy: 112 zostaje, bo też trafiła w dziesiątkę
            { text: "Katedra", cx: 660, cy: 115, info: "Imponująca, gotycka Katedra z jedną z najwyższych wież w Polsce." }
        ],
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
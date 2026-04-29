const trips = [
  { city: 'Ojców', title: 'Dolina Prądnika', budget: 120, hours: 7, color: '#dbeafe', icon: 'mountain' },
  { city: 'Kazimierz Dolny', title: 'Nadwiślańska perła', budget: 95, hours: 8, color: '#fef9c3', icon: 'landmark' },
  { city: 'Zalipie', title: 'Malowana wieś', budget: 80, hours: 5, color: '#fce7f3', icon: 'palette' },
  { city: 'Książ', title: 'Zamek i ogrody', budget: 110, hours: 6, color: '#e0f2fe', icon: 'castle' },
  { city: 'Chochołów', title: 'Drewniana tradycja', budget: 70, hours: 4, color: '#f0fdf4', icon: 'home' }
];

const timelineData = [
  { time: '7:30 - 7:50', label: 'Wyjazd z Wrocławia Głównego pociągiem Kolei Dolnośląskich. Podróż trwa około 1 godziny i 10 minut.', type: 'transport' },
  { time: '9:00', label: 'Zamek Książ. Zwiedzanie trzeciego największego zamku w Polsce z audioguide’em (ok. 2 godziny).', type: 'sight' },
  { time: '11:15', label: 'Palmiarnia. Spacer leśną ścieżką od Zamku (~15-20 min) do egzotycznego ogrodu zimowego z ponad 200 gatunkami roślin (ok. 1 godzina).', type: 'sight' },
  { time: '13:00', label: 'Muzeum Porcelany. Zwiedzanie jedynego takiego muzeum w Polsce z kolekcją 10 000 eksponatów (ok. 1 godzina).', type: 'sight' },
  { time: '14:15', label: 'Stara Kopalnia. Zwiedzanie trasy podziemnej i maszynowni w dawnym Centrum Nauki i Sztuki (ok. 2 godziny).', type: 'sight' },
  { time: '17:00', label: 'Wieża Widokowa (Park Sobieskiego). Wejście na nową stalową wieżę z panoramą 360 stopni na Wałbrzych i Sudety (ok. 30 min).', type: 'sight' },
  { time: '19:00 - 20:00', label: 'Powrót do Wrocławia. Wyjazd pociągiem powrotnym ze stacji w Wałbrzychu.', type: 'transport' }
];

const attractionsData = [
  { name: 'Zamek Książ', desc: 'Trzeci największy zamek w Polsce — zwiedzanie z audioguide w cenie biletu', icon: 'castle' },
  { name: 'Palmiarnia', desc: 'Egzotyczny ogród zimowy z ponad 200 gatunkami roślin, pawiami i lemurami', icon: 'leaf' },
  { name: 'Muzeum Porcelany', desc: 'Jedynie takie muzeum w Polsce z kolekcją 10 000 eksponatów', icon: 'coffee' },
  { name: 'Stara Kopalnia', desc: 'Renesansowy zamek z muzeum i ogrodem', icon: 'castle' },
  { name: 'Wieża Widokowa', desc: 'Nowa stalowa wieża z panoramą 360 stopni na Wałbrzych i Sudety', icon: 'castle' }
];

const budgetItems = [
  { label: 'Pociąg Wrocław - Wałbrzych (obie strony)', amount: '35 zł', icon: 'train' },
  { label: 'Bilet Explore Wałbrzych (4 atrakcje)', amount: '75 zł', icon: 'ticket' },
  { label: 'Jedzenie', amount: '45 zł', icon: 'utensils' },
  { label: 'Bilet na Wieżę Widokową', amount: '10 zł', icon: 'circle-dot' }
];

const practicalData = [
  { label: 'Bilet Explore Wałbrzych', value: 'Najlepiej kupić bilet łączony, który obejmuje Zamek Książ, Palmiarnię, Starą Kopalnię i Muzeum Porcelany.', icon: 'ticket' },
  { label: 'Dojazd Kolejami', value: 'Z dworca Wałbrzych Miasto do Starej Kopalni dojdziesz pieszo w 10 minut. Do Zamku Książ dojedziesz autobusem linii 8.', icon: 'train' },
  { label: 'Aplikacja KDR', value: 'Jeśli masz Kartę Dużej Rodziny, sprawdź zniżki na bilety wstępu — Wałbrzych oferuje spore rabaty.', icon: 'smartphone' },
  { label: 'Obuwie i pogoda', value: 'W kopalni panuje stała temperatura ok. 10 stopni, a w Palmiarni jest bardzo wilgotno — ubierz się "na cebulkę".', icon: 'cloud-rain' }
];

const reviewsData = [
  { name: 'Marta K.', rating: 5, text: 'Idealna wycieczka na jeden dzień! Krajobraz zapiera dech.', time: '2 tyg. temu' },
  { name: 'Tomek W.', rating: 4, text: 'Świetny plan, jaskinia robi wrażenie. Polecam wygodne buty.', time: '1 mies. temu' }
];
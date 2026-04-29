const trips = [
  { city: 'Ojców', title: 'Dolina Prądnika', budget: 120, hours: 7, color: '#dbeafe', icon: 'mountain' },
  { city: 'Kazimierz Dolny', title: 'Nadwiślańska perła', budget: 95, hours: 8, color: '#fef9c3', icon: 'landmark' },
  { city: 'Zalipie', title: 'Malowana wieś', budget: 80, hours: 5, color: '#fce7f3', icon: 'palette' },
  { city: 'Książ', title: 'Zamek i ogrody', budget: 110, hours: 6, color: '#e0f2fe', icon: 'castle' },
  { city: 'Chochołów', title: 'Drewniana tradycja', budget: 70, hours: 4, color: '#f0fdf4', icon: 'home' }
];

const timelineData = [
  { time: '7:30', label: 'Wyjazd pociągiem z Krakowa', type: 'transport' },
  { time: '8:15', label: 'Przyjazd do Ojcowa, krótki spacer', type: 'walk' },
  { time: '9:00', label: 'Brama Krakowska — widok na dolinę', type: 'sight' },
  { time: '10:30', label: 'Jaskinia Łokietka — zwiedzanie', type: 'sight' },
  { time: '12:00', label: 'Obiad w lokalnym barze', type: 'food' },
  { time: '13:00', label: 'Szlak do Pieskowej Skały', type: 'walk' },
  { time: '14:30', label: 'Zamek Pieskowa Skała', type: 'sight' },
  { time: '16:00', label: 'Powrót busem do Krakowa', type: 'transport' }
];

const attractionsData = [
  { name: 'Brama Krakowska', desc: 'Naturalna formacja skalna, symbol Ojcowa', icon: 'mountain' },
  { name: 'Jaskinia Łokietka', desc: '320m podziemnych korytarzy z legendą', icon: 'flashlight' },
  { name: 'Maczuga Herkulesa', desc: '25-metrowy wapień stojący samotnie', icon: 'milestone' },
  { name: 'Zamek Pieskowa Skała', desc: 'Renesansowy zamek z muzeum i ogrodem', icon: 'castle' }
];

const budgetItems = [
  { label: 'Transport', amount: '35 zł', icon: 'train' },
  { label: 'Atrakcje', amount: '25 zł', icon: 'ticket' },
  { label: 'Jedzenie', amount: '45 zł', icon: 'utensils' },
  { label: 'Inne', amount: '15 zł', icon: 'circle-dot' }
];

const practicalData = [
  { label: 'Godziny otwarcia', value: 'Jaskinia: 9:00–17:00', icon: 'clock' },
  { label: 'Bilety', value: 'Jaskinia 20 zł, zamek 5 zł', icon: 'ticket' },
  { label: 'Parking', value: 'Bezpłatny przy wejściu', icon: 'car' },
  { label: 'Płatność', value: 'Gotówka + karta', icon: 'credit-card' }
];

const reviewsData = [
  { name: 'Marta K.', rating: 5, text: 'Idealna wycieczka na jeden dzień! Krajobraz zapiera dech.', time: '2 tyg. temu' },
  { name: 'Tomek W.', rating: 4, text: 'Świetny plan, jaskinia robi wrażenie. Polecam wygodne buty.', time: '1 mies. temu' }
];
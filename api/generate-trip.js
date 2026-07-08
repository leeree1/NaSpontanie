// api/generate-trip.js
export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Only POST allowed' });
  }

  const { climate, budget, duration, transport, difficulty } = req.body;
  const apiKey = process.env.GEMINI_API_KEY;

  try {
    const prompt = `Zaplanuj jednodniową wycieczkę w Polsce o następujących kryteriach:
    - Klimat/Miejsce: ${climate}
    - Maksymalny budżet na osobę: ${budget} PLN
    - Czas trwania: ${duration}
    - Środek transportu: ${transport}
    - Poziom trudności fizycznej: ${difficulty}
    
    Sam dobierz idealne miejsce. Wygeneruj kompletny plan dnia w formacie JSON. 
    Zwrot ma być czystym obiektem JSON, bez żadnych znaków markdownu typu \`\`\`json.
    Struktura musi wyglądać dokładnie tak:
    {
      "id": "wygenerowane_id_miasta",
      "city": "Nazwa miejsca",
      "distance": "Krótki podtytuł trasy",
      "price": "Łączny koszt (np. 120 zł)",
      "duration": "Łączny czas (np. 8h)",
      "transport": "Transport",
      "bgImage": "https://images.unsplash.com/photo-1589308078059-be1415eab4c3?q=80&w=1200",
      "startCy": 260,
      "mapPath": "M60,260 C180,150 350,250 500,180 S700,200 760,120",
      "mapLabels": [{ "text": "Punkt 1", "cx": 200, "cy": 220, "info": "Opis" }],
      "timeline": [{ "time": "09:00", "title": "Start", "desc": "Opis" }],
      "attractions": [{ "title": "Atrakcja", "desc": "Opis", "image": "https://images.unsplash.com/photo-1589308078059-be1415eab4c3?q=80&w=400" }],
      "budget": [{ "label": "Wydatek", "amount": "30 zł", "icon": "ticket" }],
      "practical": [{ "title": "Porada", "desc": "Treść" }]
    }`;

    // Oficjalne zapytanie HTTP do darmowego API Gemini (nie potrzebujesz instalować dodatkowych paczek npm!)
    const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { responseMimeType: "application/json" } // Wymuszamy format JSON
      })
    });

    const data = await response.json();
    const responseText = data.candidates[0].content.parts[0].text;
    const tripData = JSON.parse(responseText);
    
    return res.status(200).json(tripData);

  } catch (error) {
    console.error("Błąd darmowego Agenta Gemini:", error);
    return res.status(500).json({ message: "Agent Gemini nie dał rady." });
  }
}
// api/generate-trip.js
export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Only POST allowed' });
  }

  const { climate, budget, duration, transport, difficulty } = req.body;
  const apiKey = process.env.GEMINI_API_KEY;

  if (!apiKey) {
    return res.status(500).json({ message: "Brak klucza GEMINI_API_KEY w konfiguracji Vercela!" });
  }

  try {
    const prompt = `Zaplanuj jednodniową wycieczkę w Polsce o następujących kryteriach:
    - Klimat/Miejsce: ${climate}
    - Maksymalny budżet na osobę: ${budget} PLN
    - Czas trwania: ${duration}
    - Środek transportu: ${transport}
    - Poziom trudności fizycznej: ${difficulty}
    
    Sam dobierz idealne miasto lub region w Polsce. Wygeneruj kompletny plan dnia jako obiekt JSON. 
    Struktura musi wyglądać DOKŁADNIE tak, zachowaj te same klucze:
    {
      "id": "unikalne_id_wycieczki",
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

    const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { 
          responseMimeType: "application/json"
        }
      })
    });

    const data = await response.json();
    
    // BEZPIECZNE SPRAWDZENIE: Czy Google nie zwróciło błędu struktury lub blokady
    if (!data.candidates || !data.candidates[0] || !data.candidates[0].content || !data.candidates[0].content.parts || !data.candidates[0].content.parts[0]) {
      console.error("Nieprawidłowa odpowiedź z API Gemini:", JSON.stringify(data));
      return res.status(500).json({ message: "Gemini zwróciło pustą odpowiedź. Prawdopodobnie blokada filtrów bezpieczeństwa Google." });
    }

    let responseText = data.candidates[0].content.parts[0].text.trim();
    
    // ODRAZU OCZYSZCZAMY Z ENKAPSULACJI MARKDOWN (gdyby Gemini i tak dodało ```json)
    if (responseText.startsWith("```")) {
      responseText = responseText.replace(/^```json/, "").replace(/^```/, "").replace(/```$/, "").trim();
    }

    const tripData = JSON.parse(responseText);
    return res.status(200).json(tripData);

  } catch (error) {
    console.error("Pełny błąd parsowania danych:", error);
    return res.status(500).json({ message: "Agent napotkał problem przy przetwarzaniu struktury wycieczki." });
  }
}
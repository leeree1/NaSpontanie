// api/generate-trip.js
import { OpenAI } from 'openai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY, // Bezpieczny klucz ukryty w panelu Vercela
});

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Only POST allowed' });
  }

  const { climate, budget, duration, transport, difficulty } = req.body;

  try {
    // Konstruujemy dynamiczny prompt na podstawie tego, co użytkownik kliknął na stronie
    const prompt = `Zaplanuj jednodniową wycieczkę w Polsce o następujących kryteriach:
    - Klimat/Miejsce: ${climate}
    - Maksymalny budżet na osobę: ${budget} PLN
    - Czas trwania: ${duration}
    - Środek transportu: ${transport}
    - Poziom trudności fizycznej: ${difficulty}
    
    Sam dobierz idealne miasto, region lub pasmo górskie, które pasuje do tych filtrów. Oblicz realne, aktualne koszty.`;

    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini', // Szybki i świetny do strukturyzowanych danych
      response_format: { type: "json_object" }, // Wymuszamy na AI czysty format JSON
      messages: [
        {
          role: 'system',
          content: `Jesteś zaawansowanym agentem turystycznym aplikacji NaSpontanie. Twoim zadaniem jest wygenerowanie kompletnego planu dnia w formacie JSON. 
          Nie dopisuj żadnego tekstu przed ani po JSON. Format wyjściowy musi dokładnie odpowiadać tej strukturze:
          {
            "id": "wygenerowane_id_miasta",
            "city": "Nazwa miejsca/pasma górskiego",
            "distance": "Krótki podtytuł określający trasę",
            "price": "Łączny koszt w zł (np. 120 zł)",
            "duration": "Łączny czas w godzinach (np. 8h)",
            "transport": "Środek transportu",
            "bgImage": "URL do zdjęcia z Unsplash pasującego do tego miejsca",
            "startCy": 260,
            "mapPath": "Wygeneruj falowaną linię SVG dla ścieżki, np. 'M60,260 C180,150 350,250 500,180 S700,200 760,120'",
            "mapLabels": [
              { "text": "Nazwa punktu 1", "cx": 200, "cy": 220, "info": "Ciekawy opis/tooltip, który pojawi się po najechaniu" }
            ],
            "timeline": [
              { "time": "GG:MM", "title": "Nazwa etapu", "desc": "Szczegółowy opis co robić" }
            ],
            "attractions": [
              { "title": "Nazwa atrakcji", "desc": "Opis", "image": "URL do zdjęcia" }
            ],
            "budget": [
              { "label": "Na co wydatek", "amount": "X zł", "icon": "Ikona z Lucide, np. ticket, train, coffee" }
            ],
            "practical": [
              { "title": "Nagłówek porady", "desc": "Treść praktycznej wskazówki" }
            ]
          }`
        },
        { role: 'user', content: prompt }
      ]
    });

    // Odbieramy gotowy, unikalny JSON stworzony w 100% przez sztuczną inteligencję
    const tripData = JSON.parse(response.choices[0].message.content);
    
    return res.status(200).json(tripData);

  } catch (error) {
    console.error("Błąd Agenta AI:", error);
    return res.status(500).json({ message: "Agent nie dał rady wygenerować planu." });
  }
}